// chat_list_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatefulWidget{
  const ChatListScreen({super.key});

  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  bool isSearching = false;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: !isSearching
            ? Text('Chats', style: TextStyle(color: Colors.white))
            : TextField(
                decoration: InputDecoration(
                  hintText: 'Search...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.white),
                ),
                style: TextStyle(color: Colors.white),
                onChanged: (query) {
                  // Logika pencarian, implementasi dapat ditambahkan di sini
                },
              ),
         backgroundColor: Theme.of(context).primaryColor, // Warna dari tema global
        actions: [
          IconButton(
            icon: Icon(isSearching ? Icons.close : Icons.search, color: Colors.white),
            onPressed: () {
              setState(() {
                isSearching = !isSearching; // Toggle antara pencarian dan tidak
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
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
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFF6B7B82),
                          child: Icon(Icons.person), // Ganti dengan image profil yang valid
                        ),
                        title: Text(snap1.data!.get('name'), style: TextStyle(color: Colors.black)), // Warna teks
                        subtitle: Text(chat['last_message'], style: TextStyle(color: Colors.black54)),
                        trailing: Text(tanggal, style: TextStyle(color: Colors.black54)),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(chatId: chat.id, nama: snap1.data!.get('name')),
                            ),
                          ); // Navigasi ke halaman chat
                        },
                      ),
                      Divider(
                        color: Theme.of(context).dividerColor, // Divider menggunakan warna tema
                        thickness: 1,
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/contacts'); // Navigasi ke halaman kontak
        },
        child: Icon(Icons.message, color: Colors.white),
        backgroundColor: Theme.of(context).colorScheme.secondary, // Gunakan warna tombol dari tema
      ),
    );
  }
}
