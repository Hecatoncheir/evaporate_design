import 'package:flutter/widgets.dart';

import '../design/theme.dart';
import '../design/tokens.dart';
import '../widgets/ev_focusable.dart';
import '../widgets/ev_icon.dart';

/// Верхняя полоса: хлебная крошка слева, поиск и живые показатели справа.
///
/// Высота 58. Полоса ничего не заливает — только отделяется линией, чтобы
/// фон окна проходил под ней непрерывно.
class EvTopBar extends StatelessWidget {
  const EvTopBar({
    super.key,
    required this.section,
    this.onSearch,
    this.trailing = const [],
  });

  /// Текущий раздел — вторая часть крошки.
  final String section;

  final VoidCallback? onSearch;

  /// Показатели: скорость, состояние движка.
  final List<Widget> trailing;

  @override
  Widget build(BuildContext context) {
    final ev = context.ev;
    final c = ev.colors;
    final gutter = EvSpace.gutterFor(MediaQuery.sizeOf(context));
    return Container(
      height: EvSpace.topBarHeight,
      padding: EdgeInsets.symmetric(horizontal: gutter),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: c.lineSoft)),
      ),
      child: Row(
        children: [
          Text(
            'EVAPORATE',
            style: ev.text.section.copyWith(fontSize: 12, letterSpacing: 1.9),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 9),
            child: Text('/', style: ev.text.bodySmall.copyWith(color: c.ink4)),
          ),
          // Крошка забирает всё свободное место, поэтому поиск и показатели
          // прижаты к правому полю. Flexible рядом со Spacer получил бы
          // половину места и не отдал неиспользованное — правая группа
          // не доезжала бы до края.
          Expanded(
            child: AnimatedSwitcher(
              duration: EvMotion.fast,
              // старая и новая подписи разной длины: обе прижаты влево,
              // иначе короткая на миг съезжает к середине длинной
              layoutBuilder: (current, previous) => Stack(
                alignment: Alignment.centerLeft,
                children: [...previous, ?current],
              ),
              child: Text(
                section,
                key: ValueKey(section),
                overflow: TextOverflow.ellipsis,
                style: ev.text.bodySmall.copyWith(
                  color: c.ink2,
                  fontSize: 12.5,
                ),
              ),
            ),
          ),
          const SizedBox(width: EvSpace.l),
          _SearchButton(onTap: onSearch),
          for (final w in trailing) ...[const SizedBox(width: 10), w],
        ],
      ),
    );
  }
}

class _SearchButton extends StatefulWidget {
  const _SearchButton({this.onTap});

  final VoidCallback? onTap;

  @override
  State<_SearchButton> createState() => _SearchButtonState();
}

class _SearchButtonState extends State<_SearchButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final ev = context.ev;
    final c = ev.colors;
    final ink = _hover ? c.ink2 : c.ink3;
    return Semantics(
      button: true,
      label: 'Поиск, клавиша слэш',
      child: MouseRegion(
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: EvFocusable(
          onActivate: widget.onTap,
          radius: ev.radii.r2,
          child: AnimatedContainer(
            duration: EvMotion.fast,
            height: 34,
            padding: const EdgeInsets.only(left: 11, right: 10),
            decoration: BoxDecoration(
              borderRadius: ev.radii.b2,
              border: Border.all(color: _hover ? c.ink4 : c.line),
              color: c.ink.withValues(alpha: _hover ? 0.05 : 0.02),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                EvIcon(EvIcons.search, size: 15, color: ink),
                const SizedBox(width: 9),
                Text('Поиск', style: ev.text.bodySmall.copyWith(color: ink)),
                const SizedBox(width: 9),
                EvKey('/', dense: true),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Клавиша: моноширинная подпись в рамке. Общая для топбара и строки
/// подсказок, чтобы клавиши выглядели одинаково везде.
class EvKey extends StatelessWidget {
  const EvKey(this.label, {super.key, this.dense = false});

  final String label;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final ev = context.ev;
    final c = ev.colors;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: dense ? 5 : 6, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: ev.radii.b1,
        color: c.ink.withValues(alpha: dense ? 0.07 : 0.06),
        border: Border.all(color: c.line),
      ),
      child: Text(
        label,
        style: ev.text.data.copyWith(
          color: c.ink3,
          fontSize: 10.5,
          height: 1.2,
        ),
      ),
    );
  }
}
