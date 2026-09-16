import '../widgets/ev_game_card.dart';

// Пример содержимого. Движка раздач в приложении ещё нет, а пустой каркас
// не показывает, как он работает. Названия вымышленные, как в макетах;
// всё, что можно вывести из библиотеки, выводится из неё, а не пишется
// вторым числом рядом.

class SampleGame {
  const SampleGame(
    this.title,
    this.subtitle,
    this.palette,
    this.seed, {
    this.state = EvGameState.ready,
    this.progress,
    this.badge,
  });

  final String title;
  final String subtitle;
  final EvCoverPalette palette;
  final int seed;
  final EvGameState state;
  final double? progress;
  final String? badge;
}

const sampleLibrary = [
  SampleGame('Пепельный Предел', 'Action-RPG · 24 ч', EvCoverPalette.ash, 1207),
  SampleGame('Глубина 9', 'Хоррор · 6 ч', EvCoverPalette.deepSea, 9314),
  SampleGame(
    'Неон Хальцион',
    'Киберпанк · в очереди',
    EvCoverPalette.neon,
    4422,
    state: EvGameState.queued,
    badge: 'в очереди',
  ),
  SampleGame('Лунная Колея', 'Симулятор · 12 ч', EvCoverPalette.lunar, 7781),
  SampleGame(
    'Красный Меридиан',
    'Тактика · 31 ч',
    EvCoverPalette.crimson,
    2960,
  ),
  SampleGame(
    'Орбита 7',
    'Космосим · качается',
    EvCoverPalette.glass,
    8802,
    state: EvGameState.downloading,
    progress: 0.41,
    badge: '41 %',
  ),
];

/// Раздачи в работе: качаются и ждут очереди.
final sampleDownloadsActive = sampleLibrary
    .where((g) => g.state != EvGameState.ready)
    .length;

const sampleUserInitials = 'ВВ';
const sampleUserName = 'Виталий В.';
const sampleFriendsOnline = 6;
const sampleRate = '1.6 МБ/с';
