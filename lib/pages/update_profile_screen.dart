import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'profile_screen.dart';

class UpdateProfileScreen extends StatefulWidget {
  const UpdateProfileScreen({Key? key}) : super(key: key);

  @override
  _UpdateProfileScreenState createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  TextEditingController fullNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController? currentPasswordController;
  TextEditingController? newPasswordController;

  String profileImageUrl = '';
  File? pickedImage; // Add a File variable to hold the picked image

  String storedPassword =
      ''; // Variable to store the password retrieved from Firestore

  @override
  void initState() {
    super.initState();
    retrieveUserData();

    // Initialize the currentPasswordController and newPasswordController
    currentPasswordController = TextEditingController();
    newPasswordController = TextEditingController();
  }

  Future<void> retrieveUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (snapshot.exists) {
        setState(() {
          fullNameController.text = snapshot['fullname'];
          emailController.text = snapshot['email'];
          profileImageUrl = snapshot['image'];
          storedPassword = snapshot['password']; // Retrieve the stored password
        });
      }
    }
  }

  void openImagePicker() async {
    final picker = ImagePicker();
    final pickedImageFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImageFile != null) {
      setState(() {
        pickedImage = File(pickedImageFile.path); // Store the picked image file
      });
    }
  }

  Future<String> uploadImageToFirebase() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && pickedImage != null) {
      final storageRef =
          FirebaseStorage.instance.ref().child('users/${user.uid}');
      final uploadTask = await storageRef.putFile(pickedImage!);
      if (uploadTask.state == TaskState.success) {
        final downloadUrl = await storageRef.getDownloadURL();
        return downloadUrl;
      }
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(LineAwesomeIcons.angle_left),
        ),
        title: Text(tEditProfile, style: Theme.of(context).textTheme.headline4),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(tDefaultSize),
          child: Column(
            children: [
              Stack(
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: pickedImage != null
                          ? Image.file(pickedImage!)
                          : profileImageUrl.isNotEmpty
                              ? Image.network(profileImageUrl)
                              : Image.asset(tProfileImage),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 35,
                      height: 35,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: tPrimaryColor,
                      ),
                      child: IconButton(
                        icon: const Icon(
                          LineAwesomeIcons.camera,
                          color: Colors.black,
                          size: 20,
                        ),
                        onPressed: openImagePicker,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 50),
              Form(
                child: Column(
                  children: [
                    TextFormField(
                      controller: fullNameController,
                      decoration: InputDecoration(
                        labelText: "Full Name",
                        prefixIcon: Icon(LineAwesomeIcons.user),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: emailController,
                      enabled: false,
                      decoration: InputDecoration(
                        labelText: "Email",
                        prefixIcon: Icon(LineAwesomeIcons.envelope_1),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: currentPasswordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: "Current Password",
                        prefixIcon: const Icon(Icons.fingerprint),
                        suffixIcon: IconButton(
                          icon: const Icon(LineAwesomeIcons.eye_slash),
                          onPressed: () {},
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: newPasswordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: "New Password",
                        prefixIcon: const Icon(Icons.fingerprint),
                        suffixIcon: IconButton(
                          icon: const Icon(LineAwesomeIcons.eye_slash),
                          onPressed: () {},
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => updateProfile(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: tPrimaryColor,
                          side: BorderSide.none,
                          shape: const StadiumBorder(),
                        ),
                        child: const Text(
                          tEditProfile,
                          style: TextStyle(color: tDarkColor),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text.rich(
                          TextSpan(
                            text: "Joined",
                            style: TextStyle(fontSize: 12),
                            children: [
                              TextSpan(
                                text: "JoinedAt",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent.withOpacity(0.1),
                            elevation: 0,
                            foregroundColor: Colors.red,
                            shape: const StadiumBorder(),
                            side: BorderSide.none,
                          ),
                          child: const Text("Delete"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void updateProfile() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        if (currentPasswordController != null &&
            currentPasswordController!.text.isNotEmpty) {
          String enteredPassword = currentPasswordController!.text.trim();

          // Check if the entered password matches the stored password
          if (enteredPassword != storedPassword) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Wrong current password.')),
            );
            return; // Exit the method if the current password is incorrect
          }

          AuthCredential credential = EmailAuthProvider.credential(
            email: user.email!,
            password: enteredPassword,
          );
          await user.reauthenticateWithCredential(credential);
        }

        await user.updateEmail(emailController.text.trim());

        if (newPasswordController != null &&
            newPasswordController!.text.isNotEmpty) {
          String newEnteredPassword = newPasswordController!.text.trim();

          // Update the password in Firestore
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .update({
            'password': newEnteredPassword,
          });
        }

        if (pickedImage != null) {
          String imageUrl = await uploadImageToFirebase();
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .update({
            'fullname': fullNameController.text.trim(),
            'image': imageUrl,
          });
        } else {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .update({
            'fullname': fullNameController.text.trim(),
          });
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully.')),
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => ProfileScreen()),
        );
      } catch (error) {
        if (error is FirebaseAuthException) {
          if (error.code == 'wrong-password') {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Wrong current password.')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update profile: $error')),
          );
        }
      }
    }
  }
}
