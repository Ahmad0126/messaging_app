import 'package:flutter/material.dart';
import 'package:messaging_app/auth.dart';
import 'package:messaging_app/screens/chat_list_screen.dart';
import 'package:messaging_app/screens/login_screen.dart';

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
          return ChatListScreen();
        }else{
          return LoginScreen();
        }
      },
    );
  }
}