import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../art/ev_art.dart';
import '../data/game_facts.dart';
import '../data/sample_data.dart';
import '../design/theme.dart';
import '../design/tokens.dart';
import '../friends/ev_avatar.dart';
import '../util/units.dart';
import '../widgets/ev_focusable.dart';
import '../widgets/ev_icon.dart';
import '../widgets/ev_surfaces.dart';

/// Содержимое карточки: описание и четыре блока данных, которых нет ни
/// в одном магазине, потому что их знает только лаунчер, — плюс правая
/// колонка с раздачей, сохранением, друзьями и списком глаголов.
///
/// От 900 px колонки идут рядом, уже — друг под другом, как в прототипе.
class EvSheetBody extends StatelessWidget {
  const EvSheetBody({
    super.key,
    required this.game,
    required this.facts,
    required this.window,
  });

  final SampleGame game;
  final EvGameFacts facts;
  final Size window;

  @override
  Widget build(BuildContext context) {
    final ev = context.ev;
    final gap = (window.width * .024).clamp(20.0, 30.0);
    final blurb = ev.text.body.copyWith(fontSize: 14);
    final main = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 64 * evCharWidth(blurb)),
          child: Text(game.blurb, style: blurb),
        ),
        const SizedBox(height: 24),
        _History(facts: facts),
        const SizedBox(height: 26),
        _Achievements(facts: facts),
        const SizedBox(height: 26),
        _Parts(facts: facts),
      ],
    );
    final side = _SideColumn(game: game, facts: facts);

    if (window.width < 900) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          main,
          SizedBox(height: gap),
          side,
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: main),
        SizedBox(width: gap),
        SizedBox(width: 300, child: side),
      ],
    );
  }
}

/// Заголовок блока: подпись капсом, линия в никуда и значение справа.
class _BlockHeader extends StatelessWidget {
  const _BlockHeader(this.label, {this.value, this.strong});

  final String label;

  /// Значение справа; [strong] — его горячая часть в начале.
  final String? value;
  final String? strong;

  @override
  Widget build(BuildContext context) {
    final ev = context.ev;
    final c = ev.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(
            label.toUpperCase(),
            style: ev.text.dsp(
              ev.text.section,
              weight: FontWeight.w600,
              size: 10.5,
              letterSpacing: 2.1,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [c.line, c.line.withValues(alpha: 0)],
                ),
              ),
            ),
          ),
          if (value != null || strong != null) ...[
            const SizedBox(width: 12),
            Text.rich(
              TextSpan(
                children: [
                  if (strong != null)
                    TextSpan(
                      text: strong,
                      style: ev.text.mono(
                        ev.text.data,
                        weight: FontWeight.w500,
                        size: 11,
                        color: c.hot2,
                      ),
                    ),
                  if (value != null)
                    TextSpan(
                      text: value,
                      style: ev.text.data.copyWith(fontSize: 11, color: c.ink3),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Ваша история: часы всего, последняя сессия и семь столбиков с пиком.
/// Пока игру не запускали, вместо графика — честная строка.
class _History extends StatelessWidget {
  const _History({required this.facts});

  final EvGameFacts facts;

  @override
  Widget build(BuildContext context) {
    final ev = context.ev;
    final c = ev.colors;
    final played = facts.hours > 0;
    final big = (MediaQuery.sizeOf(context).width * .034).clamp(28.0, 40.0);
    final key = ev.text.data.copyWith(
      fontSize: 10,
      letterSpacing: 1.6,
      color: c.ink4,
    );

    Widget column(Widget value, String label) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        value,
        const SizedBox(height: 7),
        Text(label.toUpperCase(), style: key),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _BlockHeader(
          'Ваша история',
          value: played ? 'последние 7 сессий' : null,
        ),
        Wrap(
          spacing: (MediaQuery.sizeOf(context).width * .03).clamp(18.0, 34.0),
          runSpacing: 18,
          crossAxisAlignment: WrapCrossAlignment.end,
          children: played
              ? [
                  column(
                    Text(
                      '${facts.hours} ч',
                      style: ev.text
                          .big(big)
                          .copyWith(letterSpacing: big * -.03),
                    ),
                    'всего в игре',
                  ),
                  column(
                    Text(
                      '${facts.lastMinutes ~/ 60} ч ${facts.lastMinutes % 60} мин',
                      style: ev.text.body.copyWith(fontSize: 15, color: c.ink),
                    ),
                    'последняя · ${facts.lastAgo}',
                  ),
                  SizedBox(
                    width: 250,
                    child: _SessionChart(sessions: facts.sessions),
                  ),
                ]
              : [
                  column(
                    Text('—', style: ev.text.big(big)),
                    'ещё не запускали',
                  ),
                  column(
                    Text(
                      'История появится после первого запуска',
                      style: ev.text.body.copyWith(
                        fontSize: 13.5,
                        color: c.ink3,
                      ),
                    ),
                    'сессии · достижения · часы',
                  ),
                ],
        ),
      ],
    );
  }
}

/// Семь столбиков последних сессий. Пик подсвечен — это и есть история,
/// а не украшение: видно, когда в игру играли всерьёз.
class _SessionChart extends StatelessWidget {
  const _SessionChart({required this.sessions});

  final List<int> sessions;

  @override
  Widget build(BuildContext context) {
    final ev = context.ev;
    final c = ev.colors;
    final peak = math.max(1, sessions.reduce(math.max));
    final top = sessions.indexOf(peak);
    // Подпись дня лежит внутри тех же 62 px, что и столбики: в CSS
    // столбик — доля высоты колонки и ужимается под подпись.
    const label = 13.5, gap = 6.0, chart = 62.0;
    return SizedBox(
      height: chart,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final (i, minutes) in sessions.indexed) ...[
            if (i > 0) const SizedBox(width: 5),
            Expanded(
              child: Semantics(
                label: '${EvGameFacts.days[i]}: $minutes мин',
                excludeSemantics: true,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      height: (minutes / peak * chart).clamp(
                        6,
                        chart - gap - label,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(3),
                          bottom: Radius.circular(1),
                        ),
                        color: i == top ? null : c.ink.withValues(alpha: .1),
                        gradient: i == top
                            ? LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [c.hot2, c.hot1],
                              )
                            : null,
                        boxShadow: i == top
                            ? [
                                BoxShadow(
                                  color: c.hot1.withValues(alpha: .5),
                                  blurRadius: 14,
                                ),
                              ]
                            : null,
                      ),
                    ),
                    const SizedBox(height: gap),
                    SizedBox(
                      height: label,
                      child: Text(
                        EvGameFacts.days[i],
                        style: ev.text.data.copyWith(
                          fontSize: 9,
                          height: 1.5,
                          color: c.ink4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Достижения: общая полоса, ближайшее отдельной плашкой и сетка из пяти.
class _Achievements extends StatelessWidget {
  const _Achievements({required this.facts});

  final EvGameFacts facts;

  @override
  Widget build(BuildContext context) {
    final ev = context.ev;
    final c = ev.colors;
    final all = EvGameFacts.achievements.length;
    final part = facts.unlocked / all;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _BlockHeader(
          'Достижения',
          strong: '${facts.unlocked}',
          value: ' из $all · ${percent(part)} %',
        ),
        ClipRRect(
          borderRadius: ev.radii.bPill,
          child: SizedBox(
            height: 5,
            child: Stack(
              fit: StackFit.expand,
              children: [
                ColoredBox(color: c.ink.withValues(alpha: .07)),
                FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: part,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [c.hotDeep, c.hot2]),
                      boxShadow: [
                        BoxShadow(
                          color: c.hot1.withValues(alpha: .5),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        if (facts.unlocked > 0) ...[_Nearest(), const SizedBox(height: 12)],
        LayoutBuilder(
          builder: (context, box) {
            final columns = math.max(1, (box.maxWidth + 6) ~/ 196);
            return Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final (i, (name, rule))
                    in EvGameFacts.achievements.indexed)
                  SizedBox(
                    width: (box.maxWidth - 6 * (columns - 1)) / columns,
                    child: _Achievement(
                      name: name,
                      rule: rule,
                      unlocked: i < facts.unlocked,
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

/// Ближайшее достижение — единственное, к которому лаунчер знает путь.
class _Nearest extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ev = context.ev;
    final c = ev.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      decoration: BoxDecoration(
        borderRadius: ev.radii.b3,
        border: Border.all(color: c.hot1.withValues(alpha: .3)),
        color: c.hot1.withValues(alpha: .06),
      ),
      child: Row(
        children: [
          _TrophyIcon(unlocked: true, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Ближе всего: Собиратель',
                  style: ev.text.ui(
                    ev.text.body,
                    weight: FontWeight.w500,
                    size: 13,
                    color: c.ink,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '37 из 60 реликвий · осталось 23',
                  style: ev.text.data.copyWith(fontSize: 10, color: c.ink3),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '62 %',
            style: ev.text.data.copyWith(fontSize: 15, color: c.hot2),
          ),
        ],
      ),
    );
  }
}

class _Achievement extends StatelessWidget {
  const _Achievement({
    required this.name,
    required this.rule,
    required this.unlocked,
  });

  final String name;
  final String rule;
  final bool unlocked;

  @override
  Widget build(BuildContext context) {
    final ev = context.ev;
    final c = ev.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: ev.radii.b2,
        color: c.ink.withValues(alpha: .022),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TrophyIcon(unlocked: unlocked, size: 32),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  style: ev.text.ui(
                    ev.text.body,
                    weight: FontWeight.w500,
                    size: 13,
                    color: c.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  rule,
                  style: ev.text.body.copyWith(fontSize: 11.5, color: c.ink4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TrophyIcon extends StatelessWidget {
  const _TrophyIcon({required this.unlocked, required this.size});

  final bool unlocked;
  final double size;

  @override
  Widget build(BuildContext context) {
    final ev = context.ev;
    final c = ev.colors;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: ev.radii.b4,
        border: Border.all(
          color: unlocked ? c.hot1.withValues(alpha: .45) : c.line,
        ),
        color: unlocked ? c.hot1.withValues(alpha: .1) : null,
        boxShadow: unlocked
            ? [BoxShadow(color: c.hot1.withValues(alpha: .25), blurRadius: 20)]
            : null,
      ),
      child: Center(
        child: EvIcon(
          EvIcons.trophy,
          size: 15,
          color: unlocked ? c.hot2 : c.ink4,
        ),
      ),
    );
  }
}

/// Состав на диске: многоцветная полоса и список частей. Обязательная
/// часть не снимается — та же строка, что в диалоге добавления раздачи.
class _Parts extends StatefulWidget {
  const _Parts({required this.facts});

  final EvGameFacts facts;

  @override
  State<_Parts> createState() => _PartsState();
}

class _PartsState extends State<_Parts> {
  late final Set<EvGamePart> _on = {
    for (final p in widget.facts.parts)
      if (p.onDisk) p,
  };

  @override
  Widget build(BuildContext context) {
    final ev = context.ev;
    final c = ev.colors;
    final on = widget.facts.parts.where(_on.contains).toList();
    final onSum = on.fold<double>(0, (sum, p) => sum + p.size);
    final offSum = widget.facts.parts
        .where((p) => !_on.contains(p))
        .fold<double>(0, (sum, p) => sum + p.size);
    final colors = [c.hot1, c.cool, c.arc];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _BlockHeader(
          'Состав на диске',
          strong: formatGb(onSum > 0 ? onSum : offSum),
          value: onSum > 0 ? ' на диске' : ' к загрузке',
        ),
        ClipRRect(
          borderRadius: ev.radii.bPill,
          child: SizedBox(
            height: 8,
            child: on.isEmpty
                ? ColoredBox(color: c.ink.withValues(alpha: .08))
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final (i, part) in on.indexed)
                        Expanded(
                          flex: math.max(1, (part.size * 100).round()),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: colors[i % colors.length],
                              border: i == 0
                                  ? null
                                  : const Border(
                                      left: BorderSide(
                                        color: Color.fromRGBO(6, 6, 10, .6),
                                      ),
                                    ),
                            ),
                          ),
                        ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 13),
        for (final part in widget.facts.parts)
          _PartRow(
            part: part,
            on: _on.contains(part),
            onToggle: part.required
                ? null
                : () => setState(() {
                    _on.contains(part) ? _on.remove(part) : _on.add(part);
                  }),
          ),
      ],
    );
  }
}

class _PartRow extends StatefulWidget {
  const _PartRow({
    required this.part,
    required this.on,
    required this.onToggle,
  });

  final EvGamePart part;
  final bool on;
  final VoidCallback? onToggle;

  @override
  State<_PartRow> createState() => _PartRowState();
}

class _PartRowState extends State<_PartRow> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final ev = context.ev;
    final c = ev.colors;
    final on = widget.on;
    return MouseRegion(
      cursor: widget.onToggle == null
          ? MouseCursor.defer
          : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = widget.onToggle != null),
      onExit: (_) => setState(() => _hover = false),
      child: EvFocusable(
        onActivate: widget.onToggle,
        radius: ev.radii.r2,
        child: Semantics(
          button: widget.onToggle != null,
          checked: on,
          label: widget.part.name,
          excludeSemantics: true,
          child: GestureDetector(
            onTap: widget.onToggle,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
              decoration: BoxDecoration(
                borderRadius: ev.radii.b2,
                color: _hover ? c.ink.withValues(alpha: .04) : null,
              ),
              child: Row(
                children: [
                  Container(
                    width: 17,
                    height: 17,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        math.min(5, ev.radii.r2),
                      ),
                      border: Border.all(color: on ? c.hot1 : c.line),
                      gradient: on
                          ? LinearGradient(
                              begin: const Alignment(-.7, -1),
                              end: const Alignment(.7, 1),
                              colors: [c.hot2, c.hot1],
                            )
                          : null,
                      boxShadow: on
                          ? [
                              BoxShadow(
                                color: c.hot1.withValues(alpha: .5),
                                blurRadius: 14,
                              ),
                            ]
                          : null,
                    ),
                    child: on
                        ? const Center(
                            child: EvIcon(
                              EvIcons.verified,
                              size: 11,
                              color: Color(0xFF1A0A00),
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Row(
                      children: [
                        Flexible(
                          child: Text(
                            widget.part.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: ev.text.body.copyWith(
                              fontSize: 13,
                              color: on ? c.ink : c.ink4,
                            ),
                          ),
                        ),
                        if (widget.part.required) ...[
                          const SizedBox(width: 8),
                          Text(
                            'обязательно',
                            style: ev.text.data.copyWith(
                              fontSize: 10,
                              color: c.ink4,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 11),
                  Text(
                    formatGb(widget.part.size),
                    style: ev.text.data.copyWith(
                      fontSize: 11.5,
                      color: on ? c.ink2 : c.ink4,
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

/// Правая колонка: раздача, точка сохранения, друзья и глаголы.
class _SideColumn extends StatelessWidget {
  const _SideColumn({required this.game, required this.facts});

  final SampleGame game;
  final EvGameFacts facts;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _SideCard(
        label: 'Раздача',
        child: _SeedBox(facts: facts),
      ),
      const SizedBox(height: 12),
      _SideCard(
        label: 'Сохранения',
        child: _SavePoint(game: game, facts: facts),
      ),
      const SizedBox(height: 12),
      _SideCard(
        label: 'Друзья',
        child: _Friends(facts: facts),
      ),
      const SizedBox(height: 12),
      _SideCard(
        label: 'Действия',
        child: _Verbs(facts: facts),
      ),
    ],
  );
}

class _SideCard extends StatelessWidget {
  const _SideCard({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final ev = context.ev;
    final c = ev.colors;
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        borderRadius: ev.radii.b3,
        border: Border.all(color: c.lineSoft),
        color: c.ink.withValues(alpha: .022),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(label.toUpperCase(), style: ev.text.label),
          const SizedBox(height: 11),
          child,
        ],
      ),
    );
  }
}

/// Раздача — то, чего нет ни у одного магазина: рейтинг, отдано, пиры.
class _SeedBox extends StatelessWidget {
  const _SeedBox({required this.facts});

  final EvGameFacts facts;

  @override
  Widget build(BuildContext context) {
    final ev = context.ev;
    final c = ev.colors;

    Widget field(String key, String value, Color color) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          key.toUpperCase(),
          style: ev.text.data.copyWith(
            fontSize: 9,
            letterSpacing: 1.26,
            color: c.ink4,
          ),
        ),
        const SizedBox(height: 4),
        Text(value, style: ev.text.data.copyWith(fontSize: 15, color: color)),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: field(
                'Рейтинг',
                facts.ratio.toStringAsFixed(2).replaceAll('.', ','),
                facts.ratio >= 1 ? EvColors.ok : c.ink,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(child: field('Отдано', formatGb(facts.uploaded), c.cool)),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: ev.radii.bPill,
          child: SizedBox(
            height: 4,
            child: Stack(
              fit: StackFit.expand,
              children: [
                ColoredBox(color: c.ink.withValues(alpha: .07)),
                FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: (facts.ratio / 3).clamp(.04, 1),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [const Color(0xFF1B6F8A), c.cool],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: c.cool.withValues(alpha: .5),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: field('Пиров сейчас', '${facts.peers}', c.ink)),
            const SizedBox(width: 14),
            Expanded(
              child: field(
                'Раздаём',
                facts.installed ? 'да' : 'нет',
                facts.installed ? EvColors.ok : c.ink3,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Точка сохранения: миниатюра кадра, время и куда выгружено.
class _SavePoint extends StatelessWidget {
  const _SavePoint({required this.game, required this.facts});

  final SampleGame game;
  final EvGameFacts facts;

  @override
  Widget build(BuildContext context) {
    final ev = context.ev;
    final c = ev.colors;
    if (facts.hours == 0) {
      return Row(
        children: [
          EvIcon(EvIcons.cloud, size: 14, color: c.ink3),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              'Сохранений пока нет',
              style: ev.text.data.copyWith(fontSize: 11, color: c.ink3),
            ),
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(9, 9, 12, 9),
          decoration: BoxDecoration(
            borderRadius: ev.radii.b3,
            border: Border.all(color: c.line),
            color: const Color.fromRGBO(10, 11, 17, .66),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 42,
                height: 32,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(math.min(7, ev.radii.r3)),
                  child: EvCover(palette: game.palette, seed: game.seed),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '02:14 · Глава 5',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: ev.text.body.copyWith(
                        fontSize: 12.5,
                        color: c.ink,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${facts.lastAgo} · 148 МБ',
                      style: ev.text.data.copyWith(fontSize: 10, color: c.ink4),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _Device(icon: EvIcons.cloud, label: 'выгружено', ok: true),
            _Device(icon: EvIcons.desktop, label: 'КУЗНЯ'),
          ],
        ),
      ],
    );
  }
}

class _Device extends StatelessWidget {
  const _Device({required this.icon, required this.label, this.ok = false});

  final String icon;
  final String label;
  final bool ok;

  @override
  Widget build(BuildContext context) {
    final ev = context.ev;
    final c = ev.colors;
    final color = ok ? EvColors.ok : c.ink3;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: ev.radii.bPill,
        border: Border.all(
          color: ok ? EvColors.ok.withValues(alpha: .32) : c.lineSoft,
        ),
        color: ok ? EvColors.ok.withValues(alpha: .07) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          EvIcon(icon, size: 12, color: color),
          const SizedBox(width: 7),
          Text(
            label,
            style: ev.text.data.copyWith(fontSize: 10.5, color: color),
          ),
        ],
      ),
    );
  }
}

/// Друзья, у которых эта игра: у первого она запущена сейчас.
class _Friends extends StatelessWidget {
  const _Friends({required this.facts});

  final EvGameFacts facts;

  @override
  Widget build(BuildContext context) {
    final ev = context.ev;
    final c = ev.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (i, friend) in facts.friends.indexed)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 7),
            child: Row(
              children: [
                EvFriendAvatar(
                  initials: friend.initials,
                  tint: friend.tint,
                  size: 26,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    friend.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: ev.text.body.copyWith(fontSize: 12.5, color: c.ink),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  i == 0 ? 'в игре · 2 ч' : 'в сети',
                  style: ev.text.data.copyWith(fontSize: 10, color: c.ink4),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Список глаголов: всё, что можно сделать с игрой, кроме как играть.
class _Verbs extends StatelessWidget {
  const _Verbs({required this.facts});

  final EvGameFacts facts;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Verb(
          icon: EvIcons.verified,
          label: 'Проверить целостность',
          note: '~4 мин',
        ),
        _Verb(icon: EvIcons.folder, label: 'Открыть папку', note: r'D:\Игры'),
        _Verb(icon: EvIcons.boost, label: 'Создать ярлык'),
        _Verb(
          icon: EvIcons.seed,
          label: facts.installed ? 'Перестать раздавать' : 'Начать раздачу',
        ),
        _Verb(
          icon: EvIcons.close,
          label: 'Удалить с диска',
          note: formatGb(facts.onDisk),
          danger: true,
        ),
      ],
    ),
  );
}

class _Verb extends StatefulWidget {
  const _Verb({
    required this.icon,
    required this.label,
    this.note,
    this.danger = false,
  });

  final String icon;
  final String label;
  final String? note;
  final bool danger;

  @override
  State<_Verb> createState() => _VerbState();
}

class _VerbState extends State<_Verb> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final ev = context.ev;
    final c = ev.colors;
    final accent = widget.danger ? EvColors.bad : c.ink;
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(
          borderRadius: ev.radii.b2,
          color: _hover
              ? (widget.danger
                    ? EvColors.bad.withValues(alpha: .09)
                    : c.ink.withValues(alpha: .05))
              : null,
        ),
        child: Row(
          children: [
            EvIcon(
              widget.icon,
              size: 15,
              color: _hover ? (widget.danger ? EvColors.bad : c.hot2) : c.ink4,
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Text(
                widget.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: ev.text.body.copyWith(
                  fontSize: 13,
                  color: _hover ? accent : c.ink2,
                ),
              ),
            ),
            if (widget.note != null) ...[
              const SizedBox(width: 10),
              Text(
                widget.note!,
                style: ev.text.data.copyWith(fontSize: 10, color: c.ink4),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
