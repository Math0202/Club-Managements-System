import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ongolf_tech_mamagement_system/Manage%20Club%20Page/clubs_page.dart';
import 'package:ongolf_tech_mamagement_system/Manage%20Events/eventsPage.dart';
import 'package:ongolf_tech_mamagement_system/Pro%20Shop/proShop.dart';
import 'package:ongolf_tech_mamagement_system/homePage.dart';

class PlayerManagement extends StatefulWidget {
  const PlayerManagement({super.key});


  @override
  State<PlayerManagement> createState() => _PlayerManagementState();
}

class _PlayerManagementState extends State<PlayerManagement> {
  late String? currentClubName = ""; // Make currentClubName nullable
  String clubProfileImageUrl = 'null';
  String clubName = 'null';

  @override
  void initState() {
    super.initState();
    fetchCurrentClubName();
  }

 Future<void> fetchCurrentClubName() async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    DocumentSnapshot clubSnapshot = await FirebaseFirestore.instance
        .collection('clubs')
        .doc(user.uid)
        .get();

    if (clubSnapshot.exists) {
      setState(() {
        currentClubName = clubSnapshot['Club Name'];
      });
    }
  }
}


  @override
  Widget build(BuildContext context) {
    if (currentClubName == null) {
      // Handle the case where currentClubName is not yet initialized
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }


    return Scaffold(
      backgroundColor: Colors.green.shade100,
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance.collection('users').where('Home club', isEqualTo: currentClubName).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No players found for current club.'),
            );
          }
          
          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 340, // Maximum width for each item
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              mainAxisExtent: 150,
            ),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final player = snapshot.data!.docs[index];
              final playerName = player['Full Name'];
              final clubName = player['Home club'];
              final handicap = player['Handicap'];
              final gender = player['Gender'];
              final userName = player['User Name'];
              final profilePictureUrl = player['Profile Picture'];

              return GestureDetector(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/playerProfile',
                    arguments: {
                      'userName': userName,
                      'handicap': handicap,
                      'profileImageUrl': profilePictureUrl,
                      'homeClub': clubName,
                      'playerFullName': playerName,
                    },
                  );
                },
                child: Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  margin: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const SizedBox(width: 4),
                          CircleAvatar(
                            radius: 40,
                            backgroundImage: NetworkImage(profilePictureUrl),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  playerName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Home Club: $clubName',
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                                Text('Handicap: $handicap'),
                                Text('Gender: $gender'),
                                Text('Username: $userName'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
