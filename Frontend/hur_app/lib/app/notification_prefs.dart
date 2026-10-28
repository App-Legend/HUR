import 'package:shared_preferences/shared_preferences.dart';

/// 알림 종류(서버 type) → 설정 저장 키. 기본값은 모두 켜짐. 기기에 저장되며 계정별로 나누지 않는다.
const notificationPrefKeys = {
  'like': 'notify_like',
  'comment': 'notify_comment',
  'follow': 'notify_follow',
};

/// 서버의 `?types=` 파라미터에 넘길, 켜져 있는 알림 종류 (예: "like,comment").
Future<String> enabledNotificationTypes() async {
  final prefs = await SharedPreferences.getInstance();
  return notificationPrefKeys.entries
      .where((e) => prefs.getBool(e.value) ?? true)
      .map((e) => e.key)
      .join(',');
}
