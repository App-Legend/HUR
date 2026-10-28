//  ————————————————————————————————
//  |   안내 문서 (가이드라인/약관 등)  |
//  ————————————————————————————————

import 'package:flutter/material.dart';
import 'package:hur_app/app/theme.dart';

/// 제목과 (소제목, 본문) 묶음을 보여주는 단순 문서 화면.
class InfoTextPage extends StatelessWidget {
  final String title;
  final String? intro;
  final List<(String, String)> sections;

  const InfoTextPage({
    super.key,
    required this.title,
    this.intro,
    required this.sections,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HurColors.bg,
      appBar: AppBar(
        backgroundColor: HurColors.bg,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: HurColors.text, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: HurColors.text,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, thickness: 1, color: HurColors.line),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
        children: [
          if (intro != null) ...[
            Text(
              intro!,
              style: const TextStyle(color: HurColors.muted, fontSize: 14, height: 1.6),
            ),
            const SizedBox(height: 24),
          ],
          for (final (heading, body) in sections) ...[
            Text(
              heading,
              style: const TextStyle(
                color: HurColors.text,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              body,
              style: const TextStyle(color: HurColors.muted, fontSize: 14, height: 1.6),
            ),
            const SizedBox(height: 22),
          ],
        ],
      ),
    );
  }
}

const _demoNotice = 'HUR는 대림대학교 컴퓨터정보학부 졸업작품으로 제작된 시연용 서비스입니다.';

class CommunityGuidelinesPage extends StatelessWidget {
  const CommunityGuidelinesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const InfoTextPage(
      title: '커뮤니티 가이드라인',
      intro: 'HUR는 원하는 분위기를 함께 찾아가는 공간이에요. 모두가 편하게 이용할 수 있도록 아래 약속을 지켜주세요.',
      sections: [
        ('서로를 존중해요', '다른 사람을 비방하거나 조롱하는 게시물과 댓글은 올리지 않아요.'),
        ('내 사진만 올려요', '다른 사람의 사진을 허락 없이 올리지 않아요. 타인의 얼굴이 담긴 사진은 동의를 받은 경우에만 올려주세요.'),
        ('정확한 정보를 나눠요', '제품 태그와 후기는 직접 사용한 경험을 바탕으로 솔직하게 남겨주세요. 광고성 게시물과 허위 후기는 삭제될 수 있어요.'),
        ('안전한 환경을 지켜요', '선정적이거나 폭력적인 내용, 개인정보가 드러나는 게시물은 올리지 않아요.'),
        ('신고와 차단', '불편한 게시물이나 계정은 게시물 메뉴에서 신고하거나 차단할 수 있어요.'),
      ],
    );
  }
}

class SupportPage extends StatelessWidget {
  const SupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const InfoTextPage(
      title: '고객센터',
      intro: _demoNotice,
      sections: [
        ('문의하기', '서비스 이용 중 불편한 점이나 제안은 HUR 팀에 전달해 주세요. 시연 기간에는 현장에서 팀원에게 직접 문의하실 수 있어요.'),
        ('자주 묻는 질문', 'Q. 퍼스널컬러는 어떻게 정해지나요?\nA. 프로필에서 직접 선택한 값을 사용해요.\n\nQ. 게시물을 삭제하고 싶어요.\nA. 내 게시물 상세 화면 오른쪽 위의 휴지통 아이콘을 눌러주세요.\n\nQ. 저장한 게시물은 어디서 보나요?\nA. 프로필의 북마크 탭에서 볼 수 있어요.'),
        ('운영 팀', '대림대학교 컴퓨터정보학부\n성수연 · 송윤서 · 박건우 · 노신용'),
      ],
    );
  }
}

class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const InfoTextPage(
      title: '이용약관',
      intro: _demoNotice,
      sections: [
        ('제1조 (목적)', '이 약관은 HUR(이하 "서비스")가 제공하는 뷰티 추구미 공유 및 제품 추천 서비스의 이용 조건과 절차, 이용자와 운영자의 권리와 의무를 정하는 것을 목적으로 해요.'),
        ('제2조 (회원)', '이용자는 이메일로 가입해 회원이 될 수 있어요. 회원은 본인의 계정 정보를 직접 관리해야 하며, 타인에게 양도하거나 대여할 수 없어요.'),
        ('제3조 (게시물)', '회원이 올린 게시물의 권리는 회원에게 있어요. 다만 서비스 운영과 추천 기능을 위해 게시물을 서비스 안에서 노출하고 분석하는 데 사용할 수 있어요. 가이드라인에 어긋나는 게시물은 사전 안내 없이 삭제될 수 있어요.'),
        ('제4조 (AI 분석)', '서비스는 사진의 분위기를 AI로 분석해 태그와 추천에 활용해요. 분석 결과는 참고용이며 정확하지 않을 수 있어요.'),
        ('제5조 (이용 제한)', '다른 이용자에게 피해를 주거나 서비스 운영을 방해하는 경우 이용이 제한될 수 있어요.'),
        ('제6조 (탈퇴)', '회원은 언제든지 설정에서 탈퇴할 수 있어요. 탈퇴하면 계정과 게시물 등 관련 데이터가 삭제돼요.'),
      ],
    );
  }
}

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const InfoTextPage(
      title: '개인정보처리방침',
      intro: _demoNotice,
      sections: [
        ('수집하는 정보', '회원가입 시 이메일, 이름, 닉네임, 비밀번호(암호화 저장)를 수집해요. 이용 중에는 프로필 정보(퍼스널컬러, 피부톤, 선호 무드), 업로드한 사진과 게시물, 좋아요·댓글·북마크·검색 기록이 저장돼요.'),
        ('이용 목적', '회원 식별과 로그인, 맞춤 피드와 제품 랭킹 제공, 서비스 개선을 위해서만 사용해요.'),
        ('보관과 삭제', '정보는 회원 탈퇴 시까지 보관하며, 탈퇴하면 지체 없이 삭제해요.'),
        ('제3자 제공', '법령에 근거가 있는 경우를 제외하고 개인정보를 외부에 제공하지 않아요.'),
        ('이용자의 권리', '설정에서 언제든지 내 정보를 확인하고 수정할 수 있으며, 회원 탈퇴를 요청할 수 있어요.'),
      ],
    );
  }
}
