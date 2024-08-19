// chat_list_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:messaging_app/auth.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(title: Text('Chat List')),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .where('participants', arrayContains: user!.uid)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          final chats = snapshot.data!.docs;
          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              return ListTile(
                title: Text('Chat with ${chat['participants'].firstWhere((id) => id != user.uid)}'),
                subtitle: Text(chat['last_message']),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(chatId: chat.id),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              TextButton(
                child: ListTile(
                  leading: Icon(Icons.verified_user),
                  title: Text("Profil"),
                  subtitle: Text(""),
                ),
                onPressed: () {},
              ),
              TextButton(
                child: ListTile(
                  leading: Icon(Icons.logout),
                  title: Text("Logout"),
                  subtitle: Text("Keluar dari aplikasi"),
                ),
                onPressed: Auth().signOut,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
