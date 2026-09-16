import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import '../design/theme.dart';

/// Фон окна, пока нет шейдера.
///
/// Два слоя из прототипа, без движения:
/// * тёплое эллиптическое пятно справа сверху — ровно тот запасной фон,
///   который прототип рисует, когда WebGL недоступен;
/// * жерло у нижней кромки — усреднённое ядро плюма из шейдера
///   (`core` в точке 0.16, −0.62): туда потом встанет живой пар.
///
/// Рисуется один раз и перерисовывается только при смене облика.
class EvBackdrop extends StatelessWidget {
  const EvBackdrop({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.evc;
    return RepaintBoundary(
      child: CustomPaint(
        painter: _BackdropPainter(ground: c.ground, hot: c.hot1, vent: c.hot2),
        size: Size.infinite,
      ),
    );
  }
}

class _BackdropPainter extends CustomPainter {
  const _BackdropPainter({
    required this.ground,
    required this.hot,
    required this.vent,
  });

  final Color ground;
  final Color hot;
  final Color vent;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final w = size.width, h = size.height;
    canvas.drawRect(rect, Paint()..color = ground);

    // radial-gradient(70% 90% at 72% 12%, hot / .13, transparent 60%)
    canvas.drawRect(
      rect,
      Paint()
        ..shader = _ellipse(
          Offset(w * 0.72, h * 0.12),
          w * 0.7,
          h * 0.9,
          [hot.withValues(alpha: 0.13), hot.withValues(alpha: 0)],
          const [0, 0.6],
        ),
    );

    // Жерло: центр чуть ниже кромки окна, правее середины. Спад мягкий,
    // как exp(−2.3·d) в шейдере, — три ступени градиента его повторяют.
    final ventCenter = Offset(w / 2 + h * 0.16, h * 1.12);
    canvas.drawRect(
      rect,
      Paint()
        ..blendMode = BlendMode.screen
        ..shader = _ellipse(
          ventCenter,
          h * 0.95,
          h * 0.95,
          [
            vent.withValues(alpha: 0.16),
            hot.withValues(alpha: 0.07),
            hot.withValues(alpha: 0),
          ],
          const [0, 0.38, 1],
        ),
    );
  }

  /// Эллиптический радиальный градиент: единичный круг, растянутый
  /// матрицей. Так эллипс считается в шейдере, а не тесселируется
  /// огромной окружностью.
  ui.Shader _ellipse(
    Offset center,
    double rx,
    double ry,
    List<Color> colors,
    List<double> stops,
  ) {
    final matrix = Matrix4.translationValues(center.dx, center.dy, 0)
      ..multiply(Matrix4.diagonal3Values(rx, ry, 1));
    return ui.Gradient.radial(
      Offset.zero,
      1,
      colors,
      stops,
      TileMode.clamp,
      matrix.storage,
    );
  }

  @override
  bool shouldRepaint(_BackdropPainter old) =>
      old.ground != ground || old.hot != hot || old.vent != vent;
}
