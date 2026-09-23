import 'package:flutter/widgets.dart';

import '../design/theme.dart';
import '../design/tokens.dart';
import '../downloads/download_data.dart';
import '../downloads/ev_torrent_row.dart';
import '../downloads/rate_graph.dart';
import '../util/plural.dart';
import '../util/units.dart';
import '../widgets/ev_controls.dart';
import '../widgets/ev_icon.dart';
import '../widgets/ev_surfaces.dart';

/// Загрузки — приборная доска раздачи.
///
/// Сверху два прибора: что происходит сейчас (приём, график за минуту,
/// четыре числа) и из чего это состоит (кольцо частей и активность пиров).
/// Ниже — сами раздачи и очередь. Ни одно число в шапке не написано
/// отдельно от строк: приём, отдача и «активных» складываются из них,
/// поэтому разойтись не могут.
class DownloadsPage extends StatefulWidget {
  const DownloadsPage({super.key, required this.downloads});

  final EvDownloads downloads;

  @override
  State<DownloadsPage> createState() => _DownloadsPageState();
}

class _DownloadsPageState extends State<DownloadsPage>
    with SingleTickerProviderStateMixin {
  /// Секунда приёма — один отсчёт графика; тепловая карта живёт своим
  /// шагом в 900 мс, как в прототипе.
  static const _second = Duration(seconds: 1);
  static const _heatStep = Duration(milliseconds: 900);

  late final AnimationController _clock = AnimationController(
    vsync: this,
    duration: const Duration(minutes: 1),
    // Приборы идут по настоящим часам: «меньше движения» гасит их
    // совсем, а не ускоряет в двадцать раз.
    animationBehavior: AnimationBehavior.preserve,
  );
  late EvRateSeries _series = EvRateSeries(widget.downloads.downKb / 1000);
  int _ticks = 0;
  int _heat = 0;

  @override
  void initState() {
    super.initState();
    _clock.addListener(_tick);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // «Меньше движения» — приборы замирают на первом кадре, как `RM`
    // в прототипе.
    if (MediaQuery.disableAnimationsOf(context)) {
      _clock.stop();
    } else if (!_clock.isAnimating) {
      _clock.repeat();
    }
  }

  @override
  void didUpdateWidget(DownloadsPage old) {
    super.didUpdateWidget(old);
    // Состояние раздела сменилось — приборы начинают с нового числа,
    // а не дотягивают старую историю.
    if (old.downloads.downKb != widget.downloads.downKb) {
      _series = EvRateSeries(widget.downloads.downKb / 1000);
      _ticks = 0;
    }
  }

  void _tick() {
    final elapsed = _clock.lastElapsedDuration ?? Duration.zero;
    final seconds = elapsed.inMicroseconds ~/ _second.inMicroseconds;
    final heat = elapsed.inMicroseconds ~/ _heatStep.inMicroseconds;
    if (seconds == _ticks && heat == _heat) return;
    setState(() {
      while (_ticks < seconds) {
        _series.advance();
        _ticks++;
      }
      _heat = heat;
    });
  }

  @override
  void dispose() {
    _clock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ev = context.ev;
    final window = MediaQuery.sizeOf(context);
    final gutter = EvSpace.gutterFor(window);
    final chrome = MediaQuery.paddingOf(context);
    final d = widget.downloads;

    final head = [
      _RatePanel(downloads: d, series: _series.history),
      _SwarmPanel(downloads: d, heat: _heat),
    ];

    Widget section(String title, String count, Widget child) => Padding(
      padding: const EdgeInsets.only(top: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          EvSectionHeader(title, count: count),
          const SizedBox(height: EvSpace.l),
          child,
        ],
      ),
    );

    return ListView(
      primary: true,
      padding: EdgeInsets.fromLTRB(
        gutter,
        chrome.top + gutter,
        gutter,
        26 + chrome.bottom,
      ),
      children: [
        // Ниже 900 приборы встают друг под друга: кольцо с подписями
        // в колонку уже, чем в один ряд, не читается.
        if (window.width < 900)
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              head.first,
              const SizedBox(height: EvSpace.l),
              head.last,
            ],
          )
        else
          // Панели одной высоты, как колонки сетки в прототипе: правая
          // дотягивается до левой, а не висит короче неё.
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(flex: 125, child: head.first),
                const SizedBox(width: EvSpace.l),
                Expanded(flex: 100, child: head.last),
              ],
            ),
          ),
        section(
          'Сейчас качается',
          '${d.torrents.length} '
              '${ruPlural(d.torrents.length, 'раздача', 'раздачи', 'раздач')}',
          d.torrents.isEmpty
              ? EvNothing(
                  icon: EvIcons.download,
                  title: 'Ничего не качается',
                  detail:
                      'Перетащите .torrent в окно или вставьте magnet-ссылку '
                      '— движок подхватит её сам',
                  action: EvMiniButton(
                    label: 'Вставить ссылку',
                    icon: EvIcons.magnet,
                    onPressed: () {},
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final (i, t) in d.torrents.indexed) ...[
                      if (i > 0) const SizedBox(height: 11),
                      EvTorrentRow(torrent: t),
                    ],
                  ],
                ),
        ),
        if (d.queue.isNotEmpty)
          section(
            'В очереди',
            '${d.queue.length} '
                '${ruPlural(d.queue.length, 'раздача', 'раздачи', 'раздач')}',
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final (i, q) in d.queue.indexed) ...[
                  if (i > 0) const SizedBox(height: 7),
                  EvQueueRow(item: q),
                ],
              ],
            ),
          ),
        SizedBox(height: ev.radii.r1),
      ],
    );
  }
}

/// Приём сейчас: крупное число, минута истории и четыре прибора.
class _RatePanel extends StatelessWidget {
  const _RatePanel({required this.downloads, required this.series});

  final EvDownloads downloads;
  final List<double> series;

  @override
  Widget build(BuildContext context) {
    final ev = context.ev;
    final c = ev.colors;
    final d = downloads;
    final window = MediaQuery.sizeOf(context);
    final rate = series.last;
    return EvPanel(
      glowCorner: true,
      grouped: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('ПРИЁМ · СЕЙЧАС', style: ev.text.label),
          const SizedBox(height: 8),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(text: rate.toStringAsFixed(2)),
                TextSpan(
                  text: '  МБ/с',
                  style: ev.text.mono(
                    ev.text.data,
                    // 0.36 от кегля числа — те же пропорции, что в макете.
                    size: _bigSize(window) * .36,
                    color: c.ink3,
                    letterSpacing: _bigSize(window) * .018,
                  ),
                ),
              ],
            ),
            style: ev.text.big(_bigSize(window)),
          ),
          const SizedBox(height: 10),
          EvRateGraph(series),
          const SizedBox(height: EvSpace.l),
          _Kpis(
            items: [
              ('Отдача', formatRate(d.upKb), c.cool),
              ('Пик за час', formatRate(d.peakKb, digits: 1), c.hot2),
              ('Активных', '${d.active} / ${d.slots}', c.ink),
              ('На диск', formatRate(d.toDiskKb), c.ink),
            ],
          ),
        ],
      ),
    );
  }

  /// `clamp(30px, 4.4vw, 50px)` из прототипа.
  static double _bigSize(Size window) => (window.width * .044).clamp(30, 50);
}

/// Четыре числа сеткой: тонкие линии между ними — не рамки, а швы.
class _Kpis extends StatelessWidget {
  const _Kpis({required this.items});

  final List<(String, String, Color)> items;

  @override
  Widget build(BuildContext context) {
    final ev = context.ev;
    final c = ev.colors;
    Widget cell((String, String, Color) item) => Container(
      color: c.surface,
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item.$1.toUpperCase(), style: ev.text.label),
          const SizedBox(height: 5),
          Text(
            item.$2,
            maxLines: 1,
            style: ev.text.mono(
              ev.text.data,
              size: 17,
              weight: FontWeight.w500,
              color: item.$3,
            ),
          ),
        ],
      ),
    );
    return ClipRRect(
      borderRadius: ev.radii.b2,
      child: ColoredBox(
        color: c.lineSoft,
        child: Column(
          children: [
            for (var row = 0; row < 2; row++) ...[
              if (row > 0) const SizedBox(height: 1),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: cell(items[row * 2])),
                    const SizedBox(width: 1),
                    Expanded(child: cell(items[row * 2 + 1])),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Из чего состоит приём: кольцо частей и минута активности пиров.
class _SwarmPanel extends StatelessWidget {
  const _SwarmPanel({required this.downloads, required this.heat});

  final EvDownloads downloads;
  final int heat;

  @override
  Widget build(BuildContext context) {
    final ev = context.ev;
    final c = ev.colors;
    final parts = downloads.parts;
    return EvPanel(
      grouped: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('РОЙ · РАСПРЕДЕЛЕНИЕ ЧАСТЕЙ', style: ev.text.label),
          const SizedBox(height: 14),
          if (parts == null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 22),
              child: Text(
                'Частей нет: ни одна раздача не идёт',
                style: ev.text.data.copyWith(fontSize: 11.5),
              ),
            )
          else
            Row(
              children: [
                EvSwarmRing(
                  received: parts.received / parts.total,
                  inFlight: parts.inFlight / parts.total,
                  verifying: parts.verifying / parts.total,
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _Legend(
                        color: c.hot1,
                        label: 'Получено',
                        value: parts.received,
                      ),
                      _Legend(
                        color: c.cool,
                        label: 'В работе',
                        value: parts.inFlight,
                      ),
                      _Legend(
                        color: c.arc,
                        label: 'Проверка',
                        value: parts.verifying,
                      ),
                      _Legend(
                        color: c.ink.withValues(alpha: .12),
                        label: 'Осталось',
                        value: parts.remaining,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          const SizedBox(height: 18),
          Text('АКТИВНОСТЬ ПИРОВ · 60 С', style: ev.text.label),
          const SizedBox(height: 14),
          EvPeerHeat(tick: heat, live: downloads.torrents.isNotEmpty),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({
    required this.color,
    required this.label,
    required this.value,
  });

  final Color color;
  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    final ev = context.ev;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.5),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: ev.text.body.copyWith(fontSize: 12.5),
            ),
          ),
          const SizedBox(width: 14),
          Text(formatGbDot(value), style: ev.text.dataStrong),
        ],
      ),
    );
  }
}
