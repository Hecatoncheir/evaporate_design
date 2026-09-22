import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../design/theme.dart';
import '../design/tokens.dart';
import '../widgets/ev_focusable.dart';
import '../widgets/ev_icon.dart';
import 'ev_section.dart';

/// Боковой рейл: знак, четыре основных раздела, друзья и аватар.
///
/// Ширина 76. Активный раздел отмечен янтарной чертой у самой кромки окна и
/// тёплым пятном внутри кнопки — не заливкой: насыщенный объект на экране
/// один, и это не навигация.
class EvRail extends StatelessWidget {
  const EvRail({
    super.key,
    required this.current,
    required this.onSelect,
    required this.initials,
    required this.userName,
    this.friendsOnline,
    this.downloadsActive,
  });

  final EvSection current;
  final ValueChanged<EvSection> onSelect;
  final String initials;
  final String userName;

  /// Числа в подсказках. `null` — подсказка без числа: рейл не выдумывает
  /// показатели, которых ему не передали.
  final int? friendsOnline;
  final int? downloadsActive;

  String _tip(EvSection s) => switch (s) {
    EvSection.downloads when downloadsActive != null =>
      '${s.label} · $downloadsActive',
    EvSection.friends when friendsOnline != null =>
      '${s.label} · $friendsOnline в сети',
    _ => s.label,
  };

  @override
  Widget build(BuildContext context) {
    final ev = context.ev;
    final c = ev.colors;
    return Container(
      width: EvSpace.railWidth,
      padding: const EdgeInsets.only(top: 18, bottom: 14),
      decoration: BoxDecoration(
        border: Border(right: BorderSide(color: c.lineSoft)),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0, 0.4],
          colors: [c.ink.withValues(alpha: 0.022), c.ink.withValues(alpha: 0)],
        ),
      ),
      child: Column(
        children: [
          DecoratedBox(
            // свечение повторяет плитку знака: rx 14 на сетке 48
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(36 * 14 / 48),
              boxShadow: [
                BoxShadow(
                  color: c.hot1.withValues(alpha: 0.35),
                  blurRadius: 18,
                ),
              ],
            ),
            child: const EvMark(size: 36),
          ),
          const SizedBox(height: EvSpace.l),
          for (final s in EvSection.primary) ...[
            EvRailItem(
              section: s,
              tooltip: _tip(s),
              active: s == current,
              onTap: () => onSelect(s),
            ),
            const SizedBox(height: EvSpace.xs),
          ],
          const Spacer(),
          EvRailItem(
            section: EvSection.friends,
            tooltip: _tip(EvSection.friends),
            active: current == EvSection.friends,
            onTap: () => onSelect(EvSection.friends),
          ),
          const SizedBox(height: EvSpace.s),
          EvAvatar(
            initials: initials,
            label: 'Профиль · $userName',
            active: current == EvSection.profile,
            onTap: () => onSelect(EvSection.profile),
          ),
        ],
      ),
    );
  }
}

/// Кнопка рейла 48 × 44 внутри полосы шириной 76: черта активного раздела
/// живёт снаружи кнопки, у кромки окна.
class EvRailItem extends StatefulWidget {
  const EvRailItem({
    super.key,
    required this.section,
    required this.tooltip,
    required this.active,
    required this.onTap,
  });

  final EvSection section;
  final String tooltip;
  final bool active;
  final VoidCallback onTap;

  @override
  State<EvRailItem> createState() => _EvRailItemState();
}

class _EvRailItemState extends State<EvRailItem> {
  bool _hover = false;
  bool _focus = false;

  @override
  Widget build(BuildContext context) {
    final ev = context.ev;
    final c = ev.colors;
    final lit = widget.active || _hover || _focus;
    return SizedBox(
      width: EvSpace.railWidth,
      height: 44,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // черта у кромки
          Positioned(
            left: 0,
            child: AnimatedContainer(
              duration: EvMotion.fast,
              curve: EvMotion.ease,
              width: 3,
              height: widget.active ? 22 : 0,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.horizontal(
                  right: Radius.circular(3),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [c.hot2, c.hot1],
                ),
                boxShadow: [
                  BoxShadow(
                    color: c.hot1.withValues(alpha: 0.9),
                    blurRadius: 12,
                  ),
                ],
              ),
            ),
          ),
          Semantics(
            button: true,
            selected: widget.active,
            label: widget.section.label,
            child: _SideTooltip(
              message: widget.tooltip,
              visible: _hover || _focus,
              child: MouseRegion(
                onEnter: (_) => setState(() => _hover = true),
                onExit: (_) => setState(() => _hover = false),
                child: EvFocusable(
                  onActivate: widget.onTap,
                  radius: ev.radii.r2,
                  onFocusHighlight: (v) => setState(() => _focus = v),
                  child: AnimatedContainer(
                    duration: EvMotion.fast,
                    curve: EvMotion.ease,
                    width: 48,
                    height: 44,
                    decoration: BoxDecoration(
                      borderRadius: ev.radii.b2,
                      color: _hover && !widget.active
                          ? c.ink.withValues(alpha: 0.045)
                          : null,
                      gradient: widget.active
                          ? RadialGradient(
                              center: const Alignment(-1, 0),
                              radius: 1.1,
                              colors: [
                                c.hot1.withValues(alpha: 0.2),
                                c.hot1.withValues(alpha: 0),
                              ],
                            )
                          : null,
                    ),
                    child: Center(
                      child: EvIcon(
                        widget.section.icon,
                        size: 21,
                        color: lit ? c.ink : c.ink3,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Аватар пользователя. Скругление берётся из потолка радиуса, но не больше
/// половины стороны — при полном радиусе это круг, при 8 px — плитка.
class EvAvatar extends StatefulWidget {
  const EvAvatar({
    super.key,
    required this.initials,
    required this.label,
    required this.active,
    required this.onTap,
    this.size = 38,
    this.showTooltip = true,
  });

  final String initials;

  /// Подпись для чтения с экрана и текст подсказки.
  final String label;

  final bool active;
  final VoidCallback onTap;
  final double size;

  /// В нижней панели узкого окна подсказке некуда выйти — там её нет.
  final bool showTooltip;

  @override
  State<EvAvatar> createState() => _EvAvatarState();
}

class _EvAvatarState extends State<EvAvatar> {
  bool _hover = false;
  bool _focus = false;

  @override
  Widget build(BuildContext context) {
    final ev = context.ev;
    final c = ev.colors;
    final r = math.min(ev.radii.pill, widget.size / 2);
    Widget avatar = MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: EvFocusable(
        onActivate: widget.onTap,
        radius: r,
        onFocusHighlight: (v) => setState(() => _focus = v),
        child: AnimatedContainer(
          duration: EvMotion.fast,
          width: widget.size,
          height: widget.size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(r),
            gradient: SweepGradient(
              startAngle: 200 * math.pi / 180,
              endAngle: (200 + 360) * math.pi / 180,
              colors: [c.hot2, c.hot1, c.arc, c.hot2],
            ),
            border: Border.all(
              color: widget.active
                  ? c.hot2
                  : c.ink.withValues(alpha: _hover ? 0.32 : 0.14),
              width: widget.active ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: c.hot1.withValues(alpha: widget.active ? 0.55 : 0.35),
                blurRadius: widget.active ? 22 : 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ExcludeSemantics(
            child: Text(
              widget.initials,
              style: ev.text.dsp(
                ev.text.big(widget.size * 0.34),
                weight: FontWeight.w600,
                color: const Color(0xFF0B0B10),
                letterSpacing: 0,
              ),
            ),
          ),
        ),
      ),
    );
    if (widget.showTooltip) {
      avatar = _SideTooltip(
        message: widget.label,
        visible: _hover || _focus,
        child: avatar,
      );
    }
    return Semantics(
      button: true,
      selected: widget.active,
      label: widget.label,
      child: avatar,
    );
  }
}

/// Подсказка справа от кнопки. Штатный Tooltip умеет только сверху и снизу,
/// а у бокового рейла подсказка должна выходить в сторону контента.
///
/// Слой подсказки подключён всё время, а видимость — это прозрачность:
/// так подсказка и появляется, и гаснет плавно (180 мс, как в прототипе),
/// а контроллер слоя не приходится дёргать посреди сборки.
class _SideTooltip extends StatefulWidget {
  const _SideTooltip({
    required this.message,
    required this.visible,
    required this.child,
  });

  final String message;
  final bool visible;
  final Widget child;

  @override
  State<_SideTooltip> createState() => _SideTooltipState();
}

class _SideTooltipState extends State<_SideTooltip> {
  final _link = LayerLink();
  final _portal = OverlayPortalController();

  @override
  void initState() {
    super.initState();
    // Портал ещё не подключён: вызов только запоминает, что слой нужен.
    _portal.show();
  }

  @override
  Widget build(BuildContext context) {
    final ev = context.ev;
    final c = ev.colors;
    return CompositedTransformTarget(
      link: _link,
      child: OverlayPortal(
        controller: _portal,
        overlayChildBuilder: (context) => Positioned(
          left: 0,
          top: 0,
          child: CompositedTransformFollower(
            link: _link,
            showWhenUnlinked: false,
            targetAnchor: Alignment.centerRight,
            followerAnchor: Alignment.centerLeft,
            offset: const Offset(10, 0),
            child: IgnorePointer(
              child: ExcludeSemantics(
                child: AnimatedOpacity(
                  opacity: widget.visible ? 1 : 0,
                  duration: const Duration(milliseconds: 180),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: c.raised,
                      borderRadius: ev.radii.b1,
                      border: Border.all(color: c.line),
                      boxShadow: ev.shadowRest,
                    ),
                    child: Text(
                      widget.message,
                      style: ev.text.bodySmall.copyWith(
                        color: c.ink2,
                        fontSize: 12,
                        height: 1.2,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        child: widget.child,
      ),
    );
  }
}

/// Нижняя панель навигации для узких окон: рейл превращается в строку,
/// черта активного раздела уходит под иконку.
class EvBottomNav extends StatelessWidget {
  const EvBottomNav({
    super.key,
    required this.current,
    required this.onSelect,
    required this.initials,
  });

  final EvSection current;
  final ValueChanged<EvSection> onSelect;
  final String initials;

  @override
  Widget build(BuildContext context) {
    final ev = context.ev;
    final c = ev.colors;
    return Container(
      height: EvSpace.bottomNavHeight,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: c.ground,
        border: Border(top: BorderSide(color: c.line)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          for (final s in [...EvSection.primary, EvSection.friends])
            Semantics(
              button: true,
              selected: s == current,
              label: s.label,
              child: EvFocusable(
                onActivate: () => onSelect(s),
                radius: ev.radii.r2,
                child: SizedBox(
                  width: 48,
                  height: EvSpace.bottomNavHeight,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      EvIcon(
                        s.icon,
                        size: 21,
                        color: s == current ? c.ink : c.ink3,
                      ),
                      Positioned(
                        bottom: 0,
                        child: AnimatedContainer(
                          duration: EvMotion.fast,
                          width: s == current ? 20 : 0,
                          height: 2,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(2),
                            ),
                            color: c.hot1,
                            boxShadow: [
                              BoxShadow(color: c.hot1, blurRadius: 10),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          EvAvatar(
            initials: initials,
            label: 'Профиль',
            active: current == EvSection.profile,
            onTap: () => onSelect(EvSection.profile),
            size: 32,
            showTooltip: false,
          ),
        ],
      ),
    );
  }
}
