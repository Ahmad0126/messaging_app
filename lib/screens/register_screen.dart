import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:test_chat/auth.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  final _nameController = TextEditingController();

  Future<void> _register() async {
    if(_passwordConfirmController.text != _passwordController.text){
      //kalau passwordnya salah
      setState(() {
        Alert(
          context: context,
          title: "Register Failed",
          desc: "Confirm your password again",
          buttons: [
            DialogButton(
              child: const Text("OK"), 
              onPressed: () => Navigator.pop(context),
            )
          ]
        ).show();
        _passwordConfirmController.text = '';
      });
    }else{
      //kalau passwordnya benar
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

        Navigator.pushReplacementNamed(context, '/chat-history');
      } on FirebaseAuthException catch (e) {
        print('Register error: $e');

        setState(() {
          Alert(
            context: context,
            title: "Register Failed",
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
          _passwordConfirmController.text = '';
          _nameController.text = '';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFD8EFD3), // Background color from the palette
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Create Account',
                style: TextStyle(
                  color: Color(0xFF55AD9B), // Title color
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              // Input for Name
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  labelText: 'Name', // Label for the name input
                  labelStyle: TextStyle(color: Color(0xFF55AD9B)), // Label color
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(color: Color(0xFF55AD9B)), // Border color
                  ),
                ),
              ),
              SizedBox(height: 10),
              // Input for Email
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  labelText: 'Email',
                  labelStyle: TextStyle(color: Color(0xFF55AD9B)), // Label color
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(color: Color(0xFF55AD9B)), // Border color
                  ),
                ),
              ),
              SizedBox(height: 10),
              // Input for Password
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  labelText: 'Password',
                  labelStyle:
                      TextStyle(color: Color(0xFF55AD9B)), // Label color
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(color: Color(0xFF55AD9B)), // Border color
                  ),
                ),
                obscureText: true,
              ),
              SizedBox(height: 10),
              // Input for Confirm Password
              TextField(
                controller: _passwordConfirmController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  labelText: 'Confirm Password',
                  labelStyle: TextStyle(color: Color(0xFF55AD9B)), // Label color
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(color: Color(0xFF55AD9B)), // Border color
                  ),
                ),
                obscureText: true,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF55AD9B), // Button color
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                  textStyle: TextStyle(fontSize: 18),
                ),
                child: Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
