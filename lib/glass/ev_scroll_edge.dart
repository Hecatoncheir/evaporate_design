import 'package:flutter/widgets.dart';

import '../design/effects.dart';
import '../design/theme.dart';

/// Мягкий край полосы каркаса.
///
/// Под матовой полосой содержимое обрывалось бы резкой границей: тут
/// размыто, а на пиксель ниже — нет. Край добавляет несколько ступеней
/// размытия и затемнения, и переход читается как глубина, а не как шов.
/// В iOS это называется scroll edge effect; здесь он ступенчатый, потому
/// что размытие с переменным радиусом стоило бы отдельного прохода.
class EvScrollEdge extends StatelessWidget {
  const EvScrollEdge({
    super.key,
    this.height = 22,
    this.fromTop = true,
    this.blur = 12,
  });

  /// Высота перехода.
  final double height;

  /// Полоса сверху: размытие слабеет вниз. Иначе — наоборот.
  final bool fromTop;

  /// Размытие у самой полосы.
  final double blur;

  static const _steps = 3;

  @override
  Widget build(BuildContext context) {
    final c = context.evc;
    final effects = EvEffectsScope.maybeOf(context);
    if (!(effects?.glass ?? true)) return SizedBox(height: height);
    final scale = (effects?.quality ?? EvEffectsQuality.full).blurScale;
    final strips = [
      for (var i = 0; i < _steps; i++)
        _EdgeStrip(
          height: height / _steps,
          // Ступени идут вчетверо мягче каждая: так шов между ними
          // не заметнее самого края.
          sigma: blur * scale / (1 << (i + 1)),
          tint: c.ground.withValues(alpha: 0.26 / (1 << i)),
        ),
    ];
    return IgnorePointer(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: fromTop ? strips : strips.reversed.toList(),
      ),
    );
  }
}

class _EdgeStrip extends StatelessWidget {
  const _EdgeStrip({
    required this.height,
    required this.sigma,
    required this.tint,
  });

  final double height;
  final double sigma;
  final Color tint;

  @override
  Widget build(BuildContext context) => ClipRect(
    child: BackdropFilter.grouped(
      filterConfig: ImageFilterConfig.blur(sigmaX: sigma, sigmaY: sigma),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: ColoredBox(color: tint),
      ),
    ),
  );
}
