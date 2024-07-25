import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ongolf_tech_mamagement_system/Manage%20Events/dataTable.dart';
import 'package:ongolf_tech_mamagement_system/Manage%20Events/eventsPage.dart';
import 'package:ongolf_tech_mamagement_system/basic%20components/contentTable.dart';

class PlayerSignUpPage extends StatefulWidget {
  const PlayerSignUpPage({super.key});

  @override
  State<PlayerSignUpPage> createState() => _PlayerSignUpPageState();
}

class _PlayerSignUpPageState extends State<PlayerSignUpPage> {
 Events? tappedEvent;
  List<Events> clubEvents = [];
  List<UserDetails> usersDetails = []; 

  String clubName = 'Omeya Golf Club';
  final currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    getClubEvents();
    FirebaseFirestore.instance
        .collection('clubs')
        .doc(currentUser!.uid)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        final clubName1 = snapshot.data()!['Club Name'] as String;
        setState(() {
          clubName = clubName1;
        });
      } else {
        // ignore: avoid_print
        print('Document does not exist');
      }
    });
  }

    Future<void> getClubEvents() async {
    final snapshot = await FirebaseFirestore.instance.collection('Events').get();
    final events = snapshot.docs
        .map((doc) => Events(
              doc['Event Name'],
              doc['Club Host'],
              doc['Formate'],
              doc['Entry Fee'],
              doc['Sign up due'],
              doc['More info'],
              doc['Event poster']
            ))
        .toList();
    clubEvents = events.where((event) => event.host == clubName.split(" ").first).toList();
  }

Future<List<UserDetails>> getAllUsers() async {
  final List<UserDetails> usersDetails = [];
  
  // Fetch all documents from the 'users' collection
  final querySnapshot = await FirebaseFirestore.instance.collection('users').get();
  
  // Iterate through the documents
  for (var doc in querySnapshot.docs) {
    final userData = doc.data();
    final String fullName = userData['Full Name'] ?? '';
    final String homeClub = userData['Home club'] ?? '';
    final String profilePictureUrl = userData['Profile Picture'] ?? '';
    final String handicap = userData['Handicap']?.toString() ?? 'N/A';
    final String userId = doc.id; // Use the document ID as userId

    final userDetails = UserDetails(
      fullName,
      homeClub,
      profilePictureUrl,
      handicap,
      userId,
    );

    usersDetails.add(userDetails);
  }
  
  return usersDetails;
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SizedBox(
            height: MediaQuery.of(context).size.height + 200,
            child: Column(
            children: [
              BuildTableContainer(check: false, title:  'Manage Events', container:  eventsContainer()),
              if (tappedEvent == null) Expanded(child: Center(
                child: Text('Select event above.',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900
                ),
                ),
              )) ,
              if (tappedEvent != null) 
              Expanded(
                child: Row(
                  children: [
                    Container(
                       width:  MediaQuery.of(context).size.width - MediaQuery.of(context).size.width/3 - 80,
                       child: 
                     SampleTablePage(currentTappedTitle: tappedEvent!.eventName)),
                    Container(
                       width: MediaQuery.of(context).size.width/3,
                      decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.grey[200],
                              ),
                      child: Expanded(
                        child: Column(
                          children: [
                            Container(
                            margin: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: Colors.grey.shade900),
                            ),
                            child: Center(
                              child: TextField(
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Search...',
                                  prefixIcon: Icon(Icons.person_search),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                ),
                              ),
                            ),
                          ),
                          Expanded(child: rsvpContainer()),
                          ],
                        ),
                      ),
                    ),
                  //create a method that build sample table with attributes name, time, handicap, Group, color, payment using a PaginatedDataTable it doesnt need to have records
                  
                  ],
                )) ,
            ],
          ),
          ),
      ),
    );
  }

     Container eventsContainer() {
   return Container(
    height: 200,
    child: FutureBuilder<void>(
      future: getClubEvents(),
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          return Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.grey[200],
            ),
            child: ListView.builder(
              scrollDirection: Axis.vertical,
              itemCount: clubEvents.length,
              itemBuilder: (BuildContext context, int index) {
                final event = clubEvents[index];
                return ListTile(
                  selectedColor: Colors.green.shade100,
                  leading: CircleAvatar(
                        backgroundImage: NetworkImage(event.posterURL),
                      ),
                  title: Text(event.eventName),
                  subtitle: Text(event.format),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    // ignore: prefer_const_literals_to_create_immutables
                    children: [
                      //count the number of rsvp's and replace it with #
                      Text('#'),
                      const SizedBox(width: 4,),
                      Icon(Icons.web)
                    ],
                  ),
                  onTap: () {
                    setState(() {
                      tappedEvent = event;
                    });
                  },
                );
              },
            ),
          );
        }
      },
    ),
  );
 }



   SingleChildScrollView rsvpContainer() {
   return SingleChildScrollView(
    scrollDirection: Axis.vertical,
     child: Expanded(
       child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.grey[200],
        ),
        child: FutureBuilder<void>(
          future: getAllUsers(),
          builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              usersDetails = snapshot.data as List<UserDetails>;
              return SingleChildScrollView(
              scrollDirection: Axis.vertical,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: usersDetails.length,
                  itemBuilder: (BuildContext context, int index) {
                    final user = usersDetails[index];
                    return Column(
                      children: [
                        ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(user.profilePictureUrl),
                          ),
                          title: Text(user.fullName),
                          subtitle: Text(user.homeClub),
                          trailing: SizedBox(
                            width: 60.0, 
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [Text(user.handicap),
                              const Spacer(),
                              //toggle checklist to add user to tapped event
                              Icon(Icons.check_box_outline_blank)
                              ],
                            ),
                          ),
                        ),
                        Divider()
                      ],
                    );
                  },
                ),
              );
            }
          },
        ),
      ),
     ),
   );
 }

   AlertDialog deleteReservationDialog(BuildContext context, UserDetails user) {
     return AlertDialog(
      title: const Text("Confirm Delete"),
      content: const Text("Are you sure you want to delete this reservation?"),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () {
            // Delete the reservation
            FirebaseFirestore.instance.collection('Reservations')
              .where('User ID', isEqualTo: user.userId)
              .where('Event Title', isEqualTo: tappedEvent!.eventName)
              .where('Host', isEqualTo: clubName.split(" ").first)
              .get()
              .then((snapshot) {
                for (final doc in snapshot.docs) {
                  doc.reference.delete();
                }
              });
            Navigator.of(context).pop(); // Close the dialog
          },
          child: const Text("Delete"),
        ),
      ],
    );
   }
}