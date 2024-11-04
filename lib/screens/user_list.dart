import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:test_chat/auth.dart';
import 'package:test_chat/screens/chat_screen.dart';

class UserList extends StatefulWidget{
  const UserList({super.key});


  @override
  _UserListState createState() => _UserListState();
}

class _UserListState extends State<UserList> {

  Future<dynamic> _makeChat(user2)async{
    var id = "";
    bool exist = false;
    await FirebaseFirestore.instance.collection('chats').where('participants', arrayContains: user2).get().then((value) {
      if (value.docs.isNotEmpty) {
        for(var chat in value.docs){
          if(chat.get('participants').contains(Auth().currentUser!.uid)){
            exist = true;
            id = chat.id;
          }
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
  void cari() {
    if(_searchController.text != ''){
      user = FirebaseFirestore.instance.collection('users')
        .orderBy('name').startAt([_searchController.text]).endAt(["${_searchController.text}\uf8ff"])
        .where(FieldPath.documentId, isNotEqualTo: Auth().currentUser!.uid)
        .snapshots();
    }else{
      user = FirebaseFirestore.instance.collection('users').where(FieldPath.documentId, isNotEqualTo: Auth().currentUser!.uid).snapshots();
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> user = FirebaseFirestore.instance.collection('users').where(FieldPath.documentId, isNotEqualTo: Auth().currentUser!.uid).snapshots();
  final _searchController = TextEditingController();
  bool isSearching = false;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: !isSearching
            ? Text('Contacts', style: TextStyle(color: Colors.white))
            : TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.white),
                ),
                style: TextStyle(color: Colors.white),
                onChanged: (query) {
                  setState(() {
                    cari();
                  });
                },
              ),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
            icon: Icon(isSearching ? Icons.close : Icons.search, color: Colors.white),
            onPressed: () {
              setState(() {
                isSearching = !isSearching; // Toggle antara pencarian dan tidak
                if(!isSearching){
                  user = FirebaseFirestore.instance.collection('users').where(FieldPath.documentId, isNotEqualTo: Auth().currentUser!.uid).snapshots();
                }
              });
            },
          ),
        ],
      ),
      body: StreamBuilder(
        stream: user, 
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final users = snapshot.data!.docs;
          return ListView.separated(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFF6B7B82),
                  child: Icon(Icons.person), // Ganti dengan image profil yang valid
                ),
                title: Text(user['name']),
                subtitle: Text(user.id),
                onTap: () async{
                  var chatId =  await _makeChat(user.id);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(chatId: chatId, nama: user['name']),
                    ),
                  );
                },
              );
            },
            separatorBuilder: (context, index) {
              return Divider(
                thickness: 1.0, // Ketebalan pemisah
                color: Theme.of(context).dividerColor, // Warna pemisah dari tema
                indent: 16, // Jarak dari kiri
                endIndent: 16, // Jarak dari kanan
              );
            },
          );
        },
      ),
    );
  }
}