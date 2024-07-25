// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ongolf_tech_mamagement_system/basic%20components/my_button.dart';
import 'package:ongolf_tech_mamagement_system/basic%20components/my_textfied.dart';
import 'package:uuid/uuid.dart';

class AddProShopItem extends StatefulWidget {
  final String clubName;
  const AddProShopItem({
    super.key, 
    required this.clubName
    });

  @override
  State<AddProShopItem> createState() => _AddProShopItemState();
}

class _AddProShopItemState extends State<AddProShopItem> {
  PlatformFile? pickedFile;
  final gearNameController = TextEditingController();
  final categoryController = TextEditingController();
  final quantityNameController = TextEditingController();
  final PriceController = TextEditingController();
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
    gearNameController.dispose();
    PriceController.dispose();
    categoryController.dispose();
    quantityNameController.dispose();
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


void showValidationErrorDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return const AlertDialog(
        title: Text('Error'),
        content: Text('Please fill in all fields.'),
      );
    },
  );
}



Future<void> golfGearDetail(
  String clubId, String gearName, int price, String clubName, String quantity, String categoryName
) async {
  if (gearName.isEmpty || quantity.isEmpty || categoryName.isEmpty) {
  print("******************************************");
  showValidationErrorDialog(context);
  return;
}


  try {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    if (user != null) {
      // Generate a unique gearIDs
      String gearId = const Uuid().v4();
      // Upload image file
      String imageUrl = '';
      if (pickedFile != null) {
        Reference ref = FirebaseStorage.instance
            .ref()
            .child('gear_images')
            .child(gearId);
        await ref.putData(selectedImageInBytes!);
        imageUrl = await ref.getDownloadURL();
      }
      // Add data to Firestore
      await FirebaseFirestore.instance.collection('Pro Shops').add({
        "Gear Id": gearId,
        "Gear Name": gearName,
        "Quantity": quantity,
        "Category": categoryName,
        "Club Name": clubName,
        "Price": price,
        "Food Image": imageUrl,
        "ClubId": user.uid,
        "Available": true,
      });
      // Reset controllers and picked file
      gearNameController.clear();
      PriceController.clear();
      setState(() {
        pickedFile = null;
      });
    } else {
      throw Exception("User not logged in");
    }
  } catch (e) {
    String errorMessage = 'Failed to add item. Please try again.';
    if (e is FirebaseException) {
      errorMessage = e.message!;
    } else if (e is PlatformException) {
      errorMessage = e.message!;
    } else if (e is SocketException) {
      errorMessage = 'Network error. Please check your internet connection and try again.';
    } else if (e is FirebaseAuthException) {
      errorMessage = 'Authentication error. Please log in again.';
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(errorMessage),
        );
      },
    );
  } finally {
    setState(() {
      isUploading = false;
    });
  }
}




    Future<void> addProShopItem() async {
        if (selectedImageInBytes == null) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const AlertDialog(
          title: Text('Error'),
          content: Text('Please select an image to upload.'),
        );
      },
    );
    return;
  }
    await golfGearDetail(
      user.uid,
      gearNameController.text,
      int.parse(PriceController.text),
      widget.clubName,
      quantityNameController.text,
      categoryController.text
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
                  Icons.sports_baseball,
                  size: 100,
                ),
              ),
              const Text(
                "Add a golfing gear",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w300),
              ),
              const SizedBox(height: 50),
              MyTextFied(
                controller: gearNameController,
                hintText: 'Enter Gear Name',
                obscureText: false,
              ),
              MyTextFied(
                controller: PriceController,
                hintText: 'Enter Gear Price as a whole number.',
                obscureText: false,
              ),
              MyTextFied(
                controller: quantityNameController,
                hintText: 'Enter the quantity.',
                obscureText: false,
              ),
              categoryDropDown(),
            const SizedBox(height: 10),
              // Image preview
              if (pickedFile != null)
                buildImagesPreview(),
              ElevatedButton(
                onPressed: selectedImage,
                child: Text('Select Image'),
              ),
              MyButton(onTap: addProShopItem, text: "Add gear"),
            ],
          ),
        ),
      ),
    );
  }

  Container buildImagesPreview() {
    return Container(
                height: 250,
                width: 250,
                color: Colors.green.shade200,
                child: Image.memory(
                  Uint8List.fromList(pickedFile!.bytes!),
                  fit: BoxFit.cover,
                ),
              );
  }

  DropdownButtonFormField<String> categoryDropDown() {
    return DropdownButtonFormField<String>(
           value: categoryController.text.isNotEmpty ? categoryController.text : null,
           onChanged: (String? newValue) {
            setState(() {
             categoryController.text = newValue!;
             });
              },
              items: [
                'Gloves',
                'Balls',
                'Hats',
                'Shoes',
                'Clubs',
                'Bags',
                'Carts',
              ].map((String category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
            );
  }
}
