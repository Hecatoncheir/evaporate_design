import 'package:flutter/widgets.dart';

import '../design/theme.dart';
import '../design/tokens.dart';
import '../glass/ev_glass.dart';

/// Панель: матовое стекло на ступень выше земли. Сквозь него видно, что
/// делает фон, но ровно настолько, чтобы текст оставался текстом.
class EvPanel extends StatelessWidget {
  const EvPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.glowCorner = false,
    this.grouped = false,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  /// Тёплое пятно в правом верхнем углу. Не больше одного на экран.
  final bool glowCorner;

  /// Панели одного слоя читают фон один раз на всех.
  final bool grouped;

  @override
  Widget build(BuildContext context) {
    final ev = context.ev;
    return EvGlass(
      borderRadius: ev.radii.b4,
      grouped: grouped,
      child: Stack(
        children: [
          if (glowCorner)
            Positioned(
              right: -90,
              top: -120,
              width: 260,
              height: 260,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      ev.colors.hot1.withValues(alpha: 0.16),
                      ev.colors.hot1.withValues(alpha: 0),
                    ],
                    stops: const [0, 0.66],
                  ),
                ),
              ),
            ),
          Padding(padding: padding, child: child),
        ],
      ),
    );
  }
}

/// Чип: короткая метка на 24 px. Лежит поверх картинки, поэтому сделан
/// из линзы — кадр под ним виден и гнётся у кромки. Горячий вариант —
/// единственный цветной, им помечают текущее состояние объекта.
class EvChip extends StatelessWidget {
  const EvChip(this.label, {super.key, this.hot = false, this.grouped = false});

  final String label;
  final bool hot;

  /// Чипы одной строки читают фон один раз на всех.
  final bool grouped;

  @override
  Widget build(BuildContext context) {
    final ev = context.ev;
    final c = ev.colors;
    return EvGlass(
      style: EvGlassStyle.lens,
      borderRadius: ev.radii.b1,
      grouped: grouped,
      tint: hot ? c.hot1.withValues(alpha: 0.16) : null,
      keyLight: hot ? c.hot2 : null,
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      child: Text(
        label,
        style: ev.text.data.copyWith(
          color: hot ? c.hot2 : c.ink2,
          fontSize: 11,
        ),
      ),
    );
  }
}

/// Состояние процесса: точка плюс подпись. Цвет точки кодирует причину,
/// а не громкость.
enum EvStatus {
  /// Всё хорошо.
  ok,

  /// Что-то идёт прямо сейчас.
  busy,

  /// Ждём внешнего.
  warn,

  /// Нужно решение человека.
  bad,

  /// Просто пауза.
  idle,
}

class EvPill extends StatelessWidget {
  const EvPill(this.label, {super.key, this.status = EvStatus.ok, this.onTap});

  final String label;
  final EvStatus status;
  final VoidCallback? onTap;

  Color _dot(EvColors c) => switch (status) {
    EvStatus.ok => EvColors.ok,
    EvStatus.busy => c.cool,
    EvStatus.warn => EvColors.warn,
    EvStatus.bad => EvColors.bad,
    EvStatus.idle => c.ink4,
  };

  @override
  Widget build(BuildContext context) {
    final ev = context.ev;
    final dot = _dot(ev.colors);
    final tinted = status == EvStatus.warn || status == EvStatus.bad;
    // Таблетки живут в полосе каркаса — под ними уже стекло, второй раз
    // читать фон незачем.
    final pill = EvGlass(
      style: EvGlassStyle.chip,
      backdrop: false,
      borderRadius: ev.radii.bPill,
      tint: tinted ? dot.withValues(alpha: 0.1) : null,
      keyLight: tinted ? dot : null,
      padding: const EdgeInsets.symmetric(horizontal: 11),
      child: SizedBox(
        height: 30,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: dot,
                boxShadow: [BoxShadow(color: dot, blurRadius: 9)],
              ),
            ),
            const SizedBox(width: 7),
            Text(
              label,
              style: ev.text.data.copyWith(
                color: tinted ? dot : ev.colors.ink2,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
    if (onTap == null) return pill;
    return GestureDetector(onTap: onTap, child: pill);
  }
}

/// Полоса прогресса. Янтарная — приём, циановая — данные и проверка.
class EvBar extends StatelessWidget {
  const EvBar(
    this.value, {
    super.key,
    this.cool = false,
    this.height = 5,
    this.muted = false,
  });

  /// 0…1
  final double value;

  /// Циановый вариант — для данных.
  final bool cool;

  final double height;

  /// Погашенная полоса: завершённое или ждущее, без свечения.
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final ev = context.ev;
    final c = ev.colors;
    final fill = muted
        ? [c.ink4.withValues(alpha: 0.5), c.ink4]
        : cool
        ? [const Color(0xFF1B6F8A), c.cool]
        : [c.hotDeep, c.hot1, c.hot2];
    final glowColor = cool ? c.cool : c.hot1;
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: Stack(
        children: [
          Container(height: height, color: c.ink.withValues(alpha: 0.055)),
          FractionallySizedBox(
            widthFactor: value.clamp(0.0, 1.0),
            child: Container(
              height: height,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: fill),
                boxShadow: muted
                    ? null
                    : [
                        BoxShadow(
                          color: glowColor.withValues(alpha: 0.5),
                          blurRadius: 14,
                        ),
                      ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Заголовок раздела: капс, счётчик и линия в никуда.
class EvSectionHeader extends StatelessWidget {
  const EvSectionHeader(this.title, {super.key, this.count, this.trailing});

  final String title;
  final String? count;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final ev = context.ev;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(title.toUpperCase(), style: ev.text.section),
        if (count != null) ...[
          const SizedBox(width: 14),
          Text(count!, style: ev.text.data.copyWith(color: ev.colors.ink4)),
        ],
        const SizedBox(width: 14),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [ev.colors.line, ev.colors.line.withValues(alpha: 0)],
              ),
            ),
          ),
        ),
        if (trailing != null) ...[const SizedBox(width: 14), trailing!],
      ],
    );
  }
}
