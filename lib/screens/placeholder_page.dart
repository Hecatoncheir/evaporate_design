import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../design/theme.dart';
import '../design/tokens.dart';
import '../shell/ev_section.dart';
import '../shell/ev_top_bar.dart' show EvKey;
import '../widgets/ev_icon.dart';

/// Раздел, который каркас уже знает, а экран ещё не перенесён.
///
/// Не «скоро будет», а честная табличка: что здесь появится и как сюда
/// попасть — навигация работает уже сейчас.
class PlaceholderPage extends StatelessWidget {
  const PlaceholderPage({super.key, required this.section});

  final EvSection section;

  static const _about = {
    EvSection.downloads:
        'Очередь раздач, скорость, пиры и проверка файлов — с графиком '
        'приёма и тепловой картой частей.',
    EvSection.saves:
        'Облачные сохранения, снимки перед запуском и разбор конфликтов '
        'между устройствами.',
    EvSection.friends:
        'Кто в сети и во что играет, приглашения, общие игры и лента '
        'событий.',
    EvSection.profile:
        'Витрина игрока: часы, достижения, редкие трофеи и то, как профиль '
        'видят друзья.',
  };

  @override
  Widget build(BuildContext context) {
    final ev = context.ev;
    final c = ev.colors;
    final window = MediaQuery.sizeOf(context);
    final gutter = EvSpace.gutterFor(window);
    final chrome = MediaQuery.paddingOf(context);
    final label = ev.text.data.copyWith(color: c.ink4, fontSize: 10.5);
    return LayoutBuilder(
      builder: (context, box) => SingleChildScrollView(
        primary: true,
        padding: EdgeInsets.fromLTRB(
          gutter,
          chrome.top + 28,
          gutter,
          chrome.bottom + 28,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: math.max(
              0,
              box.maxHeight - 56 - chrome.top - chrome.bottom,
            ),
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 104,
                    height: 104,
                    child: Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        // Иллюстративный круг — вне потолка радиуса.
                        Positioned(
                          left: -15,
                          top: -15,
                          right: -15,
                          bottom: -15,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  c.hot1.withValues(alpha: 0.2),
                                  c.hot1.withValues(alpha: 0),
                                ],
                                stops: const [0, 0.68],
                              ),
                            ),
                          ),
                        ),
                        EvIcon(section.icon, size: 44, color: c.ink2),
                      ],
                    ),
                  ),
                  const SizedBox(height: EvSpace.xl),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: section.label,
                          style: ev.text.displayBold(30),
                        ),
                        const TextSpan(text: ' ещё в макете'),
                      ],
                    ),
                    textAlign: TextAlign.center,
                    style: ev.text.display(30).copyWith(height: 1.1),
                  ),
                  const SizedBox(height: EvSpace.l),
                  Text(
                    _about[section] ?? '',
                    textAlign: TextAlign.center,
                    style: ev.text.body.copyWith(color: c.ink2),
                  ),
                  const SizedBox(height: EvSpace.xl),
                  Wrap(
                    spacing: 22,
                    runSpacing: EvSpace.s,
                    alignment: WrapAlignment.center,
                    children: [
                      _Hint(
                        keyLabel: '${section.hotkey}',
                        text: 'этот раздел',
                        style: label,
                      ),
                      _Hint(
                        keyLabel: 'Ctrl+Tab',
                        text: 'следующий',
                        style: label,
                      ),
                      _Hint(keyLabel: '/', text: 'поиск', style: label),
                    ],
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

class _Hint extends StatelessWidget {
  const _Hint({
    required this.keyLabel,
    required this.text,
    required this.style,
  });

  final String keyLabel;
  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      EvKey(keyLabel),
      const SizedBox(width: 7),
      Text(text, style: style),
    ],
  );
}
