/// **Trophy Room** — Steam başarım yöneticisi.
///
/// ## Tasarım kararları
///
/// **İki sütun.** Oyun seçmek ve başarımlara bakmak tek pencerede: oyun
/// değiştirmek tek tık.
///
/// **Arama her zaman açık** (`Ctrl+F`). Üç yüz oyunda kaydırmak yerine yazmak.
///
/// **Değişiklikler biriktirilir.** Kutuya basmak Steam'e hemen yazmaz; altta
/// "N değişiklik · Uygula" çubuğu belirir (`Ctrl+S` ile de uygulanır).
/// Gerekçe `app_state.dart` başlığında.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:window_manager/window_manager.dart';

import 'app_state.dart';
import 'ui/achievements_pane.dart';
import 'ui/games_pane.dart';
import 'ui/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  await windowManager.waitUntilReadyToShow(
    const WindowOptions(
      size: Size(1200, 780),
      minimumSize: Size(980, 620),
      center: true,
      titleBarStyle: TitleBarStyle.hidden,
      backgroundColor: TrophyColors.bg,
      title: 'Trophy Room',
    ),
    () async {
      await windowManager.show();
      await windowManager.focus();
    },
  );
  runApp(const TrophyRoomApp());
}

class TrophyRoomApp extends StatefulWidget {
  const TrophyRoomApp({super.key});

  @override
  State<TrophyRoomApp> createState() => _TrophyRoomAppState();
}

class _TrophyRoomAppState extends State<TrophyRoomApp> {
  final AppState _state = AppState();

  @override
  void initState() {
    super.initState();
    _state.loadLibrary();
  }

  @override
  void dispose() {
    _state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trophy Room',
      debugShowCheckedModeBanner: false,
      theme: trophyTheme(),
      home: Shell(state: _state),
    );
  }
}

class Shell extends StatefulWidget {
  const Shell({super.key, required this.state});
  final AppState state;

  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  final _searchFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeIntro());
  }

  @override
  void dispose() {
    _searchFocus.dispose();
    super.dispose();
  }

  Future<void> _maybeIntro() async {
    final st = widget.state;
    if (st.prefs.introSeen || !mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Row(children: [
          const Icon(Icons.emoji_events_rounded, color: TrophyColors.gold),
          const SizedBox(width: 10),
          Text(st.s.t('intro_title'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        ]),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Text(st.s.t('intro_body'),
              style: const TextStyle(color: TrophyColors.tx2, height: 1.55, fontSize: 14)),
        ),
        actions: [
          FilledButton(onPressed: () => Navigator.pop(ctx), child: Text(st.s.t('intro_ok'))),
        ],
      ),
    );
    st.markIntroSeen();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    return AnimatedBuilder(
      animation: state,
      builder: (context, _) => CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.keyF, control: true): _searchFocus.requestFocus,
          const SingleActivator(LogicalKeyboardKey.keyS, control: true): () {
            if (state.pendingCount > 0 && !state.applying) state.apply();
          },
        },
        child: Focus(
          autofocus: true,
          child: Scaffold(
            body: Column(children: [
              _TitleBar(state: state),
              const Divider(height: 1, color: TrophyColors.line),
              Expanded(
                child: Row(children: [
                  SizedBox(width: 340, child: GamesPane(state: state, searchFocus: _searchFocus)),
                  const VerticalDivider(width: 1, color: TrophyColors.line),
                  Expanded(child: AchievementsPane(state: state)),
                ]),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

class _TitleBar extends StatelessWidget {
  const _TitleBar({required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    final s = state;
    final t = s.s;
    return Container(
      height: 52,
      color: TrophyColors.bar,
      child: Row(children: [
        Expanded(
          child: DragToMoveArea(
            child: Padding(
              padding: const EdgeInsets.only(left: 18),
              child: Row(children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFFF5B83D), Color(0xFFE8892B)]),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: const Icon(Icons.emoji_events_rounded, size: 18, color: Colors.black87),
                ),
                const SizedBox(width: 12),
                const Text('Trophy Room', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                const SizedBox(width: 12),
                Text(t.t('subtitle'), style: const TextStyle(color: TrophyColors.tx3, fontSize: 12.5)),
              ]),
            ),
          ),
        ),
        if (s.libraryState == LoadState.ready)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Text(t.t('games_count', {'n': '${s.games.length}'}),
                style: const TextStyle(color: TrophyColors.tx2, fontSize: 12.5)),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: SegmentedButton<String>(
            showSelectedIcon: false,
            style: ButtonStyle(
              visualDensity: VisualDensity.compact,
              side: const WidgetStatePropertyAll(BorderSide(color: TrophyColors.line)),
              backgroundColor: WidgetStateProperty.resolveWith((st) =>
                  st.contains(WidgetState.selected) ? TrophyColors.gold.withValues(alpha: 0.16) : Colors.transparent),
              foregroundColor: WidgetStateProperty.resolveWith(
                  (st) => st.contains(WidgetState.selected) ? TrophyColors.gold : TrophyColors.tx2),
              textStyle: const WidgetStatePropertyAll(
                  TextStyle(fontFamily: kFont, fontWeight: FontWeight.w600, fontSize: 12)),
            ),
            segments: const [ButtonSegment(value: 'tr', label: Text('TR')), ButtonSegment(value: 'en', label: Text('EN'))],
            selected: {s.prefs.lang},
            onSelectionChanged: (v) => s.setLang(v.first),
          ),
        ),
        IconButton(
          tooltip: t.t('refresh'),
          icon: const Icon(Icons.refresh_rounded, size: 20),
          onPressed: s.libraryState == LoadState.busy ? null : s.loadLibrary,
        ),
        const SizedBox(width: 6),
        _WinBtn(Icons.remove_rounded, () => windowManager.minimize()),
        _WinBtn(Icons.crop_square_rounded, () async {
          (await windowManager.isMaximized()) ? windowManager.unmaximize() : windowManager.maximize();
        }, size: 15),
        _WinBtn(Icons.close_rounded, () => windowManager.close(), danger: true),
      ]),
    );
  }
}

class _WinBtn extends StatefulWidget {
  const _WinBtn(this.icon, this.onTap, {this.danger = false, this.size = 18});
  final IconData icon;
  final VoidCallback onTap;
  final bool danger;
  final double size;
  @override
  State<_WinBtn> createState() => _WinBtnState();
}

class _WinBtnState extends State<_WinBtn> {
  bool _h = false;
  @override
  Widget build(BuildContext context) => MouseRegion(
        onEnter: (_) => setState(() => _h = true),
        onExit: (_) => setState(() => _h = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: Container(
            width: 48,
            height: 52,
            color: _h ? (widget.danger ? TrophyColors.danger : TrophyColors.cardHover) : Colors.transparent,
            child: Icon(widget.icon, size: widget.size, color: TrophyColors.tx),
          ),
        ),
      );
}
