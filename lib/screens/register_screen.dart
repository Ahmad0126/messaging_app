import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:messaging_app/auth.dart';
import 'package:messaging_app/screens/chat_list_screen.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  Future<void> _register() async {
    try {
      await Auth().createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      ).then((data) {
        if(Auth().currentUser != null){
          FirebaseFirestore.instance.collection('users').doc(Auth().currentUser!.uid).set({
            "name": _nameController.text,
            "status": 'online',
            "profile": 'default'
          });
        }
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ChatListScreen()),
      );
    } on FirebaseAuthException catch (e) {
      print('Register error: $e');

      setState(() {
        Alert(
          context: context,
          title: "Register Gagal",
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
        _nameController.text = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register')),
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
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _register,
              child: Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}
