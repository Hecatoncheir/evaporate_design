import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';

/// Шрифтовая пара. Кириллица нарисована во всех трёх — это было условием
/// выбора, интерфейс русскоязычный.
///
/// * **Unbounded** — дисплей: заголовки, крупные числа, логотип.
/// * **Onest** — интерфейс: всё остальное.
/// * **JetBrains Mono** — данные: скорости, пиры, хеши, подсказки клавиш.
@immutable
class EvType {
  const EvType(this.ink, this.ink2, this.ink3, this.ink4);

  final Color ink;
  final Color ink2;
  final Color ink3;
  final Color ink4;

  /// Заголовок героя. Лёгкое начертание в крупном кегле — характер системы.
  TextStyle display(double size) => GoogleFonts.unbounded(
    fontSize: size,
    fontWeight: FontWeight.w300,
    height: 0.94,
    letterSpacing: size * -0.022,
    color: ink,
  );

  /// Ударная часть заголовка.
  TextStyle displayBold(double size) =>
      display(size).copyWith(fontWeight: FontWeight.w800);

  /// Заголовок раздела: капс с разрядкой.
  TextStyle get section => GoogleFonts.unbounded(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    letterSpacing: 2.6,
    color: ink,
  );

  /// Название игры, строки списков.
  TextStyle get title => GoogleFonts.onest(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.08,
    color: ink,
  );

  TextStyle get body => GoogleFonts.onest(
    fontSize: 14,
    height: 1.5,
    color: ink2,
  );

  TextStyle get bodySmall => GoogleFonts.onest(
    fontSize: 12.5,
    height: 1.45,
    color: ink3,
  );

  /// Надпись над заголовком и подписи панелей.
  TextStyle get label => GoogleFonts.jetBrainsMono(
    fontSize: 10.5,
    fontWeight: FontWeight.w500,
    letterSpacing: 2.1,
    color: ink4,
  );

  /// Числа. Везде, где цифры выстраиваются в колонку, — моноширинные.
  TextStyle get data => GoogleFonts.jetBrainsMono(
    fontSize: 11.5,
    color: ink3,
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  TextStyle get dataStrong => data.copyWith(
    color: ink,
    fontWeight: FontWeight.w500,
  );

  /// Крупное число в панели.
  TextStyle big(double size) => GoogleFonts.unbounded(
    fontSize: size,
    fontWeight: FontWeight.w300,
    height: 1,
    letterSpacing: size * -0.03,
    color: ink,
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  static EvType lerp(EvType a, EvType b, double t) => EvType(
    Color.lerp(a.ink, b.ink, t)!,
    Color.lerp(a.ink2, b.ink2, t)!,
    Color.lerp(a.ink3, b.ink3, t)!,
    Color.lerp(a.ink4, b.ink4, t)!,
  );
}
