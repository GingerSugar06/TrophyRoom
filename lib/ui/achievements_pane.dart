/// **Başarım listesi** — sağ sütun.
///
/// Kutuya basmak Steam'e hemen yazmaz (gerekçe `app_state.dart`); değişiklik
/// biriktikçe altta bir çubuk belirir: kaç değişiklik var, geri al, uygula.
/// Durumu renk değil AÇIKLIK anlatır: kilitli satırlar soluk, açık satırlar
/// tam opak ve zümrüt işaretli, bekleyenler altın çerçeveli.
library;

import 'package:flutter/material.dart';

import '../app_state.dart';
import 'games_pane.dart' show Cover;
import 'theme.dart';

class AchievementsPane extends StatelessWidget {
  const AchievementsPane({super.key, required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    final s = state;
    final t = s.s;
    if (s.selected == null) return _Welcome(state: s);
    if (s.gameState == LoadState.busy) {
      return const Center(child: SizedBox(width: 26, height: 26, child: CircularProgressIndicator(strokeWidth: 2.5)));
    }
    if (s.gameState == LoadState.failed) {
      return _Center(
        icon: Icons.error_outline_rounded,
        title: t.t('failed_open'),
        detail: s.gameError ?? t.t('unknown_error'),
      );
    }

    final rows = s.visibleRows;
    return Column(children: [
      _Header(state: s),
      const Divider(height: 1, color: TrophyColors.line),
      Expanded(
        child: rows.isEmpty
            ? _Center(
                icon: Icons.filter_alt_off_outlined,
                title: t.t('no_filter_match'),
                detail: t.t('no_filter_match_msg'))
            : Scrollbar(
                child: ListView.builder(
                  itemExtent: 70,
                  itemCount: rows.length,
                  padding: const EdgeInsets.only(bottom: 12),
                  itemBuilder: (context, i) => _Row(state: s, row: rows[i]),
                ),
              ),
      ),
      if (s.pendingCount > 0 || s.applyResult != null) _ApplyBar(state: s),
    ]);
  }
}

class _Welcome extends StatelessWidget {
  const _Welcome({required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    final t = state.s;
    final steps = [
      (Icons.sports_esports_rounded, t.t('step1'), t.t('step1_d')),
      (Icons.checklist_rounded, t.t('step2'), t.t('step2_d')),
      (Icons.save_rounded, t.t('step3'), t.t('step3_d')),
    ];
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [TrophyColors.gold.withValues(alpha: 0.25), TrophyColors.gold.withValues(alpha: 0.05)]),
                shape: BoxShape.circle,
                border: Border.all(color: TrophyColors.gold.withValues(alpha: 0.4)),
              ),
              child: const Icon(Icons.emoji_events_rounded, size: 42, color: TrophyColors.gold),
            ),
            const SizedBox(height: 20),
            Text(t.t('pick_game'), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(t.t('pick_game_msg'),
                textAlign: TextAlign.center,
                style: const TextStyle(color: TrophyColors.tx2, fontSize: 13.5, height: 1.55)),
            const SizedBox(height: 26),
            Row(children: [
              for (final (i, (icon, title, desc)) in steps.indexed) ...[
                if (i > 0) const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: TrophyColors.card,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: TrophyColors.line),
                    ),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Icon(icon, size: 22, color: TrophyColors.gold),
                      const SizedBox(height: 10),
                      Text('${i + 1}. $title', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      const SizedBox(height: 3),
                      Text(desc, style: const TextStyle(color: TrophyColors.tx3, fontSize: 11.5, height: 1.4)),
                    ]),
                  ),
                ),
              ],
            ]),
          ]),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    final s = state;
    final t = s.s;
    final g = s.selected!;
    final total = s.rows.length;
    final done = s.unlockedCount;
    final ratio = total == 0 ? 0.0 : done / total;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      color: TrophyColors.bar,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Cover(game: g, width: 46, height: 62, radius: 9),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(g.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Row(children: [
                Text(t.t('unlocked_of', {'a': '$done', 'b': '$total'}),
                    style: const TextStyle(color: TrophyColors.accent, fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(width: 10),
                Text('${(ratio * 100).round()}%', style: const TextStyle(color: TrophyColors.tx3, fontSize: 12.5)),
              ]),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(end: ratio),
                  duration: const Duration(milliseconds: 400),
                  builder: (_, v, _) => LinearProgressIndicator(
                    value: v,
                    minHeight: 6,
                    color: TrophyColors.accent,
                    backgroundColor: TrophyColors.line,
                  ),
                ),
              ),
            ]),
          ),
        ]),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(
            child: SizedBox(
              height: 38,
              child: TextField(
                decoration: InputDecoration(hintText: t.t('search_ach'), prefixIcon: const Icon(Icons.search_rounded, size: 19)),
                onChanged: s.setAchQuery,
              ),
            ),
          ),
          const SizedBox(width: 10),
          _Toggle(label: t.t('only_locked'), active: s.onlyLocked, onTap: () => s.setOnlyLocked(!s.onlyLocked)),
          const SizedBox(width: 6),
          _Toggle(label: t.t('hidden'), active: s.showHidden, onTap: () => s.setShowHidden(!s.showHidden)),
          const SizedBox(width: 8),
          _Small(icon: Icons.done_all_rounded, tip: t.t('unlock_visible'), onTap: () => s.setAllVisible(true)),
          _Small(icon: Icons.remove_done_rounded, tip: t.t('lock_visible'), onTap: () => s.setAllVisible(false)),
          _Small(icon: Icons.swap_horiz_rounded, tip: t.t('invert_visible'), onTap: s.invertVisible),
        ]),
      ]),
    );
  }
}

class _Row extends StatefulWidget {
  const _Row({required this.state, required this.row});
  final AppState state;
  final AchievementRow row;

  @override
  State<_Row> createState() => _RowState();
}

class _RowState extends State<_Row> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final r = widget.row;
    final s = widget.state;
    final t = s.s;
    final on = r.pending;
    final url = r.def.iconUrl(s.selected!.appId, unlocked: on);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: () => s.toggle(r, !r.pending),
        child: Container(
          margin: const EdgeInsets.fromLTRB(14, 3, 14, 3),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: _hover ? TrophyColors.card : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: r.changed ? TrophyColors.pending.withValues(alpha: 0.6) : Colors.transparent),
          ),
          child: Row(children: [
            Opacity(
              opacity: on ? 1 : 0.55,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(9),
                child: SizedBox(
                  width: 48,
                  height: 48,
                  child: url == null
                      ? _iconFallback(on)
                      : Image.network(url, fit: BoxFit.cover, cacheWidth: 96, errorBuilder: (_, _, _) => _iconFallback(on)),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Flexible(
                    child: Text(r.def.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: on ? FontWeight.w600 : FontWeight.w500,
                          color: on ? TrophyColors.tx : TrophyColors.tx.withValues(alpha: 0.65),
                        )),
                  ),
                  if (r.def.hidden) ...[
                    const SizedBox(width: 6),
                    Tooltip(message: t.t('hidden_badge'), child: const Icon(Icons.visibility_off_outlined, size: 14, color: TrophyColors.tx3)),
                  ],
                ]),
                const SizedBox(height: 2),
                Text(r.def.desc.isEmpty ? r.def.api : r.def.desc,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11.5, color: on ? TrophyColors.tx2 : TrophyColors.tx3)),
              ]),
            ),
            if (r.changed)
              Container(
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: TrophyColors.pending.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
                child: Text(on ? t.t('will_unlock') : t.t('will_lock'),
                    style: const TextStyle(fontSize: 10.5, color: TrophyColors.pending, fontWeight: FontWeight.w600)),
              ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: on ? TrophyColors.accent : Colors.transparent,
                border: Border.all(color: on ? TrophyColors.accent : TrophyColors.tx3, width: 1.6),
              ),
              child: on ? const Icon(Icons.check_rounded, size: 17, color: Colors.black) : null,
            ),
          ]),
        ),
      ),
    );
  }

  Widget _iconFallback(bool on) => Container(
        color: TrophyColors.card,
        child: Icon(Icons.emoji_events_outlined, size: 24, color: on ? TrophyColors.gold : TrophyColors.tx3),
      );
}

class _ApplyBar extends StatelessWidget {
  const _ApplyBar({required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    final s = state;
    final t = s.s;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(color: TrophyColors.bar, border: Border(top: BorderSide(color: TrophyColors.line))),
      child: Row(children: [
        if (s.pendingCount > 0) ...[
          const Icon(Icons.pending_actions_rounded, size: 19, color: TrophyColors.pending),
          const SizedBox(width: 10),
          Text(t.t('changes_pending', {'n': '${s.pendingCount}'}),
              style: const TextStyle(fontSize: 13.5, color: TrophyColors.pending, fontWeight: FontWeight.w500)),
        ] else if (s.applyResult != null) ...[
          const Icon(Icons.check_circle_outline_rounded, size: 19, color: TrophyColors.accent),
          const SizedBox(width: 10),
          Flexible(child: Text(s.applyResult!, style: const TextStyle(fontSize: 13.5, color: TrophyColors.tx2))),
        ],
        const Spacer(),
        if (s.pendingCount > 0)
          TextButton(onPressed: s.applying ? null : s.revert, child: Text(t.t('undo'))),
        const SizedBox(width: 8),
        FilledButton.icon(
          onPressed: (s.applying || s.pendingCount == 0) ? null : s.apply,
          icon: s.applying
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
              : const Icon(Icons.save_rounded, size: 18),
          label: Text('${t.t('apply')}  ·  Ctrl+S'),
        ),
      ]),
    );
  }
}

class _Toggle extends StatelessWidget {
  const _Toggle({required this.label, required this.active, required this.onTap});
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: active ? TrophyColors.gold.withValues(alpha: 0.14) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: active ? TrophyColors.gold : TrophyColors.line),
          ),
          child: Text(label,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: active ? TrophyColors.gold : TrophyColors.tx2)),
        ),
      );
}

class _Small extends StatelessWidget {
  const _Small({required this.icon, required this.tip, required this.onTap});
  final IconData icon;
  final String tip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) =>
      IconButton(tooltip: tip, icon: Icon(icon, size: 19), onPressed: onTap, visualDensity: VisualDensity.compact);
}

class _Center extends StatelessWidget {
  const _Center({required this.icon, required this.title, required this.detail});
  final IconData icon;
  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: 40, color: TrophyColors.tx3),
            const SizedBox(height: 14),
            Text(title, style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            SizedBox(
              width: 380,
              child: Text(detail, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12.5, color: TrophyColors.tx3, height: 1.5)),
            ),
          ]),
        ),
      );
}
