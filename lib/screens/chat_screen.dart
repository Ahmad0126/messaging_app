// chat_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:messaging_app/auth.dart';
import 'package:messaging_app/screens/login_screen.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;

  ChatScreen({required this.chatId});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();

  Future<void> _sendMessage() async {
    final user = FirebaseAuth.instance.currentUser;
    await FirebaseFirestore.instance.collection('messages').add({
      'chat_id': widget.chatId,
      'user_id': user!.uid,
      'message': _messageController.text,
      'timestamp': FieldValue.serverTimestamp(),
    });
    await FirebaseFirestore.instance.collection('chats').doc(widget.chatId).update({
      'last_message': _messageController.text,
      'timestamp': FieldValue.serverTimestamp(),
    });
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chat')),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('messages')
                  .where('chat_id', isEqualTo: widget.chatId)
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                final messages = snapshot.data!.docs;
                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    return StreamBuilder(
                      stream: FirebaseFirestore.instance.collection('users')
                        .doc(message['user_id'])
                        .snapshots(), 
                      builder: (context, snap1) {
                        if (!snap1.hasData) {
                          return Center(child: CircularProgressIndicator());
                        }
                        return ListTile(
                          title: Text(snap1.data!.get('name')+" 10/09/2024 10:08"),
                          subtitle: Text(message['message']),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      labelText: 'Type a message',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
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
                onPressed: () async{
                  await Auth().signOut();
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
