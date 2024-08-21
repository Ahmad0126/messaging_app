// chat_list_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:messaging_app/auth.dart';
import 'package:messaging_app/screens/login_screen.dart';
import 'package:messaging_app/screens/profile_page.dart';
import 'package:messaging_app/screens/user_list.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatefulWidget{
  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
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
              return StreamBuilder(
                stream: FirebaseFirestore.instance.collection('users')
                  .doc(chat['participants'].firstWhere((id) => id != user.uid))
                  .snapshots(), 
                builder: (context, snap1) {
                  if (!snap1.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }
                  return ListTile(
                    title: Text('Chat with ${snap1.data!.get('name')}'),
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
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage())),
              ),
              ElevatedButton(
                child: ListTile(
                  leading: Icon(Icons.logout),
                  title: Text("Logout"),
                  subtitle: Text("Keluar dari aplikasi"),
                ),
                onPressed: () async{
                  await Auth().signOut();
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(
          builder: (context) => UserList(),
        )),
        child: Icon(Icons.add),
      ),
    );
  }
}
