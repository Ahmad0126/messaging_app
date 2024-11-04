// main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:test_chat/screens/chat_list_screen.dart';
import 'package:test_chat/screens/login_screen.dart';
import 'package:test_chat/screens/profile_page.dart';
import 'package:test_chat/screens/register_screen.dart';
import 'package:test_chat/screens/user_list.dart';
import 'package:test_chat/screens/widget_tree.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat App',
      theme: ThemeData(
        primaryColor: Color(0xFF95D2B3), // AppBar dan elemen utama
        scaffoldBackgroundColor: Color(0xFFD8EFD3), // Background utama
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: Color(0xFF95D2B3), // Warna utama
          secondary: Color(0xFF55AD9B), // Warna untuk tombol utama
          background: Color(0xFFF1F8E8), // Background tambahan
        ),
        buttonTheme: ButtonThemeData(
          buttonColor: Color(0xFF55AD9B), // Warna tombol
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF55AD9B), // Warna tombol elevated button
            foregroundColor: Colors.white, // Teks pada tombol
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF95D2B3), // Warna AppBar
          elevation: 0, // Menghilangkan shadow pada AppBar
        ),
        textTheme: TextTheme(
          bodyMedium: TextStyle(
            color: Colors.black, // Warna teks biasa
          ),
          titleLarge: TextStyle(
            color: Colors.white, // Warna teks di AppBar
          ),
        ),
        dividerColor: Color(0xFF55AD9B), // Warna divider
      ),
      debugShowCheckedModeBanner: false,
      home: const WidgetTree(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/contacts': (context) => const UserList(),
        '/chat-history': (context) => const ChatListScreen(),
        '/profile': (context) => ProfilePage(), // Pastikan rute ini ada
      },
    );
  }
}
