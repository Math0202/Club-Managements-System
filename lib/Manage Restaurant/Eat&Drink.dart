// ignore: file_names
// ignore_for_file: avoid_function_literals_in_foreach_calls

import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ongolf_tech_mamagement_system/Manage%20Club%20Page/clubs_page.dart';
import 'package:ongolf_tech_mamagement_system/Manage%20Events/eventsPage.dart';
import 'package:ongolf_tech_mamagement_system/Manage%20Restaurant/addingFoodDrinks.dart';
import 'package:ongolf_tech_mamagement_system/Manage%20Restaurant/foodAndDrinksCart.dart';
import 'package:ongolf_tech_mamagement_system/Pro%20Shop/proShop.dart';
import 'package:ongolf_tech_mamagement_system/basic%20components/my_textfied.dart';
import 'package:ongolf_tech_mamagement_system/homePage.dart';



class EatAndDrink extends StatefulWidget {
  final String clubName;
  const EatAndDrink({super.key,
  required this.clubName
  });

  @override
  State<EatAndDrink> createState() => _EatAndDrinkState();
}

  bool restaurantApproval = false;
  bool customerConfirmation = false;

final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
final currentUserId = _firebaseAuth.currentUser!.uid;
  final foodNameController = TextEditingController();
  final foodPriceController = TextEditingController();
  String clubProfileImageUrl = 'null';
  String clubName = 'null';

class _EatAndDrinkState extends State<EatAndDrink> {
 

  TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> foodItems = [];
  List<Map<String, dynamic>> selectedFoodItems = [];
  

    @override
  void initState() {
    super.initState();
    fetchFoodItems();
  }

  Future<void> fetchFoodItems() async {
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore
    .instance.collection('Food and Drinks').get();
    setState(() {
      foodItems = querySnapshot.docs.map((doc) => doc.data()).toList();
      selectedFoodItems = foodItems.where((food) => food['Club Name'] == widget.clubName).toList();
    });
  }

  List<Map<String, dynamic>> getFilteredFoodItems() {
  String query = searchController.text.toLowerCase();
  return selectedFoodItems
      .where((food) =>
          food['Food Name'].toLowerCase().contains(query) &&
          food['Club Name'].toLowerCase().contains(widget.clubName.toLowerCase()))
      .toList();
}


  Container buildSearchBar() {
    return Container(
          margin: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.grey),
          ),
          child: Center(
            child: TextField(
              controller: searchController,
                onChanged: (value) {
                  setState(() {});
                },
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Search food & drinks...',
                prefixIcon: Icon(Icons.search),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
          ),
        );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade100,
      body: Expanded(
  child: Column(
    children: [
      buildSearchBar(),
      Expanded(
        child: GridView.count(
          crossAxisCount: 4,
          mainAxisSpacing: 10,
          crossAxisSpacing: 15,
          padding: const EdgeInsets.all(15),
          children: getFilteredFoodItems().map<Widget>((food) {
            return FoodTile(
              foodId: food['Food Id'],
              assetPath: food['Food Image'],
              foodName: food['Food Name'],
              foodPrice: food['Price'],
              onSelectionChanged: (isSelected) {
                setState(() {});
              },
              foodItems: foodItems,
            );
          }).toList(),
        ),
      ),
      Container(
        margin: EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white54,
          borderRadius: BorderRadius.circular(10),
        ),
        width: 140,
        child: Center(
          child: Row(
            children: [
              const Spacer(),
              FloatingActionButton(
                onPressed: cartButton,
                backgroundColor: Colors.white,
                child: const Icon(Icons.shopping_cart, color: Colors.green),
              ),
              const Spacer(),
              FloatingActionButton(
                onPressed: addFoodorDrink1,
                backgroundColor: Colors.white,
                child: const Icon(Icons.add_business, color: Colors.green),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    ],
  ),
),

    );
  }

    void addFoodorDrink1() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context)  {
  final currentUser = FirebaseAuth.instance.currentUser;
  // Fetch club name from Firestore using the current user's ID
  // Replace 'clubs' with your Firestore collection name
  return StreamBuilder<DocumentSnapshot>(
    stream: FirebaseFirestore.instance.collection('clubs').doc(currentUser!.uid).snapshots(),
    builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        // Handle loading state
        return const CircularProgressIndicator();
      }
      if (snapshot.hasError) {
        // Handle error
        return Text('Error: ${snapshot.error}');
      }
      // Get club name from snapshot data
      final clubName = snapshot.data!['Club Name'] as String;
      // Return the EatAndDrinks page with the clubName parameter
      return AddFoodAndDrink(
        clubName: clubName,
      );
    },
   );
  }
 ));
}


  void cartButton() {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FoodAndDrinksCart(clubName: widget.clubName,),
        ),
    );
  }

}





class FoodTile extends StatefulWidget {
  final String assetPath;
  final String foodName;
  final int foodPrice;
  final Function(bool) onSelectionChanged;
  final String foodId;
   final List<Map<String, dynamic>> foodItems; 

  const FoodTile({
    super.key,
    required this.assetPath,
    required this.foodName,
    required this.foodPrice,
    required this.onSelectionChanged,
    required this.foodId,
    required this.foodItems,
  });

  @override
  // ignore: library_private_types_in_public_api
  _FoodTileState createState() => _FoodTileState();
}

class _FoodTileState extends State<FoodTile> {
  bool isSelected = true;

  @override
  void initState() {
    super.initState();
  }


void updateFoodTile() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      FilePickerResult? newPickedFile;
      String? imageUrl;

      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            title: Text('Update Food Details'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                MyTextFied(
                  hintText: 'Enter New Food Name',
                  obscureText: false,
                  controller: foodNameController,
                ),
                MyTextFied(
                  hintText: 'Enter New Food Price',
                  obscureText: false,
                  controller: foodPriceController,
                ),
                ElevatedButton(
                  onPressed: () async {
                    newPickedFile = await FilePicker.platform.pickFiles();
                    setState(() {});
                  },
                  child: Text('Select New Image'),
                ),
                if (newPickedFile != null)
                  Container(
                    height: 100,
                    width: 100,
                    child: Image.memory(
                      newPickedFile!.files.first.bytes!,
                      fit: BoxFit.cover,
                    ),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  if (newPickedFile != null) {
                    Reference ref = FirebaseStorage.instance
                        .ref()
                        .child('food_images')
                        .child(widget.foodId);
                    await ref.putData(newPickedFile!.files.first.bytes!);
                    imageUrl = await ref.getDownloadURL();
                  }

                  QuerySnapshot<Map<String, dynamic>> querySnapshot =
                      await FirebaseFirestore.instance
                          .collection('Food and Drinks')
                          .where('Food Id', isEqualTo: widget.foodId)
                          .get();

                  if (querySnapshot.docs.isNotEmpty) {
                    String docId = querySnapshot.docs.first.id;
                    await FirebaseFirestore.instance
                        .collection('Food and Drinks')
                        .doc(docId)
                        .update({
                         if(foodNameController.text.isNotEmpty) "Food Name": foodNameController.text,
                        if(foodPriceController.text.isNotEmpty) "Price": int.parse(foodPriceController.text),
                        if (imageUrl != null) "Food Image": imageUrl,
                    });
                  }
                  
                  Navigator.pop(context);
                },
                child: Text('Update'),
              ),
            ],
          );
        },
      );
    },
  );
}




void toggleSelection() async {
  setState(() {
    isSelected = !isSelected;
  });

  // Find the document ID of the food item
  QuerySnapshot<Map<String, dynamic>> querySnapshot =
      await FirebaseFirestore.instance
          .collection('Food and Drinks')
          .where('Food Id', isEqualTo: widget.foodId)
          .get();

  if (querySnapshot.docs.isNotEmpty) {
    String docId = querySnapshot.docs.first.id;

    // Update the 'Available' field based on the toggle state
    await FirebaseFirestore.instance
        .collection('Food and Drinks')
        .doc(docId)
        .update({'Available': isSelected});
  }
}

//deleteing a food tile
void deleteFoodTile() async {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title:const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete ${widget.foodName} permanently?'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              // Find the document ID of the tapped food tile
              QuerySnapshot<Map<String, dynamic>> querySnapshot =
                  await FirebaseFirestore.instance
                      .collection('Food and Drinks')
                      .where('Food Id', isEqualTo: widget.foodId)
                      .get();

              if (querySnapshot.docs.isNotEmpty) {
                String docId = querySnapshot.docs.first.id;

                // Delete the document from Firestore
                await FirebaseFirestore.instance
                    .collection('Food and Drinks')
                    .doc(docId)
                    .delete();

                // Update the UI to reflect the deletion
                setState(() {
                  widget.foodItems.removeWhere((food) => food['Food Id'] == widget.foodId);
                });
              }

              Navigator.of(context).pop(); // Close the dialog
            },
            child: Text('Delete'),
          ),
        ],
      );
    },
  );
}





  @override
 Widget build(BuildContext context) {
  return LayoutBuilder(
    builder: (context, constraints) {
      return SizedBox(
        height: constraints.maxHeight,
        width: constraints.maxWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  margin: const EdgeInsets.all(0.01),
                  height: constraints.maxHeight * 0.66,
                  width: constraints.maxWidth * 0.9875,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    image: DecorationImage(
                      image: NetworkImage(widget.assetPath),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height:  30,
                    width: 30,
                    alignment: Alignment.bottomCenter,
                    decoration: BoxDecoration(
                        color: Colors.grey[800]!.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.all(8),
                    margin: const EdgeInsets.all(8),
                    child: InkWell(
                      onTap: toggleSelection,
                      child: Icon(
                        isSelected ? Icons.check_box :
                        Icons.check_box_outline_blank ,
                        color: Colors.black,
                        size: 10,
                      ),
                    ),
                  ),
                  Container(
                    height: 30,
                    width: 30,
                    alignment: Alignment.bottomCenter,
                    decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.all(8),
                    margin: const EdgeInsets.all(8),
                    child: InkWell(
                      onTap: updateFoodTile,
                      child: const Center(
                        child: Icon(
                          Icons.edit_note_rounded,
                          color: Colors.white,
                          size: 10,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height:  30,
                    width: 30,
                    alignment: Alignment.bottomCenter,
                    decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.all(8),
                    margin: const EdgeInsets.all(8),
                    child: InkWell(
                      onTap: deleteFoodTile,
                      child: const Center(
                        child: Icon(
                          Icons.delete,
                          color: Colors.red,
                          size: 10,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
          Container(
            width: constraints.maxWidth * 0.9875,
            height: 50,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
              borderRadius: BorderRadiusDirectional.circular(5),
            ),
            alignment: Alignment.topLeft,
            child: Text(
              'NAD ${widget.foodPrice} \n${widget.foodName}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontSize: 12
              ),
            ),
          ),
        ],
      ),
    );});
  }
}