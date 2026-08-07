import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'services/auth_service.dart';
import 'services/user_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthService().checkLoginStatus();
  await UserService().loadProfile();
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
      home: const HomePage(),
    );
  }
}
