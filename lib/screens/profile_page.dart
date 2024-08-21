import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:messaging_app/auth.dart';

class ProfilePage extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Your Profile")),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('users').where(FieldPath.documentId, isEqualTo: Auth().currentUser!.uid).snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          final user = snapshot.data!.docs.first;
          return Column(
            children: [
              Icon(Icons.account_circle),
              SizedBox(height: 16),
              Text(
                user.get('name'),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                Auth().currentUser!.email ?? "Your Email",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
  
}