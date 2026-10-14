/// **Uygulama durumu** — oyun listesi, seçili oyun, başarımlar, bekleyenler.
///
/// Riverpod/Bloc yok: bu uygulamanın tek bir ekranı ve tek bir akışı var.
/// `ChangeNotifier` bağımlılık getirmiyor ve açılışı hızlandırıyor — hız
/// iddiasında olan bir araçta bu bir tercih.
///
/// ## Bekleyen değişiklik kavramı
///
/// Kutucuğa basmak Steam'e HEMEN yazmıyor. Değişiklikler biriktiriliyor ve
/// oyuncu "Uygula" dediğinde tek bir `StoreStats` ile gidiyor. İki sebep:
///
///  1. Steam her yazmada bildirim çıkarıyor; on başarımı tek tek açmak on
///     bildirim demek.
///  2. Yanlışlıkla basılan kutu geri alınabilmeli. Yazılmış bir başarımı
///     geri almak da mümkün ama oyuncunun profilinde iz bırakıyor.
library;

import 'package:flutter/foundation.dart';

import 'l10n.dart';
import 'library_scan.dart';
import 'prefs.dart';
import 'worker_link.dart';

/// Bir başarımın ekrandaki hâli.
class AchievementRow {
  AchievementRow({
    required this.def,
    required this.unlocked,
  }) : pending = unlocked;

  final WorkerAchievement def;

  /// Steam'deki GERÇEK durum (son okumada).
  bool unlocked;

  /// Oyuncunun istediği durum. `pending != unlocked` ise bekleyen değişiklik.
  bool pending;

  bool get changed => pending != unlocked;
}

enum LoadState { idle, busy, ready, failed }

class AppState extends ChangeNotifier {
  final Prefs prefs = Prefs.load();
  S get s => S(prefs.lang);

  /// Dil değişince açık oyunun başlıkları yeni dille yeniden okunur.
  void setLang(String lang) {
    if (prefs.lang == lang) return;
    prefs.lang = lang;
    prefs.save();
    final g = selected;
    notifyListeners();
    if (g != null) {
      selected = null; // select() erken dönmesin
      select(g);
    }
  }

  void setQuery(String q) {
    query = q;
    notifyListeners();
  }

  void setShowAll(bool v) {
    showAll = v;
    notifyListeners();
  }

  void setAchQuery(String q) {
    achQuery = q;
    notifyListeners();
  }

  void setOnlyLocked(bool v) {
    onlyLocked = v;
    notifyListeners();
  }

  void setShowHidden(bool v) {
    showHidden = v;
    notifyListeners();
  }

  void markIntroSeen() {
    prefs.introSeen = true;
    prefs.save();
  }

  String errorText(WorkerError e) {
    final key = switch (e.code) {
      '' => null,
      'worker_missing' || 'steam_no_response' || 'worker_died' => e.code,
      final c => 'err_$c',
    };
    if (key != null) {
      final txt = s.t(key);
      if (txt != key) return txt;
    }
    return e.message;
  }

  // ── Kütüphane ────────────────────────────────────────────────────────────
  LoadState libraryState = LoadState.idle;
  String? steamPath;
  List<GameEntry> games = const [];
  String query = '';

  /// Kurulu olmayanları da göster.
  bool showAll = true;

  List<GameEntry> get visibleGames {
    final q = query.trim().toLowerCase();
    return [
      for (final g in games)
        if ((showAll || g.installed) && (q.isEmpty || g.searchKey.contains(q)))
          g,
    ];
  }

  // ── Seçili oyun ──────────────────────────────────────────────────────────
  GameEntry? selected;
  LoadState gameState = LoadState.idle;
  String? gameError;
  List<AchievementRow> rows = const [];
  WorkerLink? _link;

  /// Yalnız kilitli olanları göster.
  bool onlyLocked = false;

  /// Gizli başarımları göster.
  bool showHidden = true;

  String achQuery = '';

  List<AchievementRow> get visibleRows {
    final q = achQuery.trim().toLowerCase();
    return [
      for (final r in rows)
        if ((!onlyLocked || !r.pending) &&
            (showHidden || !r.def.hidden) &&
            (q.isEmpty ||
                r.def.title.toLowerCase().contains(q) ||
                r.def.api.toLowerCase().contains(q)))
          r,
    ];
  }

  int get pendingCount => rows.where((r) => r.changed).length;
  int get unlockedCount => rows.where((r) => r.pending).length;

  // ── Kütüphaneyi yükle ────────────────────────────────────────────────────
  Future<void> loadLibrary() async {
    libraryState = LoadState.busy;
    notifyListeners();
    final scan = await scanLibrary();
    steamPath = scan.steamPath;
    games = scan.games;
    libraryState = scan.steamPath == null ? LoadState.failed : LoadState.ready;
    notifyListeners();
  }

  // ── Oyun seç ─────────────────────────────────────────────────────────────
  Future<void> select(GameEntry g) async {
    if (selected?.appId == g.appId && gameState == LoadState.ready) return;
    _closeLink();
    selected = g;
    gameState = LoadState.busy;
    gameError = null;
    applyResult = null;
    rows = const [];
    achQuery = '';
    notifyListeners();

    try {
      // Her oyun için YENİ bir süreç: `steamclient.dll` uygulama kimliğini
      // ilk boruda kilitliyor ve aynı süreçte başka oyuna geçilemiyor
      // (gerekçe `bin/trophy_worker.dart`).
      final link = await WorkerLink.start(g.appId, lang: s.steamLang);
      // Seçim bu arada değiştiyse bu yanıt bayat: yeni işçiyi kapat, ekrana
      // dokunma. Hızlı tıklayan biri yoksa hiç olmuyor ama olduğunda yanlış
      // oyunun başarımları görünürdü.
      if (selected?.appId != g.appId) {
        link.close();
        return;
      }
      _link = link;
      rows = [
        for (final a in link.achievements)
          AchievementRow(def: a, unlocked: a.unlocked),
      ];
      gameState = LoadState.ready;
    } on WorkerError catch (e) {
      gameState = LoadState.failed;
      gameError = errorText(e);
    } catch (e) {
      gameState = LoadState.failed;
      gameError = '$e';
    }
    notifyListeners();
  }

  /// Alanları doğrudan değiştiren arayüz parçaları için: yeniden çizim
  /// isteği. Her süzgeç için ayrı bir kurucu yazmak yerine tek kapı.
  void bump() => notifyListeners();

  void toggle(AchievementRow r, bool value) {
    r.pending = value;
    notifyListeners();
  }

  void setAllVisible(bool value) {
    for (final r in visibleRows) {
      r.pending = value;
    }
    notifyListeners();
  }

  void invertVisible() {
    for (final r in visibleRows) {
      r.pending = !r.pending;
    }
    notifyListeners();
  }

  /// Bekleyenleri geri alır.
  void revert() {
    for (final r in rows) {
      r.pending = r.unlocked;
    }
    notifyListeners();
  }

  // ── Uygula ───────────────────────────────────────────────────────────────
  bool applying = false;
  String? applyResult;

  Future<void> apply() async {
    final link = _link;
    if (link == null || applying) return;
    final degisen = rows.where((r) => r.changed).toList();
    if (degisen.isEmpty) return;

    applying = true;
    applyResult = null;
    notifyListeners();

    try {
      final r = await link.apply({
        for (final row in degisen) row.def.api: row.pending,
      });
      // Gerçek durumu işçiden GERİ OKU. "Yazdım" demek yetmez; ekranda
      // görünen, Steam'in kabul ettiği olmalı.
      for (final row in rows) {
        final s = r.states[row.def.api];
        if (s != null) row.unlocked = s;
        row.pending = row.unlocked;
      }
      applyResult = r.stored
          ? '${s.t('applied', {'n': '${r.applied}'})}'
              '${r.failed > 0 ? s.t('applied_failed', {'n': '${r.failed}'}) : ""}'
          : s.t('store_refused');
    } on WorkerError catch (e) {
      applyResult = errorText(e);
    } catch (e) {
      applyResult = '$e';
    }
    applying = false;
    notifyListeners();
  }

  void _closeLink() {
    _link?.close();
    _link = null;
  }

  @override
  void dispose() {
    _closeLink();
    super.dispose();
  }
}
