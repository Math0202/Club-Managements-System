import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:ongolf_tech_mamagement_system/basic%20components/my_button.dart';
import 'package:ongolf_tech_mamagement_system/basic%20components/my_textfied.dart';
import 'package:uuid/uuid.dart';

class AddFoodAndDrink extends StatefulWidget {
  final String clubName;

  const AddFoodAndDrink({
    super.key,
    required this.clubName,
  });

  @override
  State<AddFoodAndDrink> createState() => _AddFoodAndDrinkState();
}

class _AddFoodAndDrinkState extends State<AddFoodAndDrink> {
  PlatformFile? pickedFile;
  final foodNameController = TextEditingController();
  final foodPriceController = TextEditingController();
  late User user;
  bool isUploading = false;
  
  Uint8List ? selectedImageInBytes;

  @override
  void initState() {
    super.initState();
    // Initialize user
    user = FirebaseAuth.instance.currentUser!;
  }

  @override
  void dispose() {
    foodNameController.dispose();
    foodPriceController.dispose();
    super.dispose();
  }

  Future<void> selectedImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result == null) return;
    setState(() {
      pickedFile = result.files.first;
      selectedImageInBytes = result.files.first.bytes;
      isUploading = true;
    });
  }

Future<void> foodDetails(
      String clubId, String foodName, int foodPrice, String clubName
      ) async {
    print("Adding food or drink...2");
    try {
      FirebaseAuth auth = FirebaseAuth.instance;
      User? user = auth.currentUser;

      if (user != null) {
         print("Adding food or drink...3");
        // Generate a unique foodId
        String foodId = const Uuid().v4();

        // Upload image file
        String imageUrl = '';
        if (pickedFile != null) {
           print("Adding food or drink...4");
          Reference ref = FirebaseStorage.instance
              .ref()
              .child('food_images')
              .child(foodId);
          await ref.putData(selectedImageInBytes!);
          imageUrl = await ref.getDownloadURL();
        }

         print("Adding food or drink...5");
        await FirebaseFirestore.instance.collection('Food and Drinks').add({
          "Food Id": foodId,
          "Food Name": foodNameController.text,
          "Club Name": clubName,
          "Price": int.parse(foodPriceController.text),
          "Food Image": imageUrl,
          "ClubId": user.uid,
          "Available": true,
        });

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Success'),
              content: const Text('Food/drink added successfully!'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );

        // Reset controllers and picked file
        foodNameController.clear();
        foodPriceController.clear();
        setState(() {
          pickedFile = null;
        });
      } else {
        throw Exception("User not logged in");
      }
    } catch (e, stackTrace) {
      print("Error adding food/drink: $e");
      print("Stack Trace: $stackTrace");
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const AlertDialog(
            title: Text('Error'),
            content: Text('Failed to add food/drink. Please try again.'),
          );
        },
      );
    } finally {
      setState(() {
        isUploading = false;
      });
    }
  }


  Future<void> addFoodorDrink() async {
    await foodDetails(
      user.uid,
      foodNameController.text,
      int.parse(foodPriceController.text),
      widget.clubName,
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 30),
              const Center(
                child: Icon(
                  Icons.fastfood_outlined,
                  size: 100,
                ),
              ),
              const Text(
                "Add food or drink",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w300),
              ),
              const SizedBox(height: 50),
              MyTextFied(
                controller: foodNameController,
                hintText: 'Enter Food Name',
                obscureText: false,
              ),
              MyTextFied(
                controller: foodPriceController,
                hintText: 'Enter Food Price as a whole number.',
                obscureText: false,
              ),
              const SizedBox(height: 10),
              // Image preview
              if (pickedFile != null)
                Container(
                  height: 250,
                  width: 250,
                  color: Colors.green.shade200,
                  child: Image.memory(
                    Uint8List.fromList(pickedFile!.bytes!),
                    fit: BoxFit.cover,
                  ),
                ),

              ElevatedButton(
                onPressed: selectedImage,
                child: Text('Select Image'),
              ),
              MyButton(onTap: addFoodorDrink, text: "Add food"),
            ],
          ),
        ),
      ),
    );
  }
}
