import 'package:flutter/material.dart';

import 'data/sample_data.dart';
import 'design/appearance.dart';
import 'design/effects.dart';
import 'design/theme.dart';
import 'design/tokens.dart';
import 'screens/library_page.dart';
import 'screens/placeholder_page.dart';
import 'screens/settings_page.dart';
import 'shell/ev_palette.dart';
import 'shell/ev_section.dart';
import 'shell/ev_shell.dart';
import 'util/units.dart';
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
  late final _ownEffects = widget.effects == null ? EvEffects() : null;
  final _shell = EvShellController();

  EvEffects get _effects => widget.effects ?? _ownEffects!;

  @override
  void dispose() {
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
            home: _Home(shell: _shell),
          ),
        ),
      ),
    );
  }
}

class _Home extends StatelessWidget {
  const _Home({required this.shell});

  final EvShellController shell;

  @override
  Widget build(BuildContext context) {
    final appearance = EvAppearanceScope.of(context);
    return EvShell(
      controller: shell,
      initials: sampleUserInitials,
      userName: sampleUserName,
      friendsOnline: sampleFriendsOnline,
      downloadsActive: sampleDownloadsActive,
      status: [
        EvPill(formatRate(sampleRateKb, digits: 1), status: EvStatus.busy),
        const EvPill('Движок готов'),
      ],
      commands: [
        for (final g in sampleLibrary)
          EvCommand(
            title: g.title,
            subtitle: g.subtitle,
            cover: (g.palette, g.seed),
            hint: '↵ к полке',
            onRun: () => shell.go(EvSection.library),
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
          games: sampleLibrary,
          hero: sampleHero,
          sessions: sampleSessions,
          friends: sampleFriends,
          friendsOnline: sampleFriendsOnline,
          downloadSlots: sampleDownloadSlots,
        ),
        EvSection.settings => const SettingsPage(),
        _ => PlaceholderPage(section: section),
      },
    );
  }
}
