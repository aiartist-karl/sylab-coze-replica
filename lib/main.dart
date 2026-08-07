import 'package:flutter/material.dart';
import 'package:coze_replica/pages/home_page.dart';
import 'package:coze_replica/widgets/floating_task_indicator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CozeReplicaApp());
}

class CozeReplicaApp extends StatelessWidget {
  const CozeReplicaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Coze Replica',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFFFFFFF),
        appBarTheme: const AppBarTheme(
          backgroundColor: const Color(0xFFFFFFFF),
          elevation: 0,
          surfaceTintColor: Colors.transparent,
        ),
      ),
      home: const AppShell(),
    );
  }
}

/// Global app shell — overlays floating task indicator above all pages.
class AppShell extends StatelessWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Main content
          const HomePage(),
          // Floating task progress indicator (global overlay)
          Positioned.fill(
            child: FloatingTaskIndicator(
              initialVerticalRatio: 0.35,
            ),
          ),
        ],
      ),
    );
  }
}
