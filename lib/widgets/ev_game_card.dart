import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../design/theme.dart';
import '../design/tokens.dart';
import 'ev_focusable.dart';
import 'ev_surfaces.dart';

/// Палитра одной обложки. Обложки рисуются процедурно: у раздачи картинки
/// может не быть, а серый прямоугольник на полке — худшее, что можно
/// показать вместо игры.
@immutable
class EvCoverPalette {
  const EvCoverPalette(this.deep, this.mid, this.hot, this.hot2);

  final Color deep;
  final Color mid;
  final Color hot;
  final Color hot2;

  static const ash = EvCoverPalette(
    Color(0xFF2A0F06),
    Color(0xFF160806),
    Color(0xFFFF7A18),
    Color(0xFFFFD28A),
  );
  static const deepSea = EvCoverPalette(
    Color(0xFF04222C),
    Color(0xFF03121A),
    Color(0xFF33D6D0),
    Color(0xFFC8FFF6),
  );
  static const neon = EvCoverPalette(
    Color(0xFF1B0636),
    Color(0xFF0D0320),
    Color(0xFFC15BFF),
    Color(0xFFFFB6F2),
  );
  static const lunar = EvCoverPalette(
    Color(0xFF0A1430),
    Color(0xFF050A1C),
    Color(0xFF6F9BFF),
    Color(0xFFDCE8FF),
  );
  static const crimson = EvCoverPalette(
    Color(0xFF2E0610),
    Color(0xFF170309),
    Color(0xFFFF3D5E),
    Color(0xFFFFC0C8),
  );
  static const glass = EvCoverPalette(
    Color(0xFF0B2A22),
    Color(0xFF04130F),
    Color(0xFF3BE39B),
    Color(0xFFD3FFE9),
  );
}

/// Ключевой кадр игры: небо, световое ядро, два силуэта хребта и виньетка.
/// Тот же рецепт, что в макетах, — обложки не расходятся между прототипом
/// и приложением.
class EvCoverPainter extends CustomPainter {
  EvCoverPainter({required this.palette, required this.seed});

  final EvCoverPalette palette;
  final int seed;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final rnd = math.Random(seed);
    final rect = Offset.zero & size;
    canvas.clipRect(rect);

    // небо
    canvas.drawRect(
      rect,
      Paint()
        ..shader = _linear(
          [palette.deep, palette.mid, const Color(0xFF040407)],
          const [0, 0.48, 1],
          Offset.zero,
          Offset(w * 0.3, h),
        ),
    );

    // объёмная дымка: несколько размытых пятен вместо честного fbm —
    // рисуется один раз, а читается так же
    for (var i = 0; i < 7; i++) {
      final r = w * (0.22 + rnd.nextDouble() * 0.4);
      canvas.drawCircle(
        Offset(rnd.nextDouble() * w, h * (0.1 + rnd.nextDouble() * 0.6)),
        r,
        Paint()
          ..blendMode = BlendMode.screen
          ..color = (i.isEven ? palette.hot : palette.mid)
              .withValues(alpha: 0.05 + rnd.nextDouble() * 0.06)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.7),
      );
    }

    // световое ядро: тугое и высоко, иначе обложка читается плоским пятном
    final sx = w * (0.3 + rnd.nextDouble() * 0.4);
    final sy = h * (0.22 + rnd.nextDouble() * 0.16);
    final sr = w * (0.2 + rnd.nextDouble() * 0.1);
    canvas.drawCircle(
      Offset(sx, sy),
      sr * 2.6,
      Paint()
        ..blendMode = BlendMode.screen
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFFFFFFF),
            palette.hot2,
            palette.hot,
            palette.hot.withValues(alpha: 0),
          ],
          stops: const [0, 0.06, 0.2, 0.75],
        ).createShader(
          Rect.fromCircle(center: Offset(sx, sy), radius: sr * 2.6),
        ),
    );

    // световые лучи от ядра
    canvas.save();
    canvas.translate(sx, sy);
    for (var i = 0; i < 5; i++) {
      canvas.save();
      canvas.rotate((rnd.nextDouble() - 0.5) * 1.5 + math.pi / 2);
      final spread = w * (0.02 + rnd.nextDouble() * 0.05);
      final path = Path()
        ..moveTo(0, 0)
        ..lineTo(-spread, h * 1.4)
        ..lineTo(spread, h * 1.4)
        ..close();
      canvas.drawPath(
        path,
        Paint()
          ..blendMode = BlendMode.screen
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              palette.hot2.withValues(alpha: 0.18),
              palette.hot2.withValues(alpha: 0),
            ],
          ).createShader(Rect.fromLTWH(-spread, 0, spread * 2, h * 1.4)),
      );
      canvas.restore();
    }
    canvas.restore();

    // звёзды
    for (var i = 0; i < 40; i++) {
      canvas.drawRect(
        Rect.fromLTWH(rnd.nextDouble() * w, rnd.nextDouble() * h * 0.6, 1.1, 1.1),
        Paint()
          ..blendMode = BlendMode.screen
          ..color = const Color(0xFFFFFFFF).withValues(
            alpha: rnd.nextDouble() * 0.5,
          ),
      );
    }

    // три силуэта хребта: дальний светлее, ближний почти чёрный.
    // Кромка подсвечена — это то, что делает кадр объёмным.
    for (var k = 0; k < 3; k++) {
      final base = h * (0.56 + k * 0.13);
      final amp = h * (0.15 - k * 0.035);
      final ph = rnd.nextDouble() * 9;
      final path = Path()..moveTo(-2, h + 2);
      for (var x = -2.0; x <= w + 2; x += w / 30) {
        final y =
            base +
            math.sin(x / w * 6.1 + ph) * amp * 0.6 +
            math.sin(x / w * 15.3 + ph * 2) * amp * 0.34 +
            math.sin(x / w * 31 + ph * 3) * amp * 0.12;
        path.lineTo(x, y);
      }
      path
        ..lineTo(w + 2, h + 2)
        ..close();
      canvas.drawPath(
        path,
        Paint()
          ..color = switch (k) {
            0 => const Color(0xB8040408),
            1 => const Color(0xE0030306),
            _ => const Color(0xFF020205),
          },
      );
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.3
          ..blendMode = BlendMode.screen
          ..color = palette.hot.withValues(alpha: 0.42 - k * 0.11)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
    }

    // одинокая вертикаль задаёт масштаб
    final mx = w * (0.6 + rnd.nextDouble() * 0.18);
    final mw = w * 0.035;
    final mh = h * 0.3;
    canvas.drawRect(
      Rect.fromLTWH(mx - mw / 2, h * 0.72 - mh, mw, mh),
      Paint()..color = const Color(0xFF020205),
    );

    // виньетка
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          colors: const [Color(0x00000000), Color(0xDB020205)],
          stops: const [0.35, 1],
        ).createShader(
          Rect.fromCircle(center: Offset(w * .5, h * .44), radius: h * 0.95),
        ),
    );
  }

  Shader _linear(
    List<Color> colors,
    List<double> stops,
    Offset from,
    Offset to,
  ) => LinearGradient(
    colors: colors,
    stops: stops,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  ).createShader(Rect.fromPoints(from, to));

  @override
  bool shouldRepaint(EvCoverPainter old) =>
      old.seed != seed || old.palette != palette;
}

/// Состояние игры на полке.
enum EvGameState { ready, downloading, queued }

/// Карточка на полке. Единственное, что выходит из плоскости при наведении:
/// −8 px по Y, тень 26 → 54 и контур акцента.
class EvGameCard extends StatefulWidget {
  const EvGameCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.palette,
    required this.seed,
    this.state = EvGameState.ready,
    this.progress,
    this.badge,
    this.width = 178,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final EvCoverPalette palette;
  final int seed;
  final EvGameState state;

  /// 0…1, показывается полосой внизу обложки.
  final double? progress;

  final String? badge;
  final double width;
  final VoidCallback? onTap;

  @override
  State<EvGameCard> createState() => _EvGameCardState();
}

class _EvGameCardState extends State<EvGameCard> {
  bool _hover = false;
  bool _focus = false;

  @override
  Widget build(BuildContext context) {
    final ev = context.ev;
    final c = ev.colors;
    // Фокус с клавиатуры поднимает карточку так же, как наведение:
    // на полке, которую листают стрелками, иначе не видно, где ты.
    final lifted = _hover || _focus;
    // Наведение ловится снаружи сдвига: иначе поднятая карточка уходила бы
    // из-под курсора у нижней кромки и начинала мигать.
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: EvMotion.hover,
        curve: EvMotion.easeOut,
        width: widget.width,
        transform: Matrix4.translationValues(0, lifted ? -8 : 0, 0),
        child: EvFocusable(
          onActivate: widget.onTap,
          radius: ev.radii.r3,
          onFocusHighlight: (v) => setState(() => _focus = v),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              AspectRatio(
                aspectRatio: 3 / 4,
                child: AnimatedContainer(
                  duration: EvMotion.hover,
                  curve: EvMotion.easeOut,
                  decoration: BoxDecoration(
                    borderRadius: ev.radii.b3,
                    border: Border.all(
                      color: lifted ? c.hot1.withValues(alpha: 0.4) : c.line,
                    ),
                    boxShadow: lifted
                        ? [
                            ...ev.shadowLift,
                            BoxShadow(
                              color: c.hot1.withValues(alpha: 0.3),
                              blurRadius: 42,
                            ),
                          ]
                        : ev.shadowRest,
                  ),
                  child: ClipRRect(
                    borderRadius: ev.radii.b3,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CustomPaint(
                          painter: EvCoverPainter(
                            palette: widget.palette,
                            seed: widget.seed,
                          ),
                        ),
                        // кромка, освещённая изнутри
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          height: 1,
                          child: ColoredBox(
                            color: c.ink.withValues(alpha: 0.16),
                          ),
                        ),
                        if (widget.badge != null)
                          Positioned(
                            top: 9,
                            left: 9,
                            child: _Badge(
                              widget.badge!,
                              state: widget.state,
                            ),
                          ),
                        if (widget.progress != null)
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: EvBar(
                              widget.progress!,
                              cool: true,
                              height: 3,
                            ),
                          ),
                        if (lifted)
                          Positioned.fill(
                            child: IgnorePointer(
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      const Color(0x00FFFFFF),
                                      c.ink.withValues(alpha: 0.22),
                                      const Color(0x00FFFFFF),
                                    ],
                                    stops: const [0.3, 0.48, 0.62],
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 11),
              Text(
                widget.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: ev.text.body.copyWith(
                  color: c.ink,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: ev.text.data.copyWith(color: c.ink4, fontSize: 10.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge(this.label, {required this.state});

  final String label;
  final EvGameState state;

  @override
  Widget build(BuildContext context) {
    final ev = context.ev;
    final c = ev.colors;
    final tint = switch (state) {
      EvGameState.downloading => c.cool,
      EvGameState.queued => c.ink3,
      EvGameState.ready => c.hot2,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        borderRadius: ev.radii.b1,
        color: state == EvGameState.queued
            ? c.ground.withValues(alpha: 0.7)
            : tint.withValues(alpha: 0.14),
        border: Border.all(
          color: state == EvGameState.queued
              ? c.ink.withValues(alpha: 0.12)
              : tint.withValues(alpha: 0.4),
        ),
      ),
      child: Text(
        label.toUpperCase(),
        style: ev.text.data.copyWith(
          color: state == EvGameState.queued ? c.ink2 : tint,
          fontSize: 9.5,
          letterSpacing: 0.95,
        ),
      ),
    );
  }
}
