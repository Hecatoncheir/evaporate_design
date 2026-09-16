import 'package:flutter/widgets.dart';

import '../data/sample_data.dart';
import '../design/tokens.dart';
import '../util/plural.dart';
import '../widgets/ev_game_card.dart';
import '../widgets/ev_surfaces.dart';

/// Библиотека в каркасе: пока только полка. Герой с кнопкой запуска
/// переносится следующим — он требует шейдерного фона и ритуала запуска.
class LibraryPage extends StatelessWidget {
  const LibraryPage({super.key, required this.games});

  final List<SampleGame> games;

  @override
  Widget build(BuildContext context) {
    final window = MediaQuery.sizeOf(context);
    final gutter = EvSpace.gutterFor(window);
    // Ширина обложки растёт ступенями вместе с окном, как в прототипе.
    final cardWidth = window.width >= 2200
        ? 224.0
        : window.width >= 1800
        ? 206.0
        : 178.0;
    return ListView(
      primary: true,
      padding: EdgeInsets.fromLTRB(gutter, gutter, gutter, 26),
      children: [
        EvSectionHeader(
          'Все игры',
          count:
              '${games.length} ${ruPlural(games.length, 'игра', 'игры', 'игр')}',
        ),
        const SizedBox(height: EvSpace.xl),
        Wrap(
          spacing: EvSpace.l,
          runSpacing: EvSpace.xl,
          children: [
            for (final g in games)
              EvGameCard(
                title: g.title,
                subtitle: g.subtitle,
                palette: g.palette,
                seed: g.seed,
                state: g.state,
                progress: g.progress,
                badge: g.badge,
                width: cardWidth,
              ),
          ],
        ),
      ],
    );
  }
}
