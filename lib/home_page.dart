import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _logout(BuildContext context) async {
    await _auth.signOut();
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;
    String displayName = '';

    if (user != null) {
      return FutureBuilder<DocumentSnapshot>(
        future: _firestore.collection('users').doc(user.uid).get(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Text('User data not found');
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>;

          if (user.providerData.first.providerId == 'password') {
            // User logged in with email and password
            displayName = userData['fullname'] ?? 'Unknown User';
          } else if (user.providerData.first.providerId == 'google.com') {
            // User logged in with Google authentication
            displayName = user.displayName ?? user.email ?? 'Unknown User';
          }

          return Scaffold(
            appBar: AppBar(
              title: Text('Home'),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Welcome $displayName',
                    style: TextStyle(fontSize: 20),
                  ),
                  SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () => _logout(context),
                    child: Text('Logout'),
                  ),
                ],
              ),
            ),
          );
        },
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text('Home'),
        ),
        body: Center(
          child: Text('User not logged in'),
        ),
      );
    }
  }
}
