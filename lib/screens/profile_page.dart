import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:messaging_app/auth.dart';

class ProfilePage extends StatelessWidget{
  final _nameController = TextEditingController();

  ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    Scaffold(
      appBar: AppBar(title: const Text("Your Profile")),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Profil'),
        backgroundColor: Colors.teal,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('users').where(FieldPath.documentId, isEqualTo: Auth().currentUser!.uid).snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final user = snapshot.data!.docs.first;
          return Center( // Menempatkan konten di tengah secara horizontal dan vertikal
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center, // Mengatur agar konten berada di tengah secara vertikal
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage('images/unknown.png'), // Ganti dengan image profil yang valid
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        user.get('name'),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () async{
                          _nameController.text = user.get('name');
                          await showModalBottomSheet(
                            isScrollControlled: true,
                            context: context, 
                            builder: (BuildContext ctx) {
                              return Padding(
                                padding: EdgeInsets.only(
                                  top: 20,
                                  left: 20,
                                  right: 20,
                                  bottom: MediaQuery.of(ctx).viewInsets.bottom + 20
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 15),
                                      child: TextField(
                                        controller: _nameController,
                                        decoration: const InputDecoration(labelText: 'Ubah Nama'),
                                      ),
                                    ),
                                    ElevatedButton(
                                      child: const Text('Simpan'),
                                      onPressed: () async {
                                        final String name = _nameController.text;
                                        if(name != null){
                                            await FirebaseFirestore.instance.collection('users')
                                              .doc(user.id)
                                              .update({'name': name})
                                            ;

                                          _nameController.text = user.get('name');

                                          if(!context.mounted) return;
                                          Navigator.pop(context);
                                        }
                                      }, 
                                    )
                                  ],
                                ),
                              );
                            },
                          );
                        }, 
                        icon: const Icon(Icons.edit)
                      )
                      
                    ],
                  ),
                  SizedBox(height: 10),
                  Text('Email: ${Auth().currentUser!.email ?? "Your Email"}',),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async{
                      await Auth().signOut();
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    child: Text('Logout'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
  
}