// main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:messaging_app/screens/chat_list_screen.dart';
import 'package:messaging_app/screens/login_screen.dart';
import 'package:messaging_app/screens/profile_page.dart';
import 'package:messaging_app/screens/register_screen.dart';
import 'package:messaging_app/screens/widget_tree.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: const WidgetTree(),
      routes: {
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/chat-history': (context) => ChatListScreen(),
        '/profile': (context) => ProfilePage(), // Pastikan rute ini ada
      },
    );
  }
}
