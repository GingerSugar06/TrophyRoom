/// TR/EN çeviri tablosu: anahtar -> [Türkçe, English].
library;

class S {
  const S(this.code);
  final String code;
  bool get tr => code == 'tr';

  /// Steam şemasındaki dil adı (başarım başlıkları için).
  String get steamLang => tr ? 'turkish' : 'english';

  String t(String key, [Map<String, String>? args]) {
    final v = _m[key];
    var out = v == null ? key : v[tr ? 0 : 1];
    args?.forEach((k, val) => out = out.replaceAll('{$k}', val));
    return out;
  }

  static const _m = <String, List<String>>{
    'subtitle': ['Steam başarım yöneticisi', 'Steam achievement manager'],
    'games_count': ['{n} oyun', '{n} games'],
    'refresh': ['Kütüphaneyi yenile', 'Refresh library'],
    'search_games': ['Oyun ara…   (Ctrl+F)', 'Search games…   (Ctrl+F)'],
    'only_installed': ['Yalnız kurulu', 'Installed only'],
    'steam_missing': ['Steam bulunamadı', 'Steam not found'],
    'steam_missing_msg': [
      'Steam kurulu değil ya da kayıt defterinde görünmüyor. Steam’i kur, bir kez aç ve yenile.',
      'Steam is not installed or not in the registry. Install Steam, open it once and refresh.'
    ],
    'no_match': ['Eşleşme yok', 'No matches'],
    'no_match_msg': ['Farklı bir ad ya da uygulama kimliği dene.', 'Try a different name or AppID.'],
    'no_games': ['Başarımlı oyun bulunamadı', 'No games with achievements found'],
    'no_games_msg': [
      'Steam, başarımı olan oyunların şemasını bir kez açıldıktan sonra diske yazar. Oyunlarını Steam’de bir kere başlat ve yenile.',
      'Steam writes the achievement schema to disk after a game has been opened once. Launch your games in Steam once, then refresh.'
    ],

    // sağ panel
    'pick_game': ['Bir oyun seç', 'Pick a game'],
    'pick_game_msg': [
      'Soldaki listeden bir oyuna tıkla; başarımları burada açılır. Değişiklikler “Uygula” diyene kadar Steam’e yazılmaz.',
      'Click a game on the left to see its achievements here. Nothing is written to Steam until you press “Apply”.'
    ],
    'step1': ['Oyunu seç', 'Choose a game'],
    'step1_d': ['Kurulu olmayanlar da listelenir.', 'Uninstalled games are listed too.'],
    'step2': ['Başarımları işaretle', 'Mark achievements'],
    'step2_d': ['Tıklamak değişikliği biriktirir.', 'Clicking queues a change.'],
    'step3': ['Uygula', 'Apply'],
    'step3_d': ['Hepsi tek seferde Steam’e yazılır.', 'Everything is written to Steam at once.'],
    'failed_open': ['Açılamadı', 'Could not open'],
    'unknown_error': ['Bilinmeyen hata.', 'Unknown error.'],
    'search_ach': ['Başarım ara…', 'Search achievements…'],
    'only_locked': ['Yalnız kilitli', 'Locked only'],
    'hidden': ['Gizliler', 'Hidden'],
    'unlock_visible': ['Görünenleri aç', 'Unlock visible'],
    'lock_visible': ['Görünenleri kilitle', 'Lock visible'],
    'invert_visible': ['Görünenleri tersine çevir', 'Invert visible'],
    'no_filter_match': ['Süzgece uyan başarım yok', 'No achievements match'],
    'no_filter_match_msg': ['Süzgeçleri gevşetmeyi dene.', 'Try loosening the filters.'],
    'unlocked_of': ['{a} / {b} açık', '{a} / {b} unlocked'],
    'will_unlock': ['açılacak', 'will unlock'],
    'will_lock': ['kilitlenecek', 'will lock'],
    'hidden_badge': ['Gizli başarım', 'Hidden achievement'],
    'changes_pending': ['{n} değişiklik bekliyor', '{n} changes pending'],
    'undo': ['Geri al', 'Undo'],
    'apply': ['Uygula', 'Apply'],
    'applied': ['{n} değişiklik yazıldı', '{n} changes written'],
    'applied_failed': [' · {n} başarısız', ' · {n} failed'],
    'store_refused': [
      'Steam yazmayı reddetti. Oyun açıksa kapatıp yeniden dene.',
      'Steam refused the write. If the game is running, close it and try again.'
    ],
    'worker_missing': [
      'trophy_worker.exe bulunamadı. Uygulamayı “tool\\build.ps1” ile derle ya da paketi eksiksiz çıkar.',
      'trophy_worker.exe not found. Build with “tool\\build.ps1” or extract the full package.'
    ],
    'steam_no_response': ['Steam yanıt vermedi. Steam açık ve oturum açık mı?', 'Steam did not respond. Is Steam running and signed in?'],
    'worker_died': ['Yardımcı süreç beklenmedik şekilde kapandı.', 'The helper process closed unexpectedly.'],

    // ilk açılış uyarısı
    'intro_title': ['Başlamadan önce', 'Before you start'],
    'intro_body': [
      'Başarımları elle değiştirmek Steam profilinde kalıcı iz bırakır ve bazı oyunların topluluk sıralamalarında fark edilebilir. Yalnızca kendi hesabında, ne yaptığını bilerek kullan.\n\nSteam açık ve oturum açılmış olmalı. Oyun açıkken yazma reddedilebilir.',
      'Changing achievements by hand leaves a permanent trace on your Steam profile and some games’ community rankings may notice it. Use it only on your own account and know what you are doing.\n\nSteam must be running and signed in. Writes can be refused while the game is open.'
    ],
    'intro_ok': ['Anladım', 'I understand'],
    'language': ['Dil', 'Language'],
    'err_steamNotFound': ['Steam kurulumu bulunamadı. Steam kurulu ve açık olmalı.', 'Steam installation not found. Steam must be installed and running.'],
    'err_loadFailed': ['Steam kitaplığı yüklenemedi.', 'Could not load the Steam library.'],
    'err_createInterface': ['Steam arayüzü oluşturulamadı; Steam sürümü uyumsuz olabilir.', 'Could not create the Steam interface; your Steam version may be incompatible.'],
    'err_pipe': ['Steam borusu açılamadı. Steam açık mı?', 'Could not open the Steam pipe. Is Steam running?'],
    'err_user': ['Steam kullanıcısına bağlanılamadı. Steam’de oturum açık mı?', 'Could not connect to the Steam user. Are you signed in to Steam?'],
    'err_appIdMismatch': ['Steam başka bir uygulamayı verdi. Uygulamayı yeniden başlatıp tekrar dene.', 'Steam returned a different app. Restart the app and try again.'],
    'err_schemaMissing': ['Bu oyunun başarım şeması Steam önbelleğinde yok. Oyunu Steam’de bir kez başlatmak şemayı indirtir.', 'This game’s achievement schema is not in the Steam cache. Launching the game once in Steam downloads it.'],
    'err_usage': ['Geçersiz oyun kimliği.', 'Invalid game id.'],
  };
}
