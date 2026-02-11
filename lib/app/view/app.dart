import 'package:flutter/material.dart';
import 'package:talker_flutter/talker_flutter.dart';
import '../../core/services/log_service.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mustamal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // ── TalkerWrapper ─────────────────────────────────
      // Shows a friendly error UI instead of a gray crash screen.
      // In dev mode, shake the device to open the log console.
      builder: (context, child) {
        return TalkerWrapper(
          talker: LogService().talker,
          child: child!,
        );
      },
      home: const Scaffold(
        body: Center(
          child: Text('مستعمل - Mustamal'),
        ),
      ),
    );
  }
}
