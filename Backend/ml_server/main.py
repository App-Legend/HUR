"""
이미지를 CLIP 임베딩 벡터로 변환하거나(/embed), 미리 정해둔 카테고리 중
가장 가까운 걸 자동으로 골라주는(/classify) 마이크로서비스.

/embed  -> productController.js(recommendByImage)가 벡터 유사도 검색에 사용
/classify -> postController.js(createPost)가 게시물 업로드 시 자동 태깅에 사용
"""
import base64
import io

import open_clip
import torch
from fastapi import FastAPI
from PIL import Image
from pydantic import BaseModel

app = FastAPI(title="HUR ML Server")

MODEL_NAME = "ViT-B-32"
PRETRAINED = "openai"

model, _, preprocess = open_clip.create_model_and_transforms(MODEL_NAME, pretrained=PRETRAINED)
tokenizer = open_clip.get_tokenizer(MODEL_NAME)
model.eval()

# CLIP은 영어 위주로 학습되어 한국어 프롬프트보다 정확도가 높으므로,
# 분류 기준 문장은 영어로 쓰고 결과는 기존 DB 값(한국어)으로 매핑한다.
# post_category.category_value와 정확히 일치해야 한다 (Frontend upload_page.dart의 후보 목록 기준).
CATEGORY_PROMPTS = {
    "personal_color": {
        "봄 웜톤": "a photo of spring warm tone makeup, bright peachy coral warm colors, glowing warm skin",
        "가을 웜톤": "a photo of autumn warm tone makeup, deep earthy brown terracotta warm colors",
        "겨울 쿨톤": "a photo of winter cool tone makeup, high contrast vivid blue-based cool colors",
        "여름쿨톤": "a photo of summer cool tone makeup, soft pastel rosy lavender-pink cool colors",
    },
    "mood": {
        "청순": "a photo of an innocent clean-girl natural fresh makeup look",
        "시크": "a photo of a chic sharp edgy bold makeup look",
        "큐티": "a photo of a cute playful sweet makeup look",
        "섹시": "a photo of a sexy sultry glamorous makeup look",
        "차분": "a photo of a calm subdued muted minimal makeup look",
    },
}


def _encode_texts(prompts: list[str]) -> torch.Tensor:
    tokens = tokenizer(prompts)
    with torch.no_grad():
        features = model.encode_text(tokens)
        features = features / features.norm(dim=-1, keepdim=True)
    return features


# 서버 시작 시 카테고리 텍스트 임베딩을 한 번만 계산해서 캐싱 (요청마다 다시 계산 안 함)
_CATEGORY_TEXT_EMBEDDINGS = {
    category_type: {
        "labels": list(values.keys()),
        "embeddings": _encode_texts(list(values.values())),
    }
    for category_type, values in CATEGORY_PROMPTS.items()
}


class EmbedRequest(BaseModel):
    image: str  # base64 인코딩된 이미지 (data URL prefix 없이)


class EmbedResponse(BaseModel):
    embedding: list[float]
    model_version: str


class ClassifyResponse(BaseModel):
    personal_color: str
    moods: list[str]
    model_version: str


def _image_features(image_b64: str) -> torch.Tensor:
    image_bytes = base64.b64decode(image_b64)
    image = Image.open(io.BytesIO(image_bytes)).convert("RGB")
    tensor = preprocess(image).unsqueeze(0)
    with torch.no_grad():
        features = model.encode_image(tensor)
        features = features / features.norm(dim=-1, keepdim=True)
    return features


@app.get("/health")
def health():
    return {"status": "ok"}


@app.post("/embed", response_model=EmbedResponse)
def embed(req: EmbedRequest):
    features = _image_features(req.image)
    return EmbedResponse(
        embedding=features[0].tolist(),
        model_version=f"{MODEL_NAME}/{PRETRAINED}",
    )


@app.post("/classify", response_model=ClassifyResponse)
def classify(req: EmbedRequest):
    image_features = _image_features(req.image)

    def best_label(category_type: str) -> list[tuple[str, float]]:
        labels = _CATEGORY_TEXT_EMBEDDINGS[category_type]["labels"]
        text_embeddings = _CATEGORY_TEXT_EMBEDDINGS[category_type]["embeddings"]
        scores = (image_features @ text_embeddings.T)[0].tolist()
        return sorted(zip(labels, scores), key=lambda x: x[1], reverse=True)

    personal_color_ranked = best_label("personal_color")
    mood_ranked = best_label("mood")

    # personal_color는 단일 선택, mood는 1위와 근소한 차이(0.03 이내)면 2위까지 같이 포함
    personal_color = personal_color_ranked[0][0]
    top_mood_score = mood_ranked[0][1]
    moods = [label for label, score in mood_ranked if top_mood_score - score <= 0.03][:2]

    return ClassifyResponse(
        personal_color=personal_color,
        moods=moods,
        model_version=f"{MODEL_NAME}/{PRETRAINED}",
    )
