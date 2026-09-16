import 'package:flutter/material.dart';

import '../design/appearance.dart';
import '../design/theme.dart';
import '../design/tokens.dart';
import '../gallery/gallery_page.dart';
import '../widgets/ev_controls.dart';
import '../widgets/ev_icon.dart';
import '../widgets/ev_surfaces.dart';

/// Настройки в каркасе: облик и вход в галерею компонентов. Полный экран —
/// десять разделов, поиск по настройкам, расписание — пока в макете.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ev = context.ev;
    final appearance = EvAppearanceScope.of(context);
    final gutter = EvSpace.gutterFor(MediaQuery.sizeOf(context));
    return ListView(
      primary: true,
      padding: EdgeInsets.fromLTRB(gutter, gutter, gutter, 26),
      children: [
        const EvSectionHeader('Облик', count: 'тема и геометрия'),
        const SizedBox(height: EvSpace.l),
        EvPanel(
          child: Column(
            children: [
              EvOption(
                title: 'Тема',
                description:
                    'Температура источника света · ${appearance.skin.hint}',
                control: EvSegmented<EvSkin>(
                  items: {for (final s in EvSkin.values) s: s.label},
                  value: appearance.skin,
                  onChanged: (s) => appearance.skin = s,
                ),
              ),
              EvOption(
                last: true,
                title: 'Скругление',
                description:
                    'Потолок радиуса. 8 px — приборная геометрия по умолчанию',
                control: EvSegmented<EvGeometry>(
                  items: {for (final g in EvGeometry.values) g: g.label},
                  value: appearance.geometry,
                  onChanged: (g) => appearance.geometry = g,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: EvSpace.xxl),
        const EvSectionHeader('Разработка'),
        const SizedBox(height: EvSpace.l),
        EvPanel(
          child: EvOption(
            last: true,
            title: 'Галерея компонентов',
            description:
                'Все виджеты, перенесённые из макетов, на одной странице',
            control: EvMiniButton(
              label: 'Открыть',
              icon: EvIcons.go,
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const GalleryPage()),
              ),
            ),
          ),
        ),
        const SizedBox(height: EvSpace.l),
        Text(
          'Остальные разделы — эффекты, звук, библиотека, загрузки, раздача, '
          'сохранения, запуск, клавиши, «О программе» — и поиск по настройкам '
          'пока живут в макете design/evaporate-launcher.html.',
          style: ev.text.bodySmall.copyWith(color: ev.colors.ink4),
        ),
      ],
    );
  }
}
