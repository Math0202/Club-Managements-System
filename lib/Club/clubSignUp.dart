import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:ongolf_tech_mamagement_system/basic%20components/my_button.dart';
import '../basic components/my_textfied.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';



class ClubSignUp extends StatefulWidget {
  const ClubSignUp({super.key});

  @override
  State<ClubSignUp> createState() => _ClubSignUpState();
}

class _ClubSignUpState extends State<ClubSignUp> {
  PlatformFile? pickedFile;

  final clubNameController = TextEditingController();
  final clubDiscriptionController = TextEditingController();
  final contactNumberController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController1 = TextEditingController();
  final passwordController2 = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    clubDiscriptionController.dispose();
    contactNumberController.dispose();
    clubNameController.dispose();
    passwordController1.dispose();
    passwordController2.dispose();
    super.dispose();
  }

  Future<void> clubSignUp() async {
    try {
      if (passwordController1.text.trim() == passwordController2.text.trim()) {
        final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController1.text.trim(),
        );

        final userId = userCredential.user!.uid;

        await clubDetails(
          userId,
          clubNameController.text.trim(),
          clubDiscriptionController.text.trim(),
          int.parse(contactNumberController.text.trim()),
        );

        await uploadClubImage(userId);

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return const AlertDialog(
              title: Text('Successful'),
              content:  Text("Check your email inbox to verify your email."),
            );
          },
        );
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return const AlertDialog(
              title: Text('Sign up error'),
              content: Text("Passwords don't match, try again."),
            );
          },
        );
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text(e.toString()),
          );
        },
      );
    }
  }

  Future<void> clubDetails(String clubId, String clubName, String clubDiscription, int contactNumber) async {
    try {
      await FirebaseFirestore.instance.collection("clubs").doc(clubId).set({
        'Club Name': clubName,
        'Club Discription': clubDiscription,
        'Contact Number': contactNumber,
        'isClub': true,
      });
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text(e.toString()),
          );
        },
      );
    }
  }

  Future<void> uploadClubImage(String userId) async {
    if (pickedFile == null || pickedFile!.path == null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const AlertDialog(
            title: Text('Error uploading file'),
            content: Text('No file selected.'),
          );
        },
      );
      return;
    }

    final path = 'clubs/$userId/profilepic/${pickedFile!.name}';
    final file = File(pickedFile!.path!);
    final ref = FirebaseStorage.instance.ref().child(path);

    try {
      await ref.putFile(file);
      final downloadUrl = await ref.getDownloadURL();

      print('Download URL: $downloadUrl'); // Debugging

      await FirebaseFirestore.instance.collection("clubs").doc(userId).update({
        'Profile Picture': downloadUrl,
      });
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error uploading file'),
            content: Text(e.toString()),
          );
        },
      );
    }
  }

  Future<void> selectedImage() async {
    final results = await FilePicker.platform.pickFiles();
    if (results == null) return;
    setState(() {
      pickedFile = results.files.first;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade100,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 30),
              const Center(
                child: Icon(
                  Icons.golf_course,
                  size: 100,
                ),
              ),
              const SizedBox(height: 50),
              Text(
                'Sign-up page for golf clubs only.',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 50 / 2.5),
              // Player registration form
              MyTextFied(
                controller: clubNameController,
                hintText: 'Full name.',
                obscureText: false,
              ),
              const SizedBox(height: 25),
              MyTextFied(
                controller: clubDiscriptionController,
                hintText: 'Club description.',
                obscureText: false,
              ),
              const SizedBox(height: 25),
              MyTextFied(
                controller: contactNumberController,
                hintText: 'Contact no.',
                obscureText: false,
              ),
              const SizedBox(height: 25),
              MyTextFied(
                controller: emailController,
                hintText: 'Email.',
                obscureText: false,
              ),
              const SizedBox(height: 25),
              MyTextFied(
                controller: passwordController1,
                hintText: 'Create password.',
                obscureText: true,
              ),
              const SizedBox(height: 25),
              MyTextFied(
                controller: passwordController2,
                hintText: 'Confirm password.',
                obscureText: true,
              ),
              const SizedBox(height: 10),

              // Image button
              /*if (pickedFile != null)
                Container(
                  height: 50,
                  width: 50,
                  color: Colors.green.shade200,
                  child: Image.file(
                    File(pickedFile!.path!),
                    fit: BoxFit.cover,
                  ),
                ),*/
              ElevatedButton(onPressed: selectedImage, child: const Text('Select showcase image')),
              SizedBox(height: 10),

              // Sign in button
              MyButton(
                onTap: clubSignUp,
                text: 'Sign up!   ',
              ),
              const SizedBox(height: 70),

              GestureDetector(
                onTap: () {
                 // Navigator.push(context, MaterialPageRoute(builder: (context) => const MemberLogin()));
                },
                child: const Text(
                  'Already have an account?\n Back to login.',
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}