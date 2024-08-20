import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:messaging_app/auth.dart';
import 'package:messaging_app/screens/chat_screen.dart';

class UserList extends StatelessWidget{

  Future<dynamic> _makeChat(user2)async{
    var id = "";
    await FirebaseFirestore.instance.collection('chats').add({
      'participants': [Auth().currentUser!.uid, user2],
      'last_message': "",
      'timestamp': FieldValue.serverTimestamp(),
    }).then((value) {
      id = value.id;
    });
    return id;
  }

  final _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Make A Chat")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Search a name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance.collection('users').snapshots(), 
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                final users = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return ListTile(
                      title: Text(user['name']),
                      subtitle: Text(user.id),
                      onTap: () async{
                        var chat_id =  await _makeChat(user.id);
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatScreen(chatId: chat_id),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          )
        ],
      )
    );
  }
}