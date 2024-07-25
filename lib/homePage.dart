import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ongolf_tech_mamagement_system/Club/clubSignUp.dart';
import 'package:ongolf_tech_mamagement_system/Manage%20Club%20Page/clubs_page.dart';
import 'package:ongolf_tech_mamagement_system/Manage%20Club%20Page/tabController.dart';
import 'package:ongolf_tech_mamagement_system/Manage%20Events/eventsTabController.dart';
import 'package:ongolf_tech_mamagement_system/Manage%20Restaurant/Eat&Drink.dart';
import 'package:ongolf_tech_mamagement_system/Pro%20Shop/proShop.dart';
import 'package:ongolf_tech_mamagement_system/community/Community.dart';
import 'package:ongolf_tech_mamagement_system/manage%20players/manage%20players.dart';
import 'package:ongolf_tech_mamagement_system/widgets/responsive_widget.dart';

class MyHomePage1 extends StatefulWidget {
  const MyHomePage1({super.key});

  @override
  State<MyHomePage1> createState() => _MyHomePage1State();
}

class _MyHomePage1State extends State<MyHomePage1> {
  String clubName = 'null';
  String profileImageUrl = 'null';
  String clubDescription = 'null';
  String clubProfileImageUrl = 'null';
  int selectedIndex = 0;

  // Get current user
  final currentUser = FirebaseAuth.instance.currentUser;

  Future<void> getClubDetails() async {
    if (currentUser != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('clubs')
          .doc(currentUser!.uid)
          .get();
      if (userDoc.exists) {
        setState(() {
          clubName = userDoc['Club Name'] as String;
          profileImageUrl = userDoc['Profile Picture'] as String;
          clubDescription = userDoc['Club Discription'] as String;
          clubProfileImageUrl = userDoc['Profile Picture'] as String;
        });
      } else {
        // Document does not exist
        // Handle the situation accordingly
      }
    } else {
      // User is not logged in
      // Handle the situation accordingly
    }
  }

  @override
  void initState() {
    super.initState();
    // Initialize user
    getClubDetails();
  }

  Widget buildIcon(IconData icon, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedIndex = index;
        });
      },
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: selectedIndex == index
              ? Color.fromARGB(255, 42, 185, 47)
              : Colors.black.withOpacity(0.60),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 40,
        ),
      ),
    );
  }

  List<Widget> getWidgets() {
    return [
      Container(
        width: MediaQuery.of(context).size.width - 70,
        height: MediaQuery.of(context).size.height - 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadiusDirectional.only(
            topStart: Radius.circular(10),
          ),
          image: DecorationImage(
            image: AssetImage("assets/promote.png"),
            fit: BoxFit.scaleDown,
          ),
        ),
      ),
      const eventsTabConntroller(),
      pageTabConntroller(),
      PlayerManagement(),
      EatAndDrink(clubName: clubName),
      const ProShop(),
      Container(
        width: MediaQuery.of(context).size.width - 70,
        height: MediaQuery.of(context).size.height - 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadiusDirectional.only(
            topStart: Radius.circular(10),
          ),
        ),
        child: Community(),
      ),
      Container(
        child: ClubSignUp(),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: !ResponsiveWidget.isSmallScreen(context)
          ? buildBodyWidget()
          : const Center(
              child: Text(
                "Screen too small. \n Please use a Computer or laptop or a Tablet with a bigger screen.",
                textAlign: TextAlign.center,
              ),
            ),
    );
  }

  Row buildBodyWidget() {
    return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Column(
              children: [
                buildIcon(Icons.home, 0),
                buildIcon(Icons.event, 1),
                buildIcon(Icons.web, 2),
                buildIcon(Icons.sports_golf, 3),
                buildIcon(Icons.dining, 4),
                buildIcon(Icons.add_business, 5),
                buildIcon(Icons.people, 6),
                Container(
                  margin: EdgeInsets.only(top: 70),
                  width: 46,
                  height: 3,
                  color: Colors.white,
                ),
                buildIcon(Icons.notifications, 7),
              ],
            ),
            Container(
              width: MediaQuery.of(context).size.width - 70,
              height: MediaQuery.of(context).size.height,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40),
                color: Colors.black.withOpacity(0.8), // Optional background color
              ),
              child: IndexedStack(
                index: selectedIndex,
                children: getWidgets(),
              ),
            ),
          ],
        );
  }
}
