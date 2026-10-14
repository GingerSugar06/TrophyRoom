/// Küçük kalıcı ayarlar: dil ve ilk açılış uyarısının görüldüğü bilgisi.
///
/// `%APPDATA%\Trophy Room\prefs.json`. Hiçbir kişisel veri yok.
library;

import 'dart:convert';
import 'dart:io';
import 'dart:ui' show PlatformDispatcher;

class Prefs {
  String lang = PlatformDispatcher.instance.locale.languageCode == 'tr' ? 'tr' : 'en';
  bool introSeen = false;

  static File get _file {
    final base = Platform.environment['APPDATA'] ?? Directory.systemTemp.path;
    return File('$base${Platform.pathSeparator}TrophyRoom${Platform.pathSeparator}prefs.json');
  }

  static Prefs load() {
    final p = Prefs();
    try {
      final j = jsonDecode(_file.readAsStringSync());
      if (j is Map) {
        if (j['lang'] == 'tr' || j['lang'] == 'en') p.lang = j['lang'] as String;
        p.introSeen = j['introSeen'] == true;
      }
    } catch (_) {}
    return p;
  }

  void save() {
    try {
      _file.parent.createSync(recursive: true);
      _file.writeAsStringSync(jsonEncode({'lang': lang, 'introSeen': introSeen}));
    } catch (_) {}
  }
}
