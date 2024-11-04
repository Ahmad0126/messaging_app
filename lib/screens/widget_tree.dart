import 'package:flutter/material.dart';
import 'package:test_chat/auth.dart';
import 'package:test_chat/screens/chat_list_screen.dart';
import 'package:test_chat/screens/login_screen.dart';

class WidgetTree extends StatefulWidget{
  const WidgetTree({super.key});

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree>{
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Auth().authStateChanges, 
      builder: (context, snapshot) {
        if(snapshot.hasData){
          return const ChatListScreen();
        }else{
          return const LoginScreen();
        }
      },
    );
  }
}