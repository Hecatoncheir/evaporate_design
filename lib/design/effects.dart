import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// Уровень эффектов: плотность частиц и разрешение шейдера. Множители —
/// из прототипа.
enum EvEffectsQuality {
  eco(0.5, 'Эко'),
  full(1, 'Полное'),
  max(1.6, 'Макс');

  const EvEffectsQuality(this.factor, this.label);

  final double factor;
  final String label;

  /// Пикселей кадра плюма на логический пиксель окна. Как в прототипе:
  /// 55 % при «Полном», не меньше 30 % и не больше 100 %, умноженное на
  /// плотность экрана, но не больше двух — на 4K плюм мягкий и так.
  double plumeScale(double devicePixelRatio) =>
      (0.55 * factor).clamp(0.3, 1.0) * math.min(devicePixelRatio, 2);
}

/// Эффекты атмосферы. Отдельно от облика: переключение искр не должно
/// пересобирать тему всего приложения.
class EvEffects extends ChangeNotifier {
  EvEffects({
    this._livingBackground = true,
    this._sparks = true,
    this._parallax = true,
    this._grain = true,
    this._quality = EvEffectsQuality.full,
    this._ritual = true,
    this._holdToPlay = true,
    this._throttleInBackground = true,
  });

  /// Всё выключено: для превью и тестов, где кадры не должны идти сами.
  /// Удержание «Играть» и ритуал запуска остаются — сами они кадров не
  /// заводят.
  EvEffects.still()
    : this(
        livingBackground: false,
        sparks: false,
        parallax: false,
        grain: false,
      );

  bool _livingBackground;
  bool _sparks;
  bool _parallax;
  bool _grain;
  EvEffectsQuality _quality;
  bool _ritual;
  bool _holdToPlay;
  bool _throttleInBackground;

  /// Живой фон: плюм пара на шейдере.
  bool get livingBackground => _livingBackground;
  set livingBackground(bool value) {
    if (value == _livingBackground) return;
    _livingBackground = value;
    notifyListeners();
  }

  /// Восходящие угли.
  bool get sparks => _sparks;
  set sparks(bool value) {
    if (value == _sparks) return;
    _sparks = value;
    notifyListeners();
  }

  /// Параллакс обложек: слои героя сдвигаются за курсором на разную глубину.
  bool get parallax => _parallax;
  set parallax(bool value) {
    if (value == _parallax) return;
    _parallax = value;
    notifyListeners();
  }

  /// Плёночное зерно поверх фона: 5 %, убирает бандинг на градиентах.
  bool get grain => _grain;
  set grain(bool value) {
    if (value == _grain) return;
    _grain = value;
    notifyListeners();
  }

  EvEffectsQuality get quality => _quality;
  set quality(EvEffectsQuality value) {
    if (value == _quality) return;
    _quality = value;
    notifyListeners();
  }

  /// Ритуал запуска: шесть стадий за 2,6 с, выброс искр, вспышка, волна
  /// и ирис. Выключен — игра запускается под коротким затемнением на 0,9 с.
  bool get ritual => _ritual;
  set ritual(bool value) {
    if (value == _ritual) return;
    _ritual = value;
    notifyListeners();
  }

  /// «Играть» нужно удерживать 620 мс — защита от случайного запуска.
  /// Выключено — кнопка срабатывает по нажатию.
  bool get holdToPlay => _holdToPlay;
  set holdToPlay(bool value) {
    if (value == _holdToPlay) return;
    _holdToPlay = value;
    notifyListeners();
  }

  /// 30 кадров в секунду, пока окно неактивно.
  bool get throttleInBackground => _throttleInBackground;
  set throttleInBackground(bool value) {
    if (value == _throttleInBackground) return;
    _throttleInBackground = value;
    notifyListeners();
  }
}

class EvEffectsScope extends InheritedNotifier<EvEffects> {
  const EvEffectsScope({
    super.key,
    required EvEffects effects,
    required super.child,
  }) : super(notifier: effects);

  /// `null`, если эффекты никто не задал, — тогда атмосфера неподвижна.
  static EvEffects? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<EvEffectsScope>()?.notifier;
}
