// chat_list_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:messaging_app/screens/user_list.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatefulWidget{
  const ChatListScreen({super.key});

  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Chats'),
        backgroundColor: const Color.fromARGB(255, 0, 150, 5),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // Search functionality
            },
          ),
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              Navigator.pushNamed(context, '/profile'); // Navigasi ke halaman profil
            },
          ),
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .where('participants', arrayContains: user!.uid)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
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
                    return const Center(child: CircularProgressIndicator());
                  }
                  DateTime time = chat['timestamp'].toDate();
                  var tanggal = DateFormat('d MMM y H:mm').format(time);
                  return Column(
                    children: [
                      ListTile(
                        leading: CircleAvatar(
                          backgroundImage: AssetImage('images/unknown.png'), // Ganti dengan image profil yang valid
                        ),
                        title: Text(snap1.data!.get('name')),
                        subtitle: Text(chat['last_message']),
                        trailing: Text(tanggal),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(chatId: chat.id, nama: snap1.data!.get('name')),
                            ),
                          ); // Navigasi ke halaman chat
                        },
                      ),
                      Divider(),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(
          builder: (context) => UserList(),
        )),
        child: Icon(Icons.message),
        backgroundColor: Color.fromARGB(255, 52, 215, 112),
      ),
    );
  }
}
