import 'app/view/app.dart';
import 'bootstrap.dart';
import 'core/config/flavor.dart';

Future<void> main() async {
  await bootstrap(() => const App(), AppFlavor.development);
}
