import '../art/key_art.dart';
import '../launch/ev_launch_ritual.dart';
import '../library/ev_side_cards.dart';
import '../util/units.dart';
import '../widgets/ev_game_card.dart';

// Пример содержимого. Движка раздач в приложении ещё нет, а пустой каркас
// не показывает, как он работает. Каталог — тот же, что в прототипе:
// названия вымышленные, сиды те же, поэтому и обложки те же. Всё, что можно
// вывести из библиотеки, выводится из неё, а не пишется вторым числом рядом.

class SampleGame {
  const SampleGame(
    this.title,
    this.genre,
    this.palette,
    this.seed, {
    required this.version,
    required this.size,
    required this.blurb,
    this.tags = const [],
    this.state = EvGameState.ready,
    this.played = Duration.zero,
    this.lastPlayed,
    this.progress,
    this.rateKb,
    this.checking = false,
    this.isNew = false,
  });

  final String title;
  final String genre;
  final EvCoverPalette palette;
  final int seed;

  /// «v2.4.1» или «DLC».
  final String version;

  /// «68.4 ГБ».
  final String size;

  final String blurb;

  /// Жанр и режим для чипов героя: «Action-RPG», «Одиночная».
  final List<String> tags;

  final EvGameState state;

  /// Сколько сыграно.
  final Duration played;

  /// Когда закончилась последняя сессия: «вчера в 23:40».
  final String? lastPlayed;

  /// Загрузка: 0…1.
  final double? progress;

  /// Скорость приёма, КБ/с.
  final int? rateKb;

  /// Загрузка сверяет части — полоса цвета данных.
  final bool checking;

  /// Появилась в библиотеке недавно.
  final bool isNew;

  /// Подпись на полке: «Action-RPG · 24 ч».
  String get subtitle => switch (state) {
    EvGameState.ready => '$genre · ${played.inHours} ч',
    EvGameState.downloading => '$genre · качается',
    EvGameState.queued => '$genre · в очереди',
  };

  String? get badge => switch (state) {
    EvGameState.ready => isNew ? 'новое' : null,
    EvGameState.downloading => '${percent(progress ?? 0)} %',
    EvGameState.queued => 'в очереди',
  };

  /// Чипы героя: состояние, версия, размер и метки.
  List<(String, bool)> get chips => [
    (
      switch (state) {
        EvGameState.ready => 'Установлена',
        EvGameState.downloading => 'Качается',
        EvGameState.queued => 'В очереди',
      },
      true,
    ),
    (version, false),
    (size, false),
    for (final tag in tags) (tag, false),
  ];
}

const sampleLibrary = [
  SampleGame(
    'Пепельный Предел',
    'Action-RPG',
    EvCoverPalette.ash,
    1207,
    version: 'v2.4.1',
    size: '68.4 ГБ',
    tags: ['Action-RPG', 'Одиночная'],
    played: Duration(hours: 24, minutes: 10),
    lastPlayed: '6 минут назад',
    blurb:
        'Пятая глава разблокирована. Ваш отряд ждёт у Кузни Сумерек — '
        'последнее сохранение синхронизировано 6 минут назад.',
  ),
  SampleGame(
    'Глубина 9',
    'Хоррор',
    EvCoverPalette.deepSea,
    9314,
    version: 'v1.7',
    size: '41.2 ГБ',
    tags: ['Выживание', 'Одиночная'],
    played: Duration(hours: 6),
    lastPlayed: 'вчера в 23:40',
    blurb:
        'Станция «Мерло» затоплена до шестого уровня. Кислорода на '
        '41 минуту — этого хватит ровно на один правильный маршрут.',
  ),
  SampleGame(
    'Неон Хальцион',
    'Киберпанк',
    EvCoverPalette.neon,
    4422,
    state: EvGameState.queued,
    version: 'v1.9',
    size: '24.1 ГБ',
    tags: ['Открытый мир'],
    blurb:
        'Открытый мир на 40 часов. Сеть города живая: каждая вышка, '
        'которую вы перехватываете, меняет расписание патрулей.',
  ),
  SampleGame(
    'Лунная Колея',
    'Исследование',
    EvCoverPalette.lunar,
    7781,
    version: 'v3.0',
    size: '18.9 ГБ',
    tags: ['Симулятор'],
    played: Duration(hours: 12),
    blurb:
        'Тихая колонизация без единого выстрела. Стройте маршруты между '
        'куполами и слушайте, как реголит скрипит под шасси.',
  ),
  SampleGame(
    'Красный Меридиан',
    'Тактика',
    EvCoverPalette.crimson,
    2960,
    version: 'v2.2',
    size: '22.6 ГБ',
    tags: ['Тактика', 'Кооп'],
    played: Duration(hours: 31),
    lastPlayed: 'вчера в 21:15',
    blurb:
        'Пошаговые бои на изломе фронта. Каждый выживший боец переносит '
        'шрамы и привычки в следующую кампанию.',
  ),
  SampleGame(
    'Стеклянный Сад',
    'Головоломка',
    EvCoverPalette.glass,
    5518,
    version: 'v1.4',
    size: '7.3 ГБ',
    tags: ['Головоломка'],
    played: Duration(hours: 4),
    blurb:
        'Сто двадцать комнат, выращенных из света. Ни одной подсказки — '
        'только то, что вы успели заметить.',
  ),
  SampleGame(
    'Волчья Тропа',
    'Открытый мир',
    EvCoverPalette.wolf,
    3345,
    version: 'v4.1',
    size: '92.7 ГБ',
    tags: ['Выживание'],
    played: Duration(hours: 58),
    lastPlayed: 'вчера в 19:05',
    blurb:
        'Тайга размером с область, без маркеров на карте. Ориентируйтесь '
        'по звёздам, дыму и следам на снегу.',
  ),
  SampleGame(
    'Орбита 7',
    'Космосим',
    EvCoverPalette.orbit,
    8802,
    state: EvGameState.downloading,
    progress: .41,
    rateKb: 592,
    version: 'v5.2',
    size: '36.0 ГБ',
    tags: ['Симулятор'],
    blurb:
        'Семь станций на разных высотах. Топливо конечно, окно стыковки — '
        '90 секунд, а напарник дышит вам в наушник.',
  ),
  SampleGame(
    'Тихий Порог',
    'История',
    EvCoverPalette.threshold,
    6127,
    version: 'v1.1',
    size: '11.8 ГБ',
    tags: ['Нарратив'],
    played: Duration(hours: 9),
    isNew: true,
    blurb:
        'Один дом, одна ночь, шесть голосов. Всё, что вы решите не '
        'открывать, останется закрытым навсегда.',
  ),
  SampleGame(
    'Грозовой Фронт',
    'Гонки',
    EvCoverPalette.storm,
    1993,
    version: 'v2.0',
    size: '53.4 ГБ',
    tags: ['Гонки'],
    played: Duration(hours: 17),
    blurb:
        'Трассы переписывает погода. Сухая линия исчезает на втором круге, '
        'и держаться приходится за то, чего уже нет.',
  ),
  SampleGame(
    'Хальцион: Эхо',
    'Дополнение',
    EvCoverPalette.neon,
    2211,
    state: EvGameState.downloading,
    progress: .66,
    rateKb: 1030,
    checking: true,
    version: 'DLC',
    size: '9.4 ГБ',
    blurb:
        'Сюжетное дополнение на 12 часов: подземные уровни сети и новая '
        'ветка финала.',
  ),
  SampleGame(
    'Перигей',
    'Дополнение',
    EvCoverPalette.orbit,
    4747,
    state: EvGameState.queued,
    version: 'DLC',
    size: '6.8 ГБ',
    blurb:
        'Низкие орбиты, высокая цена ошибки. Четыре новые станции и режим '
        '«без сохранений».',
  ),
];

/// Игра, на которой вы остановились, — она в герое. Каталог идёт от
/// последней запущенной.
final sampleHero = sampleLibrary.first;

/// Недавние сессии для «Продолжить» — кроме той, что в герое.
final sampleSessions = [
  for (final g in sampleLibrary)
    if (g.lastPlayed != null && g != sampleHero) g,
];

/// Раздачи, которые качаются прямо сейчас.
final sampleDownloading = [
  for (final g in sampleLibrary)
    if (g.state == EvGameState.downloading) g,
];

/// Сколько раздач качается сразу.
const sampleDownloadSlots = 3;

/// Приём — сумма скоростей активных раздач.
final sampleRateKb = sampleDownloading.fold(0, (sum, g) => sum + g.rateKb!);

final sampleDownloadsActive = sampleDownloading.length;

/// Стадии ритуала запуска и строки журнала под полосой — те же, что
/// в прототипе, для любой игры. Числа — пример: стадии будет называть
/// движок, когда он появится.
const List<EvLaunchStage> sampleLaunchStages = [
  ('Подготовка среды', 'монтирование тома…'),
  ('Проверка файлов', 'проверка целостности 118 421 файла'),
  ('Графический слой', 'инициализация графического слоя'),
  ('Шейдерный кэш', 'загрузка шейдерного кэша · 2 148'),
  ('Облако сохранений', 'синхронизация сохранений с облаком'),
  ('Запуск', 'передача управления'),
];

const sampleUserInitials = 'ВВ';
const sampleUserName = 'Виталий В.';
const sampleFriendsOnline = 6;

const sampleFriends = [
  EvFriendLine('АК', 'Антон К.', 'Пепельный Предел', EvAvatarTint.hot),
  EvFriendLine('МС', 'Мира С.', 'Красный Меридиан', EvAvatarTint.cool),
  EvFriendLine('ДР', 'Дан Р.', 'в сети', EvAvatarTint.arc),
  EvFriendLine('ЛП', 'Лена П.', 'Волчья Тропа', EvAvatarTint.ok),
];
