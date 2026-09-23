import 'package:flutter/material.dart';

import 'data/sample_data.dart';
import 'data/sample_downloads.dart';
import 'design/appearance.dart';
import 'design/effects.dart';
import 'design/theme.dart';
import 'design/tokens.dart';
import 'downloads/download_data.dart';
import 'launch/ev_launch_ritual.dart';
import 'library/hero_state.dart';
import 'sheet/ev_game_sheet.dart';
import 'screens/downloads_page.dart';
import 'screens/library_page.dart';
import 'screens/placeholder_page.dart';
import 'screens/settings_page.dart';
import 'shell/ev_palette.dart';
import 'shell/ev_section.dart';
import 'shell/ev_shell.dart';
import 'util/units.dart';
import 'widgets/ev_game_card.dart';
import 'widgets/ev_icon.dart';
import 'widgets/ev_surfaces.dart';

void main() => runApp(const EvaporateApp());

class EvaporateApp extends StatefulWidget {
  const EvaporateApp({super.key, this.effects});

  /// Эффекты атмосферы. Не задано — приложение заводит свои, всё включено.
  /// Тесты передают [EvEffects.still], чтобы кадры не шли бесконечно.
  final EvEffects? effects;

  @override
  State<EvaporateApp> createState() => _EvaporateAppState();
}

class _EvaporateAppState extends State<EvaporateApp> {
  final _appearance = EvAppearance();
  // Движка нет, а состояния продукта есть: их переключает «Разработка»
  // в настройках — как панель состояний в прототипе.
  final _state = ValueNotifier<EvHeroState>(EvHeroState.ready);
  final _downloads = ValueNotifier<EvDownloadsState>(EvDownloadsState.active);
  late final _ownEffects = widget.effects == null ? EvEffects() : null;
  final _shell = EvShellController();

  EvEffects get _effects => widget.effects ?? _ownEffects!;

  /// Состояние игры и состояние очереди — разные вещи, но «нет сети» —
  /// свойство окна, и его видят оба. Поэтому офлайн ходит парой: включить
  /// его с одной стороны — значит включить с обеих.
  void _setHero(EvHeroState next) {
    _state.value = next;
    if (next == EvHeroState.offline) {
      _downloads.value = EvDownloadsState.offline;
    } else if (_downloads.value == EvDownloadsState.offline) {
      _downloads.value = EvDownloadsState.active;
    }
  }

  void _setDownloads(EvDownloadsState next) {
    _downloads.value = next;
    if (next == EvDownloadsState.offline) {
      _state.value = EvHeroState.offline;
    } else if (_state.value == EvHeroState.offline) {
      _state.value = EvHeroState.ready;
    }
  }

  @override
  void dispose() {
    _downloads.dispose();
    _state.dispose();
    _appearance.dispose();
    _ownEffects?.dispose();
    _shell.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return EvAppearanceScope(
      appearance: _appearance,
      child: EvEffectsScope(
        effects: _effects,
        child: ListenableBuilder(
          listenable: _appearance,
          builder: (context, _) => MaterialApp(
            title: 'Evaporate',
            debugShowCheckedModeBanner: false,
            // Тема одна — тёмная, по требованию продукта.
            theme: _appearance.theme,
            themeAnimationDuration: EvMotion.screen,
            themeAnimationCurve: EvMotion.easeOut,
            home: ListenableBuilder(
              listenable: Listenable.merge([_state, _downloads]),
              builder: (context, _) => _Home(
                shell: _shell,
                state: _state.value,
                onState: _setHero,
                downloads: _downloads.value,
                onDownloads: _setDownloads,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Home extends StatelessWidget {
  const _Home({
    required this.shell,
    required this.state,
    required this.onState,
    required this.downloads,
    required this.onDownloads,
  });

  final EvShellController shell;

  /// Состояние игры в герое — одно на окно: его читают герой, плашки
  /// в верхней полосе и полоса действий в карточке игры.
  final EvHeroState state;

  final ValueChanged<EvHeroState> onState;

  /// Состояние очереди раздач — одно на окно: его видят раздел
  /// «Загрузки» и плашки в верхней полосе.
  final EvDownloadsState downloads;

  final ValueChanged<EvDownloadsState> onDownloads;

  /// Запуск игры — ритуал поверх всего окна.
  static void _launch(BuildContext context, SampleGame game) =>
      showEvLaunchRitual(
        context,
        title: game.title,
        stages: sampleLaunchStages,
      );

  /// Карточка игры. Запуск из неё — тот же ритуал, а полоса действий
  /// в ней читает состояние окна — как `cardState` в прототипе.
  void _open(BuildContext context, SampleGame game) => showEvGameSheet(
    context,
    game: game,
    state: game == sampleHero ? state : null,
    onLaunch: () => _launch(context, game),
    onInstall: () => onState(EvHeroState.installing),
    onQuit: () => onState(EvHeroState.ready),
  );

  /// Плашки верхней полосы читают оба состояния окна. Левая — всегда
  /// приём, и он складывается из раздач, а не пишется отдельным числом.
  List<EvPill> _pills(EvDownloads queue) => switch (state) {
    EvHeroState.offline => const [
      EvPill('Нет сети', status: EvStatus.idle),
      EvPill('Движок на паузе', status: EvStatus.idle),
    ],
    // Пока игра идёт, приём ограничен, чтобы не отнимать у неё сеть.
    EvHeroState.running => [
      EvPill(formatRate(1024, digits: 1), status: EvStatus.busy),
      const EvPill('Игра запущена'),
    ],
    _ => [
      EvPill(
        formatRate(queue.downKb, digits: 1),
        status: queue.downKb == 0 ? EvStatus.idle : EvStatus.busy,
      ),
      switch (downloads) {
        EvDownloadsState.noSeeds => const EvPill(
          'Нет раздающих',
          status: EvStatus.warn,
        ),
        EvDownloadsState.noSpace => const EvPill(
          'Диск переполнен',
          status: EvStatus.bad,
        ),
        EvDownloadsState.hash => const EvPill(
          'Перепроверка',
          status: EvStatus.busy,
        ),
        EvDownloadsState.empty => const EvPill(
          'Движок простаивает',
          status: EvStatus.idle,
        ),
        _ => const EvPill('Движок готов'),
      },
    ],
  };

  @override
  Widget build(BuildContext context) {
    final appearance = EvAppearanceScope.of(context);
    final queue = sampleDownloadsFor(downloads);
    return EvShell(
      controller: shell,
      initials: sampleUserInitials,
      userName: sampleUserName,
      friendsOnline: sampleFriendsOnline,
      downloadsActive: queue.torrents.length,
      status: _pills(queue),
      commands: [
        for (final g in sampleLibrary)
          EvCommand(
            title: g.title,
            subtitle: g.subtitle,
            cover: (g.palette, g.seed),
            hint: '↵ открыть',
            onRun: () => _open(context, g),
            // Запускать можно только то, что уже на диске; остальное ведёт
            // туда, где оно качается, — как «Стена» и «Пульт» в прототипе.
            onLaunch: g.state == EvGameState.ready
                ? () => _launch(context, g)
                : () => shell.go(EvSection.downloads),
          ),
        for (final s in EvSection.values)
          EvCommand(
            title: s.label,
            subtitle: 'раздел · клавиша ${s.hotkey}',
            icon: s.icon,
            hint: '↵ открыть',
            onRun: () => shell.go(s),
          ),
        for (final s in EvSkin.values)
          EvCommand(
            title: 'Сменить тему на ${s.label}',
            subtitle: 'команда · ${s.hint}',
            icon: EvIcons.settings,
            onRun: () => appearance.skin = s,
          ),
        for (final g in EvGeometry.values)
          EvCommand(
            title: 'Радиус скругления · ${g.label}',
            subtitle: 'команда · потолок радиуса',
            icon: EvIcons.settings,
            onRun: () => appearance.geometry = g,
          ),
      ],
      pageBuilder: (context, section) => switch (section) {
        EvSection.library => LibraryPage(
          state: state,
          onInstall: () => onState(EvHeroState.installing),
          onQuit: () => onState(EvHeroState.ready),
          games: sampleLibrary,
          hero: sampleHero,
          sessions: sampleSessions,
          friends: sampleFriends,
          friendsOnline: sampleFriendsOnline,
          downloadSlots: sampleDownloadSlots,
          onLaunch: (g) => _launch(context, g),
          onOpen: (g) => _open(context, g),
        ),
        EvSection.downloads => DownloadsPage(downloads: queue),
        EvSection.settings => SettingsPage(
          state: state,
          onState: onState,
          downloads: downloads,
          onDownloads: onDownloads,
        ),
        _ => PlaceholderPage(section: section),
      },
    );
  }
}
