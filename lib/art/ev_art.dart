import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import 'key_art.dart';

/// Слой ключевого кадра героя. Глубина — сдвиг в пикселях за курсором,
/// запас — насколько слой шире героя с каждой стороны, чтобы сдвиг не
/// открывал края. Всё из прототипа: `.hl.sky{inset:-9%}`, `data-d`.
enum EvHeroLayer {
  sky(bleed: .09, depth: 5),
  ridges(bleed: .06, depth: 14),
  ledge(bleed: .06, depth: 30);

  const EvHeroLayer({required this.bleed, required this.depth});

  final double bleed;
  final double depth;

  /// Кадр героя рисуется в координатах 1280 × 720, как холсты прототипа.
  static const scene = Size(1280, 720);

  void paint(Canvas canvas, EvCoverPalette palette, int seed) => switch (this) {
    sky => paintKeyScene(
      canvas,
      scene,
      palette,
      seed,
      ridges: 0,
      monolith: false,
      sunX: .68,
      sunY: .34,
    ),
    ridges => paintHeroRidges(canvas, scene, palette, seed),
    ledge => paintHeroLedge(canvas, scene, palette, seed),
  };
}

/// Растры ключевых кадров.
///
/// Процедурный кадр дорог: три размытых слоя шума, свечения, сотня звёзд.
/// Под Impeller кэша растра нет, и кадр, нарисованный прямо в дереве,
/// перерисовывался бы на каждом кадре окна, а атмосфера идёт на 60 к/с.
/// Поэтому кадр один раз рисуется в текстуру нужного размера — как холст
/// прототипа в `toDataURL`, — а дальше рисуется текстура.
///
/// Картинки берутся из кэша на время одного рисования и не хранятся:
/// вытесненная из кэша картинка остаётся жива, пока её держит слой кадра.
abstract final class EvArtCache {
  // Литерал карты помнит порядок вставки: первой вытесняется самая
  // давно нужная картинка.
  static final _covers = <Object, ui.Image>{};
  static final _heroLayers = <Object, ui.Image>{};

  /// Обложки: полка, продолжение, палитра, загрузки — с запасом на смену
  /// размеров окна.
  static const _coverCapacity = 96;

  /// Слои героя: три слоя на пару масштабов.
  static const _heroCapacity = 6;

  /// Обложка — сцена 300 × 400 прототипа в текстуре [width] × [height].
  static ui.Image cover(
    EvCoverPalette palette,
    int seed,
    int width,
    int height,
  ) => _lookup(
    _covers,
    (palette, seed, width, height),
    _coverCapacity,
    () => _rasterize(
      evCoverScene,
      width,
      height,
      (canvas) => paintKeyScene(canvas, evCoverScene, palette, seed, ridges: 2),
    ),
  );

  /// Слой героя: сцена 1280 × 720 с масштабом [scale].
  static ui.Image heroLayer(
    EvHeroLayer layer,
    EvCoverPalette palette,
    int seed,
    double scale,
  ) => _lookup(
    _heroLayers,
    (layer, palette, seed, scale),
    _heroCapacity,
    () => _rasterize(
      EvHeroLayer.scene,
      (EvHeroLayer.scene.width * scale).round(),
      (EvHeroLayer.scene.height * scale).round(),
      (canvas) => layer.paint(canvas, palette, seed),
    ),
  );

  /// Сколько растров сейчас в кэше.
  @visibleForTesting
  static int get length => _covers.length + _heroLayers.length;

  @visibleForTesting
  static void clear() {
    for (final image in [..._covers.values, ..._heroLayers.values]) {
      image.dispose();
    }
    _covers.clear();
    _heroLayers.clear();
  }

  static ui.Image _lookup(
    Map<Object, ui.Image> images,
    Object key,
    int capacity,
    ui.Image Function() make,
  ) {
    final hit = images.remove(key);
    if (hit != null) return images[key] = hit;
    while (images.length >= capacity) {
      images.remove(images.keys.first)!.dispose();
    }
    return images[key] = make();
  }

  static ui.Image _rasterize(
    Size scene,
    int width,
    int height,
    void Function(Canvas canvas) paint,
  ) {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder)
      ..scale(width / scene.width, height / scene.height);
    paint(canvas);
    final picture = recorder.endRecording();
    final image = picture.toImageSync(width, height);
    picture.dispose();
    return image;
  }
}

/// Сцена обложки в прототипе — холст 300 × 400.
const evCoverScene = Size(300, 400);

/// Обложка игры: процедурный кадр из растрового кэша. Заполняет свой
/// размер по правилу `background-size: cover` — сцена 3 : 4 масштабируется
/// по большей стороне и обрезается по центру.
class EvCover extends LeafRenderObjectWidget {
  const EvCover({super.key, required this.palette, required this.seed});

  final EvCoverPalette palette;
  final int seed;

  @override
  RenderEvCover createRenderObject(BuildContext context) => RenderEvCover(
    palette: palette,
    seed: seed,
    devicePixelRatio: MediaQuery.devicePixelRatioOf(context),
  );

  @override
  void updateRenderObject(BuildContext context, RenderEvCover renderObject) =>
      renderObject
        ..palette = palette
        ..seed = seed
        ..devicePixelRatio = MediaQuery.devicePixelRatioOf(context);
}

class RenderEvCover extends RenderBox {
  RenderEvCover({
    required this._palette,
    required this._seed,
    required this._devicePixelRatio,
  });

  EvCoverPalette _palette;
  set palette(EvCoverPalette value) {
    if (value == _palette) return;
    _palette = value;
    markNeedsPaint();
  }

  int _seed;
  set seed(int value) {
    if (value == _seed) return;
    _seed = value;
    markNeedsPaint();
  }

  double _devicePixelRatio;
  set devicePixelRatio(double value) {
    if (value == _devicePixelRatio) return;
    _devicePixelRatio = value;
    markNeedsPaint();
  }

  @override
  bool get sizedByParent => true;

  @override
  Size computeDryLayout(BoxConstraints constraints) =>
      constraints.hasBoundedWidth && constraints.hasBoundedHeight
      ? constraints.biggest
      : constraints.constrain(evCoverScene);

  @override
  void paint(PaintingContext context, Offset offset) {
    if (size.isEmpty) return;
    final dpr = _devicePixelRatio;
    final fit = math.max(
      size.width / evCoverScene.width,
      size.height / evCoverScene.height,
    );
    final width = math.max(1, (evCoverScene.width * fit * dpr).round());
    final height = math.max(1, (evCoverScene.height * fit * dpr).round());
    final image = EvArtCache.cover(_palette, _seed, width, height);
    context.canvas.drawImageRect(
      image,
      Rect.fromCenter(
        center: Offset(width / 2, height / 2),
        width: math.min(width.toDouble(), size.width * dpr),
        height: math.min(height.toDouble(), size.height * dpr),
      ),
      offset & size,
      Paint()..filterQuality = FilterQuality.low,
    );
  }
}
