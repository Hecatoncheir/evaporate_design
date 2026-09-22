import 'package:flutter/material.dart';

import '../design/appearance.dart';
import '../design/effects.dart';
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
    final effects = EvEffectsScope.maybeOf(context);
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
        if (effects != null) ...[
          const SizedBox(height: EvSpace.xxl),
          const EvSectionHeader('Эффекты', count: 'атмосфера и качество'),
          const SizedBox(height: EvSpace.l),
          EvPanel(
            child: Column(
              children: [
                EvOption(
                  title: 'Живой фон (шейдер)',
                  description: 'Объёмный плюм пара за интерфейсом',
                  control: EvSwitch(
                    value: effects.livingBackground,
                    semanticLabel: 'Живой фон',
                    onChanged: (v) => effects.livingBackground = v,
                  ),
                ),
                EvOption(
                  title: 'Искры и частицы',
                  description: 'Восходящие угли, аддитивное смешивание',
                  control: EvSwitch(
                    value: effects.sparks,
                    semanticLabel: 'Искры',
                    onChanged: (v) => effects.sparks = v,
                  ),
                ),
                EvOption(
                  title: 'Параллакс обложек',
                  description: 'Четыре слоя глубины, реакция на курсор',
                  control: EvSwitch(
                    value: effects.parallax,
                    semanticLabel: 'Параллакс',
                    onChanged: (v) => effects.parallax = v,
                  ),
                ),
                EvOption(
                  title: 'Плёночное зерно',
                  description: '5 % перекрытия, убирает бандинг на градиентах',
                  control: EvSwitch(
                    value: effects.grain,
                    semanticLabel: 'Зерно',
                    onChanged: (v) => effects.grain = v,
                  ),
                ),
                EvOption(
                  title: 'Уровень эффектов',
                  description: 'Плотность частиц и разрешение шейдера',
                  control: EvSegmented<EvEffectsQuality>(
                    items: {
                      for (final q in EvEffectsQuality.values) q: q.label,
                    },
                    value: effects.quality,
                    onChanged: (q) => effects.quality = q,
                  ),
                ),
                EvOption(
                  title: 'Ритуал запуска',
                  description:
                      'Испарение интерфейса и ударная волна при старте',
                  control: EvSwitch(
                    value: effects.ritual,
                    semanticLabel: 'Ритуал запуска',
                    onChanged: (v) => effects.ritual = v,
                  ),
                ),
                EvOption(
                  title: 'Удержание кнопки «Играть»',
                  description: 'Защита от случайного запуска · 620 мс',
                  control: EvSwitch(
                    value: effects.holdToPlay,
                    semanticLabel: 'Удержание',
                    onChanged: (v) => effects.holdToPlay = v,
                  ),
                ),
                EvOption(
                  last: true,
                  title: 'Ограничить до 30 к/с в фоне',
                  description: 'Экономит батарею, когда окно неактивно',
                  control: EvSwitch(
                    value: effects.throttleInBackground,
                    semanticLabel: 'Ограничение кадров',
                    onChanged: (v) => effects.throttleInBackground = v,
                  ),
                ),
              ],
            ),
          ),
          if (MediaQuery.disableAnimationsOf(context)) ...[
            const SizedBox(height: EvSpace.m),
            Text(
              'В системе включено «уменьшить движение» — атмосфера стоит '
              'неподвижным кадром, а игра запускается без ритуала, что бы '
              'здесь ни было выбрано.',
              style: ev.text.bodySmall.copyWith(color: ev.colors.ink4),
            ),
          ],
        ],
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
          'Остальные разделы — звук, библиотека, загрузки, раздача, '
          'сохранения, запуск, клавиши, «О программе» — и поиск по настройкам '
          'пока живут в макете design/evaporate-launcher.html.',
          style: ev.text.bodySmall.copyWith(color: ev.colors.ink4),
        ),
      ],
    );
  }
}
