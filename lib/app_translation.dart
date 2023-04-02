import 'package:get/get.dart';

class AppTranslation extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'vi_VN': vi_VN,
        'en_US': en_US,
      };

  static const Map<String, String> en_US = {
    'chat': 'Chat',
    'settings': 'Settings',
    'darkMode': 'Dark mode',
    'autoTTS': 'Auto TTS',
    'languages': 'Languages',
    'removeHistory': 'Remove History',
    'Select Language': 'Select Language',
    'Start typing or talking...': 'Start typing or talking...',
    'Touch': 'Touch',
    'Hold': 'Hold',
    'holdToTalk': 'Hold to Talk',
    "Touch to Stop":"Touch to Stop",
    "Release to Stop":"Release to Stop",
    "Touch to Talk":"Touch to Talk",
    "Hold to Talk": "Hold to Talk",

  };

  static const Map<String, String> vi_VN = {
    'chat': 'Trò chuyện',
    'settings': 'Cài đặt',
    'darkMode': 'Chế độ tối',
    'autoTTS': 'Tự động nói',
    'languages': 'Ngôn ngữ',
    'removeHistory': 'Xóa lịch sử',
    'Select Language': 'Chọn Ngôn Ngữ',
    'Start typing or talking...': 'Viết hoặc nói gì đó...',
    'Touch': 'Chạm',
    'Hold': 'Giữ',
    'holdToTalk': 'Giữ để nói',
    "Touch to Stop":"Chạm để Dừng",
    "Release to Stop":"Thả để Dừng",
    "Touch to Talk":"Chạm để Nói",
    "Hold to Talk": "Giữ để Nói",
  };
}
