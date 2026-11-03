import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:hur_app/app/theme.dart';
import 'package:hur_app/core/product_buy_link.dart';

/// 구매처 안내 문구. 구매 링크가 준비되기 전에 두 화면이 같은 문구를 쓴다.
const String _kBuyLinkNotReadyMessage = '준비 중이에요';

/// 구매처 주소를 연다. [kBuyLinkReady] 가 false 면 브라우저 대신 "준비 중이에요" 스낵바만 띄운다.
Future<void> openBuyLink(BuildContext context, Uri url) async {
  final messenger = ScaffoldMessenger.of(context);
  if (!kBuyLinkReady) {
    messenger.showSnackBar(
      const SnackBar(
        backgroundColor: HurColors.panel,
        content: Text(
          _kBuyLinkNotReadyMessage,
          style: TextStyle(color: HurColors.text),
        ),
      ),
    );
    return;
  }
  try {
    final ok = await launchUrl(url, mode: LaunchMode.externalApplication);
    if (!ok) throw Exception('launch failed');
  } catch (_) {
    messenger.showSnackBar(const SnackBar(content: Text('구매 링크를 열지 못했어요.')));
  }
}
