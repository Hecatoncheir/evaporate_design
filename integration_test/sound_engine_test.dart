import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:evaporate_design/sound/soloud_out.dart';
import 'package:evaporate_design/sound/voices.dart';

// Настоящий движок на настоящей платформе: заводится, компрессор встаёт
// на шину, девять голосов грузятся и играют. Громкость — ноль, чтобы
// проверка не шумела.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('SoLoud заводится и держит девять голосов', (tester) async {
    final out = EvSoLoudOut();
    await tester.runAsync(() async {
      await out.start();
      out.volume(0);
      for (final v in EvVoice.values) {
        out.play(v);
      }
      out
        ..hold().strike()
        ..ambient(true)
        ..ambient(false);
      await Future<void>.delayed(const Duration(milliseconds: 300));
    });
    expect(out.loaded, EvVoice.values.length);
    out.dispose();
  });
}
