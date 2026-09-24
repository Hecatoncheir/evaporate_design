import 'dart:async';

import 'package:flutter/foundation.dart';

import 'first_run_data.dart';

/// Первый запуск и каталог — состояние окна. Шаг сценария подменяет
/// библиотеку, очередь, героя и плашки; всё это читается из [run].
///
/// Что должно случиться при входе на шаг — открыть диалог, перейти
/// в загрузки, запустить ритуал — делает [onStep]: у контроллера нет
/// ни навигатора, ни каркаса.
class EvFirstRunController extends ChangeNotifier {
  EvFirstRunController({required this.onStep, this.onExit, bool read = true})
    : _catalog = read ? EvCatalog.reading : EvCatalog.normal {
    // Каталог читается первые 300 мс — всё это время виден скелет.
    if (read) _reading = Timer(EvCatalog.readTime, _doneReading);
  }

  final void Function(EvFirstRunStep step) onStep;

  /// Сценарий закрыли.
  final VoidCallback? onExit;

  Timer? _reading;
  EvCatalog _catalog;
  EvFirstRun? _run;

  EvCatalog get catalog => _catalog;

  /// Шаг сценария; `null` — сценария нет.
  EvFirstRun? get run => _run;

  set catalog(EvCatalog value) {
    _reading?.cancel();
    if (value == _catalog) return;
    _catalog = value;
    notifyListeners();
  }

  void _doneReading() {
    if (_catalog == EvCatalog.reading) catalog = EvCatalog.normal;
  }

  /// Перейти на шаг [step]. Выбор в диалоге сохраняется.
  void go(EvFirstRunStep step) {
    _run = _run?.at(step) ?? EvFirstRun(step);
    notifyListeners();
    onStep(step);
  }

  /// Дальше; с последнего шага — заново.
  void next() => go(_run?.step.next ?? EvFirstRunStep.installed);

  void previous() {
    final back = _run?.step.previous;
    if (back != null) go(back);
  }

  /// В диалоге выбрали [gb] гигабайт и нажали «Скачать».
  void download(double gb) {
    _run = EvFirstRun(EvFirstRunStep.queued, gb: gb);
    notifyListeners();
    onStep(EvFirstRunStep.queued);
  }

  /// Выйти из сценария: библиотека снова полная.
  void exit() {
    if (_run == null) return;
    _run = null;
    _catalog = EvCatalog.normal;
    notifyListeners();
    onExit?.call();
  }

  @override
  void dispose() {
    _reading?.cancel();
    super.dispose();
  }
}
