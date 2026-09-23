import '../friends/friends_data.dart';
import '../design/tokens.dart';
import 'sample_data.dart';
import 'sample_downloads.dart';
import '../downloads/download_data.dart';

// Друзья — те же двенадцать, что в прототипе. Во что они играют, берётся
// из библиотеки, а сколько они раздают — с экрана загрузок: доля «от
// него» считается из скорости той же раздачи, а не пишется рядом.

SampleGame _game(String title) =>
    sampleLibrary.firstWhere((g) => g.title == title);

/// Шесть градиентов подряд, как `AV` в прототипе: соседние кружки
/// должны различаться, а не значить что-то.
const _tints = EvAvatarTint.values;

EvAvatarTint _tint(int i) => _tints[i % _tints.length];

final samplePeople = <EvPerson>[
  EvPerson(
    initials: 'АК',
    name: 'Антон К.',
    tint: _tint(0),
    common: 11,
    status: EvPersonStatus.playing,
    game: _game('Пепельный Предел'),
    session: '2 ч 14 мин · Глава 5',
  ),
  EvPerson(
    initials: 'МС',
    name: 'Мира С.',
    tint: _tint(1),
    common: 9,
    status: EvPersonStatus.playing,
    game: _game('Красный Меридиан'),
    session: '41 мин · Излом, ход 42',
  ),
  EvPerson(
    initials: 'ЛП',
    name: 'Лена П.',
    tint: _tint(2),
    common: 10,
    status: EvPersonStatus.playing,
    game: _game('Волчья Тропа'),
    session: '5 ч 02 мин · Чёрная река',
  ),
  EvPerson(
    initials: 'ДР',
    name: 'Дан Р.',
    tint: _tint(3),
    common: 6,
    status: EvPersonStatus.online,
  ),
  EvPerson(
    initials: 'НТ',
    name: 'Ника Т.',
    tint: _tint(4),
    common: 8,
    status: EvPersonStatus.online,
  ),
  EvPerson(
    initials: 'ЮС',
    name: 'Юля С.',
    tint: _tint(5),
    common: 5,
    status: EvPersonStatus.online,
  ),
  EvPerson(
    initials: 'ИВ',
    name: 'Игорь В.',
    tint: _tint(6),
    common: 9,
    was: 'был вчера в 22:10',
  ),
  EvPerson(
    initials: 'СМ',
    name: 'Саша М.',
    tint: _tint(7),
    common: 4,
    was: '3 дня назад',
  ),
  EvPerson(
    initials: 'РБ',
    name: 'Рома Б.',
    tint: _tint(8),
    common: 7,
    was: 'неделю назад',
  ),
  EvPerson(
    initials: 'МЛ',
    name: 'Марк Л.',
    tint: _tint(9),
    common: 2,
    was: 'месяц назад',
  ),
  EvPerson(
    initials: 'ВГ',
    name: 'Вера Г.',
    tint: _tint(10),
    common: 3,
    was: 'месяц назад',
  ),
  EvPerson(
    initials: 'ПК',
    name: 'Пётр К.',
    tint: _tint(11),
    common: 1,
    was: 'два месяца назад',
  ),
];

/// Кто раздаёт вам. Скорости сходятся с разделом «Загрузки»: 592 КБ/с
/// на «Орбиту», 1.03 МБ/с на «Эхо» — из них 1.34 МБ/с дают друзья.
List<EvSeeder> _seeders() {
  final queue = sampleDownloadsFor(EvDownloadsState.active);
  int rateOf(String title) =>
      queue.torrents.firstWhere((t) => t.game.title == title).downKb!;
  return [
    EvSeeder(
      person: samplePeople[0],
      game: _game('Орбита 7'),
      rateKb: 402,
      ofKb: rateOf('Орбита 7'),
    ),
    EvSeeder(
      person: samplePeople[5],
      game: _game('Хальцион: Эхо'),
      rateKb: 870,
      ofKb: rateOf('Хальцион: Эхо'),
    ),
    EvSeeder(
      person: samplePeople[4],
      game: _game('Орбита 7'),
      rateKb: 68,
      ofKb: rateOf('Орбита 7'),
    ),
  ];
}

final _feed = <EvFeedEntry>[
  EvFeedEntry(
    person: samplePeople[0],
    did: 'получил',
    what: '«Тихий шаг»',
    tail: ' в «Пепельном Пределе»',
    when: '3 часа назад',
    bright: true,
  ),
  EvFeedEntry(
    person: samplePeople[2],
    did: 'раздала вам',
    what: '14.2 ГБ',
    tail: ' за неделю',
    when: 'вчера',
  ),
  EvFeedEntry(
    person: samplePeople[1],
    did: 'начала',
    what: '«Красный Меридиан»',
    when: 'вчера в 21:10',
  ),
  EvFeedEntry(
    person: samplePeople[3],
    did: 'добавил',
    what: '«Стеклянный Сад»',
    tail: ' в библиотеку',
    when: '2 дня назад',
  ),
  EvFeedEntry(
    person: samplePeople[4],
    did: 'прошла',
    what: '«Глубину 9»',
    tail: ' на максимальной сложности',
    when: '3 дня назад',
    bright: true,
  ),
  EvFeedEntry(
    person: samplePeople[6],
    did: 'перестал раздавать',
    what: '«Волчью Тропу»',
    when: '5 дней назад',
  ),
];

/// Библиотека делится на три части целиком: 3 + 5 + 4 — это все
/// двенадцать игр, и восемь из них есть хотя бы у одного друга.
final _library = EvSharedLibrary(
  everyone: 3,
  half: 5,
  onlyYou: sampleLibrary.length - 8,
);

const _invite = EvInvite(
  initials: 'КЖ',
  name: 'Кирилл Ж. хочет добавиться',
  tint: EvAvatarTint.rose,
  detail: '3 общие игры · нашёл вас по коду · 12 минут назад',
);

/// Правая колонка библиотеки показывает четверых — тех же, что
/// в разделе «Друзья», и в том же порядке.
final sampleFriends = samplePeople.take(4).toList();

/// Сколько друзей в сети — выводится из списка, а не пишется рядом.
final sampleFriendsOnline = samplePeople
    .where((p) => p.status != EvPersonStatus.offline)
    .length;

/// Что показывает раздел. `offline` — состояние окна, а не раздела:
/// без сети друзья не видны и пиров от них нет.
EvFriends sampleFriendsFor(EvFriendsState state, {bool offline = false}) =>
    EvFriends(
      people: samplePeople,
      seeders: offline ? const [] : _seeders(),
      feed: _feed,
      library: _library,
      givenGb: '214 ГБ',
      invite: state == EvFriendsState.invite ? _invite : null,
      offline: offline,
    );
