import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:evaporate_design/design/effects.dart';
import 'package:evaporate_design/design/theme.dart';
import 'package:evaporate_design/design/tokens.dart';
import 'package:evaporate_design/glass/ev_droplet.dart';
import 'package:evaporate_design/glass/ev_glass.dart';
import 'package:evaporate_design/glass/glass_lens.dart';
import 'package:evaporate_design/glass/glass_surface.dart';
import 'package:evaporate_design/library/ev_hero.dart';
import 'package:evaporate_design/main.dart';
import 'package:evaporate_design/screens/library_page.dart';
import 'package:evaporate_design/shell/ev_rail.dart';
import 'package:evaporate_design/shell/ev_section.dart';

Future<void> _settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(seconds: 1));
  await tester.pump();
}

Widget _app(EvEffects effects) => EvaporateApp(effects: effects);

EvEffects _still(WidgetTester tester) {
  final effects = EvEffects.still();
  addTearDown(effects.dispose);
  return effects;
}

Future<void> _window(WidgetTester tester, double w, double h) async {
  tester.view.physicalSize = Size(w, h);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

void main() {
  group('материал', () {
    testWidgets('стекло читает фон, а без него — нет', (tester) async {
      await _window(tester, 1440, 900);
      final effects = _still(tester);
      await tester.pumpWidget(_app(effects));
      await _settle(tester);

      final withGlass = tester.widgetList(find.byType(BackdropFilter)).length;
      expect(withGlass, greaterThan(3), reason: 'рейл и полосы — стеклянные');

      effects.glass = false;
      await _settle(tester);
      expect(
        find.byType(BackdropFilter),
        findsNothing,
        reason: 'выключенное стекло не должно стоить ни одного чтения фона',
      );
    });

    testWidgets('стекло без фона держится заливкой поплотнее', (tester) async {
      await _window(tester, 600, 400);
      final effects = _still(tester);
      Color fillOf(WidgetTester tester) => tester
          .renderObject<RenderGlassSurface>(find.byType(EvGlassSurface))
          .fill;

      await tester.pumpWidget(
        MaterialApp(
          theme: buildEvTheme(),
          home: EvEffectsScope(
            effects: effects,
            child: const Scaffold(
              body: Center(
                child: EvGlass(child: SizedBox(width: 200, height: 80)),
              ),
            ),
          ),
        ),
      );
      await _settle(tester);
      final glass = fillOf(tester);

      effects.glass = false;
      await _settle(tester);
      expect(fillOf(tester).a, greaterThan(glass.a));
    });

    test('преломление обещано ровно там, где движок его умеет', () {
      expect(EvGlassLens.supported, ui.ImageFilter.isShaderFilterSupported);
      // В тестах движок — Skia, значит линза недоступна и стекло матовое.
      if (!EvGlassLens.supported) expect(EvGlassLens.ready.value, isFalse);
    });
  });

  group('свет', () {
    const window = Size(1280, 720);
    const rect = Rect.fromLTWH(540, 300, 200, 120);

    test('кромка со стороны курсора светится ярче дальней', () {
      // курсор слева сверху от стекла
      final light = EvGlassLight.of(rect, const Offset(0.1, 0.1), window);
      final top = light.intensity(rect.topCenter, const Offset(0, -1));
      final bottom = light.intensity(rect.bottomCenter, const Offset(0, 1));
      final left = light.intensity(rect.centerLeft, const Offset(-1, 0));
      final right = light.intensity(rect.centerRight, const Offset(1, 0));
      expect(top, greaterThan(bottom * 1.5));
      expect(left, greaterThan(right * 1.5));
    });

    test('курсор ушёл на другую сторону — блик ушёл за ним', () {
      final leftLight = EvGlassLight.of(rect, const Offset(0.05, 0.5), window);
      final rightLight = EvGlassLight.of(rect, const Offset(0.95, 0.5), window);
      const normal = Offset(1, 0);
      expect(
        rightLight.intensity(rect.centerRight, normal),
        greaterThan(leftLight.intensity(rect.centerRight, normal)),
      );
    });

    test('без курсора свет стоит слева сверху', () {
      final light = EvGlassLight.of(rect, null, window);
      expect(light.point.dx, lessThan(rect.left));
      expect(light.point.dy, lessThan(rect.top));
    });
  });

  group('капля', () {
    const from = Rect.fromLTWH(6, 62, 48, 44);
    const to = Rect.fromLTWH(6, 206, 48, 44);

    test('на концах пути капля ровно на месте', () {
      expect(evDropletRect(from, to, 0), from);
      expect(evDropletRect(from, to, 1), to);
    });

    test('в полёте капля вытянута по движению и сужена поперёк', () {
      final mid = evDropletRect(from, to, 0.45);
      expect(mid.height, greaterThan(from.height * 1.2));
      expect(mid.width, lessThan(from.width));
      // передний край уже ближе к цели, чем задний
      final leadPassed = (mid.bottom - from.bottom) / (to.bottom - from.bottom);
      final trailPassed = (mid.top - from.top) / (to.top - from.top);
      expect(leadPassed, greaterThan(trailPassed));
    });

    test('капля вверх вытягивается так же', () {
      final mid = evDropletRect(to, from, 0.45);
      expect(mid.height, greaterThan(from.height * 1.2));
      final leadPassed = (to.top - mid.top) / (to.top - from.top);
      final trailPassed = (to.bottom - mid.bottom) / (to.bottom - from.bottom);
      expect(leadPassed, greaterThan(trailPassed));
    });

    test('капля рейла встаёт на кнопку выбранного раздела', () {
      const height = 884.0;
      for (final (i, section) in EvSection.primary.indexed) {
        final rect = EvRail.dropletRect(section, height);
        expect(rect.top, EvRail.itemTop(i));
        expect(rect.size, const Size(EvRail.itemWidth, EvRail.itemHeight));
      }
      expect(
        EvRail.dropletRect(EvSection.friends, height).top,
        EvRail.friendsTop(height),
      );
      // на профиле капля центрируется на аватаре
      expect(
        EvRail.dropletRect(EvSection.profile, height).center.dy,
        EvRail.avatarTop(height) + EvRail.avatarSize / 2,
      );
    });

    testWidgets('капля переезжает к выбранному разделу', (tester) async {
      await _window(tester, 1440, 900);
      await tester.pumpWidget(_app(_still(tester)));
      await _settle(tester);

      Rect droplet() => tester.getRect(find.byType(EvDroplet).first);
      final library = droplet();
      await tester.tap(
        find.byWidgetPredicate(
          (w) => w is EvRailItem && w.section == EvSection.saves,
        ),
      );
      await _settle(tester);
      expect(droplet().top, greaterThan(library.top));
    });
  });

  group('каркас', () {
    testWidgets('экран уходит под полосы, а не упирается в них', (
      tester,
    ) async {
      await _window(tester, 1440, 900);
      await tester.pumpWidget(_app(_still(tester)));
      await _settle(tester);

      final page = tester.getRect(find.byType(LibraryPage));
      expect(page.top, 0, reason: 'экран начинается под верхней полосой');
      expect(page.bottom, 900, reason: 'и продолжается под строкой подсказок');
      expect(page.left, EvSpace.railWidth);

      // …но содержимое начинается ниже полосы: её высота приходит
      // в отступах MediaQuery.
      final list = tester.widget<ListView>(find.byType(ListView).first);
      expect(list.padding, isA<EdgeInsets>());
      expect((list.padding! as EdgeInsets).top, EvSpace.topBarHeight);
      expect(tester.getRect(find.byType(EvHero)).top, greaterThanOrEqualTo(58));
    });

    testWidgets('рейл — плита с отступом от кромок окна', (tester) async {
      await _window(tester, 1440, 900);
      await tester.pumpWidget(_app(_still(tester)));
      await _settle(tester);

      final rail = tester.getRect(find.byType(EvRail));
      expect(rail.width, EvSpace.railWidth);
      final slab = tester.getRect(
        find
            .descendant(of: find.byType(EvRail), matching: find.byType(EvGlass))
            .first,
      );
      expect(slab.left, EvRail.inset);
      expect(slab.width, EvRail.slabWidth);
      expect(slab.top, EvRail.inset);
      expect(slab.bottom, 900 - EvRail.inset);
    });
  });
}
