import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../art/key_art.dart';
import '../data/game_facts.dart';
import '../data/sample_data.dart';
import '../friends/friends_data.dart';
import '../saves/saves_data.dart';
import '../widgets/ev_game_card.dart';

/// Год игры: 52 недели по 7 дней, в каждом дне — сколько часов сыграно,
/// от нуля до четырёх. Всё, что пишется под картой, считается из этой
/// же сетки, поэтому карта и числа не могут разойтись.
@immutable
class EvPlayYear {
  EvPlayYear(List<int> levels)
    : assert(levels.length == weeks * 7),
      levels = List.unmodifiable(levels);

  /// Год, как его рисует прототип: `rng32(20260914)`, зимой играют
  /// больше, по выходным — в полтора раза.
  factory EvPlayYear.sample(int seed) {
    final r = EvArtRandom(seed);
    return EvPlayYear([
      for (var w = 0; w < weeks; w++)
        for (var d = 0; d < 7; d++)
          _level(
            r.next() *
                (.55 + .45 * math.sin(w / weeks * 6.283 + 1.1)) *
                (d >= 5 ? 1.5 : 1),
          ),
    ]);
  }

  static const weeks = 52;

  /// Самый тёмный уровень — не играли, самый светлый — четыре часа.
  static const maxLevel = 4;

  static int _level(double v) => v < .2
      ? 0
      : v < .38
      ? 1
      : v < .56
      ? 2
      : v < .76
      ? 3
      : 4;

  /// Уровни по дням: неделя за неделей, внутри недели — с понедельника.
  final List<int> levels;

  int level(int week, int day) => levels[week * 7 + day];

  /// Дней, когда вообще играли.
  int get days => levels.where((l) => l > 0).length;

  /// Часов за год: уровень дня — это его часы.
  int get hours => levels.fold(0, (sum, l) => sum + l);

  /// Самая длинная серия дней подряд. Серия переходит через границу
  /// недели — воскресенье и следующий понедельник соседние дни.
  int get longestStreak {
    var best = 0, run = 0;
    for (final l in levels) {
      run = l > 0 ? run + 1 : 0;
      best = math.max(best, run);
    }
    return best;
  }
}

/// Что видят друзья. Четыре тумблера на своей странице — и то же самое,
/// что на чужой странице показывается скрытым, а не пропадает.
enum EvShare {
  playing('Во что я играю сейчас', 'Появляется в их разделе «Сейчас в игре»'),
  hours('Мои часы и достижения', 'Только друзьям, никогда публично'),
  seeding('Что я раздаю', 'Друзья смогут качать у вас напрямую'),
  byCode(
    'Находить меня по коду',
    'Выключите, и добавить вас сможет только тот, кому вы написали сами',
  );

  const EvShare(this.title, this.detail);

  final String title;
  final String detail;
}

/// Достижение, полученное недавно: какое из достижений игры и когда.
@immutable
class EvEarned {
  const EvEarned(this.game, this.index, this.when);

  final SampleGame game;

  /// Номер в [EvGameFacts.achievements] — в карточке игры оно же
  /// помечено полученным.
  final int index;

  /// «3 часа назад».
  final String when;

  String get name => EvGameFacts.achievements[index].$1;
}

/// Устройство и сколько на нём сыграно.
typedef EvDeviceHours = (EvDevice device, int hours);

/// Своя страница. Почти всё здесь выводится — из года игры, библиотеки,
/// друзей и устройств; руками написано только то, чего лаунчер про
/// прошлое не хранит по отдельности: часы до этого года и весь трафик.
@immutable
class EvProfile {
  const EvProfile({
    required this.name,
    required this.initials,
    required this.since,
    required this.code,
    required this.year,
    required this.hoursBefore,
    required this.uploadedGb,
    required this.receivedGb,
    required this.library,
    required this.people,
    required this.here,
    required this.away,
    required this.recent,
  });

  final String name;
  final String initials;

  /// «2 года 4 месяца».
  final String since;

  /// Код для друзей — тот, что вводят в «Друзья → Добавить по коду».
  final String code;

  final EvPlayYear year;

  /// Часов до последнего года.
  final int hoursBefore;

  /// Отдано и получено за всё время, ГБ: вместе с играми, которых уже
  /// нет в библиотеке, поэтому не меньше суммы по ней.
  final int uploadedGb;
  final int receivedGb;

  final List<SampleGame> library;
  final List<EvPerson> people;

  /// Этот компьютер. Его часы — остаток: всё, что сыграно не на других.
  final EvDevice here;

  /// Остальные устройства и их часы.
  final List<EvDeviceHours> away;

  final List<EvEarned> recent;

  /// Часов в играх за всё время: год и то, что было до него.
  int get hours => year.hours + hoursBefore;

  List<EvDeviceHours> get devices => [
    (here, hours - away.fold(0, (sum, d) => sum + d.$2)),
    ...away,
  ];

  int get installed =>
      library.where((g) => g.state == EvGameState.ready).length;

  /// Полученных достижений — сумма по карточкам игр.
  int get unlocked =>
      library.fold(0, (sum, g) => sum + EvGameFacts.of(g).unlocked);

  /// Всех достижений в библиотеке.
  int get achievements => library.length * EvGameFacts.achievements.length;

  /// Рейтинг раздачи: сколько вы вернули рою на каждый скачанный гигабайт.
  double get ratio => uploadedGb / receivedGb;

  /// Доля отданного во всём трафике, 0…1, — полоса под крупным числом.
  double get uploadShare => uploadedGb / (uploadedGb + receivedGb);

  /// Игры, в которые больше всего играли, по убыванию часов.
  List<SampleGame> top(int count) =>
      (library.where((g) => g.played > Duration.zero).toList()
            ..sort((a, b) => b.played.compareTo(a.played)))
          .take(count)
          .toList();

  /// Кому вы отдали больше всего.
  List<EvPerson> gaveMost(int count) =>
      (people.toList()..sort(
            (a, b) => b.traffic.fromYouGb.compareTo(a.traffic.fromYouGb),
          ))
          .take(count)
          .toList();
}
