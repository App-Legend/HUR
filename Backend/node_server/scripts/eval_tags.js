// AI 자동 태깅(퍼스널컬러/무드) 정확도 평가 스크립트.
// 정답표(CSV)의 사진을 ml_server /classify 에 보내고, 예측과 정답을 비교해 정확도를 출력한다.
// DB는 쓰지 않는다. docker-compose 네트워크 안에서 실행해야 ml_server에 접속 가능하다.
//
// 정답표 형식(UTF-8, 첫 줄은 헤더): 파일명, 정답_퍼스널컬러, 정답_무드, ...
// 사진/정답표 위치(base): S3 주소(https://...)이거나 로컬 폴더 경로.
//
// 사용법: docker compose exec backend node scripts/eval_tags.js <base> [정답표 파일명]
// 예)    docker compose exec backend node scripts/eval_tags.js https://hur-app-images.s3.ap-northeast-2.amazonaws.com/eval eval_labels.csv
const fs = require("fs");
const path = require("path");

const ML_SERVICE_URL = process.env.ML_SERVICE_URL || "http://localhost:8000";

const base = process.argv[2];
const csvName = process.argv[3] || "eval_labels.csv";

if (!base) {
    console.error("사용법: node scripts/eval_tags.js <S3주소 또는 폴더경로> [정답표 파일명]");
    process.exit(1);
}

const isUrl = /^https?:\/\//.test(base);

async function readBytes(name) {
    if (isUrl) {
        const url = `${base.replace(/\/$/, "")}/${encodeURIComponent(name)}`;
        const res = await fetch(url);
        if (!res.ok) throw new Error(`다운로드 실패 (${res.status}): ${url}`);
        return Buffer.from(await res.arrayBuffer());
    }
    return fs.readFileSync(path.join(base, name));
}

// 따옴표 없는 단순 CSV 기준(쉼표 포함 필드는 따옴표 처리). BOM 제거.
function parseCsv(text) {
    const rows = [];
    for (const line of text.replace(/^﻿/, "").split(/\r?\n/)) {
        if (!line.trim()) continue;
        const cells = [];
        let cur = "";
        let quoted = false;
        for (const ch of line) {
            if (ch === '"') quoted = !quoted;
            else if (ch === "," && !quoted) {
                cells.push(cur);
                cur = "";
            } else cur += ch;
        }
        cells.push(cur);
        rows.push(cells.map((c) => c.trim()));
    }
    return rows;
}

// "겨울 쿨톤" / "겨울쿨톤" 처럼 띄어쓰기만 다른 경우를 같은 라벨로 취급
const norm = (s) => (s || "").replace(/\s+/g, "");

async function classify(imageBase64) {
    const res = await fetch(`${ML_SERVICE_URL}/classify`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ image: imageBase64 }),
    });
    if (!res.ok) throw new Error(`ml_server classify 실패: ${await res.text()}`);
    return res.json();
}

const pct = (n, d) => (d ? `${((n / d) * 100).toFixed(1)}%` : "-");

// 정답 라벨별 맞춘 개수(재현율) 출력
function printPerLabel(title, stats) {
    console.log(`\n[${title}] 라벨별 (정답 기준)`);
    for (const [label, s] of Object.entries(stats).sort((a, b) => b[1].total - a[1].total)) {
        console.log(`  ${label.padEnd(8)} ${s.hit}/${s.total}  ${pct(s.hit, s.total)}`);
    }
}

// 행=정답, 열=예측 혼동행렬 출력
function printConfusion(title, matrix) {
    const preds = [...new Set(Object.values(matrix).flatMap((r) => Object.keys(r)))];
    console.log(`\n[${title}] 혼동행렬 (행=정답, 열=예측)`);
    console.log(`  ${"".padEnd(8)}${preds.map((p) => p.padEnd(8)).join("")}`);
    for (const [truth, row] of Object.entries(matrix)) {
        console.log(`  ${truth.padEnd(8)}${preds.map((p) => String(row[p] || 0).padEnd(8)).join("")}`);
    }
}

async function run() {
    const rows = parseCsv((await readBytes(csvName)).toString("utf8"));
    const header = rows.shift();
    const idx = (name) => header.findIndex((h) => h.startsWith(name));
    const iFile = idx("파일명");
    const iColor = idx("정답_퍼스널컬러");
    const iMood = idx("정답_무드");
    if (iFile < 0 || iColor < 0 || iMood < 0) {
        throw new Error("정답표 헤더에 파일명/정답_퍼스널컬러/정답_무드 열이 필요합니다.");
    }

    const items = rows.filter((r) => r[iFile] && r[iColor] && r[iMood]);
    console.log(`평가 대상 ${items.length}장 (정답이 비어있는 행은 제외)\n`);

    let colorHit = 0;
    let moodTop1Hit = 0;
    let moodAnyHit = 0;
    let done = 0;
    const colorStats = {};
    const moodStats = {};
    const colorMatrix = {};
    const moodMatrix = {};
    const truthColorCount = {};

    for (const r of items) {
        const file = r[iFile];
        const trueColor = r[iColor];
        const trueMood = r[iMood];
        try {
            const imageBase64 = (await readBytes(file)).toString("base64");
            const result = await classify(imageBase64);

            const predColor = result.personal_color;
            const predMoods = result.moods || [];
            const cOk = norm(predColor) === norm(trueColor);
            const mTop1 = norm(predMoods[0]) === norm(trueMood);
            const mAny = predMoods.some((m) => norm(m) === norm(trueMood));

            colorHit += cOk;
            moodTop1Hit += mTop1;
            moodAnyHit += mAny;
            done += 1;

            colorStats[trueColor] ||= { hit: 0, total: 0 };
            colorStats[trueColor].total += 1;
            colorStats[trueColor].hit += cOk;
            moodStats[trueMood] ||= { hit: 0, total: 0 };
            moodStats[trueMood].total += 1;
            moodStats[trueMood].hit += mTop1;

            colorMatrix[trueColor] ||= {};
            colorMatrix[trueColor][predColor] = (colorMatrix[trueColor][predColor] || 0) + 1;
            moodMatrix[trueMood] ||= {};
            moodMatrix[trueMood][predMoods[0]] = (moodMatrix[trueMood][predMoods[0]] || 0) + 1;
            truthColorCount[trueColor] = (truthColorCount[trueColor] || 0) + 1;

            console.log(
                `${file}  컬러 ${cOk ? "O" : "X"} (정답 ${trueColor} / 예측 ${predColor})  ` +
                    `무드 ${mTop1 ? "O" : mAny ? "△" : "X"} (정답 ${trueMood} / 예측 ${predMoods.join("+")})`
            );
        } catch (err) {
            console.error(`실패 ${file}: ${err.message}`);
        }
    }

    if (!done) {
        console.log("평가된 사진이 없습니다.");
        return;
    }

    // 항상 가장 많은 라벨만 찍어도 나오는 정확도. 이보다 높아야 의미가 있다.
    const majority = Math.max(...Object.values(truthColorCount));

    console.log("\n==================== 결과 ====================");
    console.log(`평가한 사진: ${done}장`);
    console.log(`퍼스널컬러 정확도: ${colorHit}/${done} = ${pct(colorHit, done)}  (랜덤 4택 25%, 최빈값 찍기 ${pct(majority, done)})`);
    console.log(`무드 정확도(1순위 일치): ${moodTop1Hit}/${done} = ${pct(moodTop1Hit, done)}  (랜덤 5택 20%)`);
    console.log(`무드 정확도(예측 후보 중 포함): ${moodAnyHit}/${done} = ${pct(moodAnyHit, done)}`);

    printPerLabel("퍼스널컬러", colorStats);
    printConfusion("퍼스널컬러", colorMatrix);
    printPerLabel("무드(1순위)", moodStats);
    printConfusion("무드(1순위)", moodMatrix);
}

run().catch((err) => {
    console.error(err);
    process.exit(1);
});
