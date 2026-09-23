import 'package:flutter/material.dart';

import '../design/appearance.dart';
import '../design/effects.dart';
import '../design/theme.dart';
import '../design/tokens.dart';
import '../downloads/download_data.dart';
import '../gallery/gallery_page.dart';
import '../glass/glass_lens.dart';
import '../library/hero_state.dart';
import '../friends/friends_data.dart';
import '../saves/saves_data.dart';
import '../widgets/ev_focusable.dart';
import '../widgets/ev_controls.dart';
import '../widgets/ev_icon.dart';
import '../widgets/ev_surfaces.dart';

/// Настройки в каркасе: облик и вход в галерею компонентов. Полный экран —
/// десять разделов, поиск по настройкам, расписание — пока в макете.
class SettingsPage extends StatelessWidget {
  const SettingsPage({
    super.key,
    required this.state,
    required this.onState,
    required this.downloads,
    required this.onDownloads,
    required this.saves,
    required this.onSaves,
    required this.friendsState,
    required this.onFriends,
  });

  /// Состояние игры в герое. Движка нет, поэтому его переключают здесь.
  final EvHeroState state;

  final ValueChanged<EvHeroState> onState;

  /// Состояние очереди раздач — по тем же причинам и рядом.
  final EvDownloadsState downloads;

  final ValueChanged<EvDownloadsState> onDownloads;

  /// Состояние облака сохранений — по тем же причинам и рядом.
  final EvSavesState saves;

  final ValueChanged<EvSavesState> onSaves;

  /// Состояние раздела «Друзья» — по тем же причинам и рядом.
  final EvFriendsState friendsState;

  final ValueChanged<EvFriendsState> onFriends;

  @override
  Widget build(BuildContext context) {
    final ev = context.ev;
    final appearance = EvAppearanceScope.of(context);
    final effects = EvEffectsScope.maybeOf(context);
    final gutter = EvSpace.gutterFor(MediaQuery.sizeOf(context));
    final chrome = MediaQuery.paddingOf(context);
    return ListView(
      primary: true,
      padding: EdgeInsets.fromLTRB(
        gutter,
        chrome.top + gutter,
        gutter,
        26 + chrome.bottom,
      ),
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
                  title: 'Стекло',
                  description: 'Рейл, полосы и панели размывают фон под собой',
                  control: EvSwitch(
                    value: effects.glass,
                    semanticLabel: 'Стекло',
                    onChanged: (v) => effects.glass = v,
                  ),
                ),
                EvOption(
                  title: 'Преломление стекла',
                  description: EvGlassLens.supported
                      ? 'Кадр под кромкой гнётся, как под толстым стеклом'
                      : 'Кадр гнётся у кромки · нужен Impeller, '
                            'в этой сборке недоступно',
                  control: EvSwitch(
                    value: effects.refraction && EvGlassLens.supported,
                    semanticLabel: 'Преломление',
                    onChanged: EvGlassLens.supported
                        ? (v) => effects.refraction = v
                        : (_) {},
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              EvOption(
                title: 'Состояние библиотеки',
                description:
                    'Движка ещё нет: состояния героя переключаются здесь. '
                    'В прототипе это панель «Состояния», в продукте её нет',
                control: const SizedBox.shrink(),
              ),
              for (final (value, name, hint) in _states)
                _StateRow(
                  name: name,
                  hint: hint,
                  selected: value == state,
                  onTap: () => onState(value),
                ),
            ],
          ),
        ),
        const SizedBox(height: EvSpace.m),
        EvPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              EvOption(
                title: 'Состояние загрузок',
                description:
                    'Шесть состояний очереди. «Сеть пропала» — состояние '
                    'окна: его же увидит герой',
                control: const SizedBox.shrink(),
              ),
              for (final value in EvDownloadsState.values)
                _StateRow(
                  name: value.label,
                  hint: value.hint,
                  selected: value == downloads,
                  onTap: () => onDownloads(value),
                ),
            ],
          ),
        ),
        const SizedBox(height: EvSpace.m),
        EvPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              EvOption(
                title: 'Состояние сохранений',
                description:
                    'Облако, лента и расхождение версий. Разрешить конфликт '
                    'можно по-настоящему — любой из трёх кнопок',
                control: const SizedBox.shrink(),
              ),
              for (final value in EvSavesState.values)
                _StateRow(
                  name: value.label,
                  hint: value.hint,
                  selected: value == saves,
                  onTap: () => onSaves(value),
                ),
            ],
          ),
        ),
        const SizedBox(height: EvSpace.m),
        EvPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              EvOption(
                title: 'Состояние друзей',
                description:
                    'Заявку можно принять по-настоящему. «Нет сети» здесь '
                    'нет: это состояние окна, из библиотеки',
                control: const SizedBox.shrink(),
              ),
              for (final value in EvFriendsState.values)
                _StateRow(
                  name: value.label,
                  hint: value.hint,
                  selected: value == friendsState,
                  onTap: () => onFriends(value),
                ),
            ],
          ),
        ),
        const SizedBox(height: EvSpace.m),
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

  /// Те же состояния и подписи, что в панели прототипа.
  static const _states = [
    (EvHeroState.ready, 'Обычное состояние', 'установлена, можно играть'),
    (
      EvHeroState.notInstalled,
      'Не установлена',
      'есть в аккаунте, нет на диске',
    ),
    (EvHeroState.update, 'Есть обновление', 'патч 2.4.2 · 1.8 ГБ'),
    (EvHeroState.installing, 'Идёт установка', 'распаковка 41 %'),
    (EvHeroState.running, 'Игра запущена', 'кнопка стала статусом'),
    (EvHeroState.offline, 'Нет сети', 'локальное живёт, сетевое нет'),
  ];
}

/// Строка списка состояний: точка, название и чем это состояние
/// отличается.
class _StateRow extends StatefulWidget {
  const _StateRow({
    required this.name,
    required this.hint,
    required this.selected,
    required this.onTap,
  });

  final String name;
  final String hint;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_StateRow> createState() => _StateRowState();
}

class _StateRowState extends State<_StateRow> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final ev = context.ev;
    final c = ev.colors;
    final lit = widget.selected || _hover;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: EvFocusable(
        onActivate: widget.onTap,
        radius: ev.radii.r2,
        child: Semantics(
          button: true,
          selected: widget.selected,
          child: GestureDetector(
            onTap: widget.onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
              decoration: BoxDecoration(
                borderRadius: ev.radii.b2,
                color: _hover ? c.ink.withValues(alpha: .04) : null,
              ),
              child: Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.selected ? c.hot2 : c.line,
                      boxShadow: widget.selected
                          ? [BoxShadow(color: c.hot2, blurRadius: 8)]
                          : null,
                    ),
                  ),
                  const SizedBox(width: 11),
                  Text(
                    widget.name,
                    style: ev.text.body.copyWith(
                      fontSize: 13,
                      color: lit ? c.ink : c.ink2,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.hint,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                      style: ev.text.data.copyWith(
                        fontSize: 10.5,
                        color: c.ink4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
