import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:messaging_app/auth.dart';
import 'package:messaging_app/screens/chat_list_screen.dart';
import 'package:messaging_app/screens/register_screen.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _login() async {
    try {
      await Auth().signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ChatListScreen()),
      );
    } on FirebaseAuthException catch (e) {
      print('Login error: $e');
      setState(() {
        Alert(
          context: context,
          title: "Login Gagal",
          desc: e.message,
          buttons: [
            DialogButton(
              child: const Text("OK"), 
              onPressed: () => Navigator.pop(context),
            )
          ]
        ).show();
        _emailController.text = '';
        _passwordController.text = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Password'),
            ),
            Padding(
              padding: EdgeInsets.all(15),
              child: Row(
                children: [
                  Text("Belum Punya Akun? "),
                  TextButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterScreen())), 
                    child: Text("Daftar"),
                    style: ButtonStyle(foregroundColor: WidgetStateColor.resolveWith((states) {
                      return Colors.blue;
                    },)),
                  )
                ],
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
