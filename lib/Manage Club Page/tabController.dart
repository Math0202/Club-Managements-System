import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ongolf_tech_mamagement_system/Manage%20Club%20Page/clubs_page.dart';

class pageTabConntroller extends StatefulWidget {
  const pageTabConntroller({super.key});

  @override
  State<pageTabConntroller> createState() => _pageTabConntrollerState();
}

class _pageTabConntrollerState extends State<pageTabConntroller> {

  String clubName = 'null';
  String profileImageUrl = 'null';
  String clubDescription = 'null';

  // Get current user
  final currentUser = FirebaseAuth.instance.currentUser;

 void initState(){
  super.initState();
  getClubDetails();
}
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
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 1,
      child: Column(
        children: [
          // Create the tabs
           TabBar(
            unselectedLabelColor: Colors.white,
            labelColor: Color.fromARGB(255, 42, 185, 47),
            tabs: [
              Tab(
                icon: Icon(Icons.settings),
                text: 'Update Club Page',
              ),
            ],
          ),
          // Access the different tab content
          Expanded(
            child: TabBarView(
              children: [
                ClubsPage(
                  assetPath: profileImageUrl, 
                  clubName: clubName, 
                  description: clubDescription
                  )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
