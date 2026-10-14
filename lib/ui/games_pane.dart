/// **Oyun listesi** — sol sütun.
///
/// Arama en üstte ve açılışta odaklı. Kurulu oyunlar başta ve bir noktayla
/// işaretli: oyuncunun aradığı oyun neredeyse her zaman kurulu olan.
library;

import 'dart:io';

import 'package:flutter/material.dart';

import '../app_state.dart';
import '../library_scan.dart';
import 'theme.dart';

class GamesPane extends StatefulWidget {
  const GamesPane({super.key, required this.state, required this.searchFocus});
  final AppState state;
  final FocusNode searchFocus;

  @override
  State<GamesPane> createState() => _GamesPaneState();
}

class _GamesPaneState extends State<GamesPane> {
  final _ctrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => widget.searchFocus.requestFocus());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.state;
    final t = s.s;
    final list = s.visibleGames;

    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
        child: TextField(
          controller: _ctrl,
          focusNode: widget.searchFocus,
          decoration: InputDecoration(
            hintText: t.t('search_games'),
            prefixIcon: const Icon(Icons.search_rounded, size: 20),
            suffixIcon: _ctrl.text.isEmpty
                ? null
                : IconButton(
                    icon: const Icon(Icons.close_rounded, size: 18),
                    onPressed: () {
                      _ctrl.clear();
                      setState(() => s.setQuery(''));
                    }),
          ),
          onChanged: (v) => setState(() => s.setQuery(v)),
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(children: [
          Text(t.t('games_count', {'n': '${list.length}'}),
              style: const TextStyle(color: TrophyColors.tx3, fontSize: 12)),
          const Spacer(),
          _Chip(
            label: t.t('only_installed'),
            active: !s.showAll,
            onTap: () => s.setShowAll(!s.showAll),
          ),
        ]),
      ),
      const SizedBox(height: 8),
      Expanded(child: _body(s, list)),
    ]);
  }

  Widget _body(AppState s, List<GameEntry> list) {
    final t = s.s;
    if (s.libraryState == LoadState.busy) {
      return const Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5)));
    }
    if (s.libraryState == LoadState.failed) {
      return _Empty(icon: Icons.link_off_rounded, title: t.t('steam_missing'), detail: t.t('steam_missing_msg'));
    }
    if (list.isEmpty) {
      return s.query.isNotEmpty
          ? _Empty(icon: Icons.search_off_rounded, title: t.t('no_match'), detail: t.t('no_match_msg'))
          : _Empty(icon: Icons.sports_esports_outlined, title: t.t('no_games'), detail: t.t('no_games_msg'));
    }
    return Scrollbar(
      child: ListView.builder(
        itemExtent: 68,
        itemCount: list.length,
        padding: const EdgeInsets.only(bottom: 10),
        itemBuilder: (context, i) {
          final g = list[i];
          return _GameTile(
            game: g,
            selected: s.selected?.appId == g.appId,
            onTap: () => s.select(g),
          );
        },
      ),
    );
  }
}

class _GameTile extends StatefulWidget {
  const _GameTile({required this.game, required this.selected, required this.onTap});
  final GameEntry game;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_GameTile> createState() => _GameTileState();
}

class _GameTileState extends State<_GameTile> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final g = widget.game;
    final sel = widget.selected;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          margin: const EdgeInsets.fromLTRB(10, 2, 10, 2),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: sel ? TrophyColors.cardHover : (_hover ? TrophyColors.card : Colors.transparent),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: sel ? TrophyColors.gold.withValues(alpha: 0.55) : Colors.transparent),
          ),
          child: Row(children: [
            Cover(game: g, width: 38, height: 52),
            const SizedBox(width: 12),
            Expanded(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(g.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: sel ? FontWeight.w600 : FontWeight.w500,
                        color: sel ? TrophyColors.tx : TrophyColors.tx.withValues(alpha: 0.88))),
                const SizedBox(height: 3),
                Row(children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: g.installed ? TrophyColors.accent : TrophyColors.tx3.withValues(alpha: 0.55),
                    ),
                  ),
                  const SizedBox(width: 7),
                  Text('${g.appId}', style: const TextStyle(fontSize: 11, color: TrophyColors.tx3)),
                ]),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}

/// Oyun kapağı: önce Steam'in yerel önbelleği, yoksa Steam CDN'i, o da
/// olmazsa baş harf.
class Cover extends StatelessWidget {
  const Cover({super.key, required this.game, required this.width, required this.height, this.radius = 7});
  final GameEntry game;
  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final letter = game.name.trim().isEmpty ? '?' : game.name.trim().characters.first.toUpperCase();
    Widget fallback() => Container(
          width: width,
          height: height,
          alignment: Alignment.center,
          color: TrophyColors.card,
          child: Text(letter,
              style: TextStyle(fontSize: width * 0.4, fontWeight: FontWeight.w700, color: TrophyColors.tx3)),
        );
    Widget net() => Image.network(
          'https://cdn.cloudflare.steamstatic.com/steam/apps/${game.appId}/library_600x900.jpg',
          fit: BoxFit.cover,
          width: width,
          height: height,
          cacheWidth: (width * 2.5).round(),
          errorBuilder: (_, _, _) => fallback(),
          loadingBuilder: (_, child, p) => p == null ? child : fallback(),
        );
    final path = game.cover;
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(
        width: width,
        height: height,
        child: path == null
            ? net()
            : Image.file(
                File(path),
                fit: BoxFit.cover,
                width: width,
                height: height,
                cacheWidth: (width * 2.5).round(),
                filterQuality: FilterQuality.medium,
                errorBuilder: (_, _, _) => net(),
              ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.active, required this.onTap});
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
        decoration: BoxDecoration(
          color: active ? TrophyColors.gold.withValues(alpha: 0.14) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: active ? TrophyColors.gold : TrophyColors.line),
        ),
        child: Text(label,
            style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500, color: active ? TrophyColors.gold : TrophyColors.tx2)),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.icon, required this.title, required this.detail});
  final IconData icon;
  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: 36, color: TrophyColors.tx3),
            const SizedBox(height: 12),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text(detail, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12.5, color: TrophyColors.tx3, height: 1.5)),
          ]),
        ),
      );
}
