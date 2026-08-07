import 'package:flutter/material.dart';
import 'package:coze_replica/pages/home_page.dart';

void main() {
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
          backgroundColor: Color(0xFFFFFFFF),
          elevation: 0,
          surfaceTintColor: Colors.transparent,
        ),
      ),
      home: const HomePage(),
    );
  }
}
