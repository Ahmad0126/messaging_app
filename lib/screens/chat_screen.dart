// chat_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:test_chat/auth.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String nama;

  const ChatScreen({super.key, required this.chatId, required this.nama});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();

  Future<void> _sendMessage() async {
    final user = FirebaseAuth.instance.currentUser;
    if(_messageController.text != ''){
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
    }
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: Image.asset('images/unknown.png').image, // Replace with actual profile image
            ),
            const SizedBox(width: 10),
            Text(widget.nama),
          ],
        ),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.call),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.videocam),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
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
                  return const Center(child: CircularProgressIndicator());
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
                          return const Center(child: CircularProgressIndicator());
                        }
                        DateTime time = message['timestamp'].toDate();
                        var tanggal = DateFormat('d MMM y H:mm').format(time);
                        var usere = message['user_id'] == Auth().currentUser!.uid;
                        return Align(
                          alignment: usere
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                            decoration: BoxDecoration(
                              color: usere ? Colors.teal[100] : Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              children: [
                                Text( message['message'] ),
                                Text(tanggal, style: const TextStyle(fontSize: 11)),
                              ],
                            ),
                          ),
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
                IconButton(
                  icon: const Icon(Icons.emoji_emotions_outlined),
                  onPressed: () {},
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.attach_file),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
