import 'app/view/app.dart';
import 'bootstrap.dart';
import 'core/config/flavor.dart';

void main() {
  bootstrap(() => const App(), AppFlavor.production);
}
