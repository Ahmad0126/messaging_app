import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:messaging_app/auth.dart';
import 'package:messaging_app/screens/chat_screen.dart';

class UserList extends StatefulWidget{

  @override
  _UserListState createState() => _UserListState();
}

class _UserListState extends State<UserList> {

  Future<dynamic> _makeChat(user2)async{
    var id = "";
    bool exist = false;
    await FirebaseFirestore.instance.collection('chats').where('participants', arrayContains: user2).get().then((value) {
      if (value.docs.isNotEmpty) {
        exist = true;
        for(var chat in value.docs){
          id = chat.id;
        }
      }
    });
    if(!exist){
      await FirebaseFirestore.instance.collection('chats').add({
        'participants': [Auth().currentUser!.uid, user2],
        'last_message': "",
        'timestamp': FieldValue.serverTimestamp(),
      }).then((value) {
        id = value.id;
      });
    }
    return id;
  }
  Stream<QuerySnapshot<Map<String, dynamic>>> cari() {
    if(_searchController.text != ''){
      return FirebaseFirestore.instance.collection('users')
        .where('name', isEqualTo: _searchController.text)
        .where(FieldPath.documentId, isNotEqualTo: Auth().currentUser!.uid)
        .snapshots();
    }else{
      return FirebaseFirestore.instance.collection('users').where(FieldPath.documentId, isNotEqualTo: Auth().currentUser!.uid).snapshots();
    }
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
                  onPressed: () => cari,
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: cari(), 
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