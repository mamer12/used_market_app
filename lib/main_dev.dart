import 'app/view/app.dart'; // We will create this next
import 'bootstrap.dart';
import 'core/config/flavor.dart';

void main() {
  bootstrap(() => const App(), AppFlavor.development);
}
