import 'package:flutter/material.dart';

import 'tokens.dart';
import 'typography.dart';

/// Тема Evaporate — только тёмная, по требованию продукта.
///
/// Всё, что рисуют виджеты, приходит отсюда через `context.ev`, поэтому
/// смена облика или потолка радиуса не требует правок в самих виджетах.
@immutable
class EvTheme extends ThemeExtension<EvTheme> {
  const EvTheme({required this.colors, required this.radii, required this.text});

  final EvColors colors;
  final EvRadii radii;
  /// Типографика. Имя `type` занято `ThemeExtension.type` —
  /// это ключ, по которому ThemeData находит расширение.
  final EvType text;

  factory EvTheme.of(EvColors colors, EvRadii radii) => EvTheme(
    colors: colors,
    radii: radii,
    text: EvType(colors.ink, colors.ink2, colors.ink3, colors.ink4),
  );

  /// Тень покоя.
  List<BoxShadow> get shadowRest => const [
    BoxShadow(color: Color(0x8C000000), blurRadius: 30, offset: Offset(0, 14)),
  ];

  /// Тень поднятого объекта.
  List<BoxShadow> get shadowLift => const [
    BoxShadow(color: Color(0xB3000000), blurRadius: 54, offset: Offset(0, 26)),
  ];

  /// Свечение активного. Цветной бывает только эта тень и только у того,
  /// что реагирует на пользователя.
  List<BoxShadow> glow(Color c, {double opacity = 0.3, double blur = 42}) => [
    BoxShadow(color: c.withValues(alpha: opacity), blurRadius: blur),
  ];

  /// Заливка панели: градиент белого 3 % → 0.6 %.
  LinearGradient get panelFill => const LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0x08FFFFFF), Color(0x02FFFFFF)],
  );

  @override
  EvTheme copyWith({EvColors? colors, EvRadii? radii, EvType? text}) => EvTheme(
    colors: colors ?? this.colors,
    radii: radii ?? this.radii,
    text: text ?? this.text,
  );

  @override
  EvTheme lerp(covariant EvTheme? other, double t) {
    if (other == null) return this;
    return EvTheme(
      colors: EvColors.lerp(colors, other.colors, t),
      radii: EvRadii.lerp(radii, other.radii, t),
      text: EvType.lerp(text, other.text, t),
    );
  }
}

/// Три облика. Тема не «раскрашивает» интерфейс, а задаёт температуру
/// источника света.
enum EvSkin {
  magma(EvColors.magma, 'Magma', 'янтарь · плазма'),
  nebula(EvColors.nebula, 'Nebula', 'фиалка · магента'),
  cryo(EvColors.cryo, 'Cryo', 'лёд · искра');

  const EvSkin(this.colors, this.label, this.hint);

  final EvColors colors;
  final String label;
  final String hint;
}

/// Потолок радиуса. Переключается в настройках.
enum EvGeometry {
  tight(EvRadii.tight, '8 px'),
  soft(EvRadii.soft, '24 px'),
  full(EvRadii.full, 'Полный');

  const EvGeometry(this.radii, this.label);

  final EvRadii radii;
  final String label;
}

ThemeData buildEvTheme({
  EvSkin skin = EvSkin.magma,
  EvGeometry geometry = EvGeometry.tight,
}) {
  final c = skin.colors;
  final ev = EvTheme.of(c, geometry.radii);
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: c.ground,
    colorScheme: ColorScheme.dark(
      primary: c.hot1,
      onPrimary: const Color(0xFF170800),
      secondary: c.cool,
      surface: c.surface,
      onSurface: c.ink,
      error: EvColors.bad,
    ),
    extensions: [ev],
  );
}

extension EvThemeAccess on BuildContext {
  /// Токены текущей темы.
  EvTheme get ev => Theme.of(this).extension<EvTheme>()!;

  EvColors get evc => ev.colors;

  EvRadii get evr => ev.radii;

  EvType get evt => ev.text;
}
