import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ongolf_tech_mamagement_system/Pro%20Shop/AddProShopItem.dart';
import 'package:ongolf_tech_mamagement_system/homePage.dart';

class ProShop extends StatefulWidget {
  const ProShop({super.key});

  @override
  State<ProShop> createState() => _ProShopState();
}

class _ProShopState extends State<ProShop> {
  String selectedClubName = '';
  List<String> clubNames = [];
  String profileImageUrl = 'null';
  String clubName = 'null';

  Future<void> fetchClubNames() async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) return;
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(currentUserId).get();
    final homeClub = userDoc['Home club'];
    setState(() {
      selectedClubName = homeClub;
    });
    final clubNamesDoc = await FirebaseFirestore.instance.collection('clubs').get();
    final clubNamesList = clubNamesDoc.docs.map((doc) => doc['Club Name'] as String).toList();
    setState(() {
      clubNames = clubNamesList;
    });
  }

  DropdownButton<String> buildDropClubDown() {
    return DropdownButton<String>(
      value: selectedClubName,
      onChanged: (String? newValue) {
        setState(() {
          selectedClubName = newValue!;
          // Fetch golfGear items for the selected club
        });
      },
      items: clubNames.map<DropdownMenuItem<String>>((String value) {
        final parts = value.split(' ');
        final displayName = parts.isNotEmpty ? parts[0] : value;
        return DropdownMenuItem<String>(
          value: value,
          child: Text(displayName),
        );
      }).toList(),
    );
  }

  @override
  void initState() {
    super.initState();
    fetchClubNames();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade100,
      body: Column(
        children: [
          buildSearchBar(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                height: 40,
                margin: const EdgeInsets.all(5),
                padding: const EdgeInsets.only(left: 12, right: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[600],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Text(
                    "All",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              Column(
                children: [
                  buildCategoryContainer("Hats"),
                  buildCategoryContainer("Shoes"),
                ],
              ),
              Column(
                children: [
                  buildCategoryContainer("Balls"),
                  buildCategoryContainer("Bags"),
                ],
              ),
              Column(
                children: [
                  buildCategoryContainer("Clubs"),
                  buildCategoryContainer("Carts"),
                ],
              ),
              const Spacer(),
              buildDropClubDown(),
            ],
          ),
          FutureBuilder(
            future: fetchGearItems(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else {
                final gearItems = snapshot.data!.docs;
                return buildProShopItems(gearItems, context);
              }
            },
          ),
          buildOptionButtons()
        ],
      ),
    );
  }

  Expanded buildProShopItems(List<QueryDocumentSnapshot<Object?>> gearItems, BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = (screenWidth / 150).floor(); // Adjust the 150 according to your item width

    return Expanded(
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 8.0, // Increased spacing for better readability
          mainAxisSpacing: 8.0, // Increased spacing for better readability
          childAspectRatio: 0.7, // Adjust the aspect ratio according to your needs
        ),
        itemCount: gearItems.length,
        itemBuilder: (BuildContext context, int index) {
          final gearItem = gearItems[index];
          final gearName = gearItem['Gear Name'];
          final quantity = gearItem['Quantity'];
          final price = gearItem['Price'];
          final imageUrl = gearItem['Food Image'];

          return Card(
            elevation: 2.0, // Add elevation for a card-like effect
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    height: 135.0, // Adjust the height of the image
                    width: double.infinity, // Take the full width of the card
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            gearName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4.0),
                          Text('Quantity: $quantity'),
                          Text('Price: N\$ $price'),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<QuerySnapshot> fetchGearItems() async {
    return FirebaseFirestore.instance.collection('Pro Shops').get();
  }

  Container buildOptionButtons() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white54,
        borderRadius: BorderRadius.circular(10),
      ),
      width: 140,
      height: 70,
      child: Center(
        child: Row(
          children: [
            const Spacer(),
            FloatingActionButton(
              onPressed: () {}, // cartButton,
              backgroundColor: Colors.white,
              child: const Icon(Icons.shopping_cart, color: Colors.green),
            ),
            const Spacer(),
            FloatingActionButton(
              onPressed: AddProShopItem1,
              backgroundColor: Colors.white,
              child: const Icon(Icons.add_business, color: Colors.green),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  void AddProShopItem1() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) {
        final currentUser = FirebaseAuth.instance.currentUser;
        return StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('clubs').doc(currentUser!.uid).snapshots(),
          builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            // Get club name from snapshot data
            final clubName = snapshot.data!['Club Name'] as String;
            // Return the EatAndDrinks page with the clubName parameter
            return AddProShopItem(
              clubName: clubName,
            );
          },
        );
      }),
    );
  }

  Widget buildCategoryContainer(String categoryName) {
    return Column(
      children: [
        Container(
          height: 20,
          margin: const EdgeInsets.all(1),
          padding: const EdgeInsets.only(left: 12, right: 12),
          decoration: BoxDecoration(
            color: Colors.grey[600],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              categoryName,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4), // Spacing between containers
      ],
    );
  }

  Container buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      margin: const EdgeInsets.only(top: 20),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    final currentUser = FirebaseAuth.instance.currentUser;
                    return StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).snapshots(),
                      builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        }
                        if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        }
                        return MyHomePage1(
                        );
                      },
                    );
                  },
                ),
              );
            },
            icon: const Icon(Icons.arrow_back, size: 32),
          ),
          const Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search in pro shop",
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
