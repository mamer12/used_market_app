import 'dart:async';

import 'package:mcp_toolkit/mcp_toolkit.dart';

import 'app/view/app.dart';
import 'bootstrap.dart';
import 'core/config/flavor.dart';

Future<void> main() async {
  runZonedGuarded(
    () async {
      await bootstrap(() => const App(), AppFlavor.development);
    },
    (error, stack) {
      // Forward zone errors to MCP toolkit so the inspector can report them
      assert(() {
        MCPToolkitBinding.instance.handleZoneError(error, stack);
        return true;
      }());
    },
  );
}
