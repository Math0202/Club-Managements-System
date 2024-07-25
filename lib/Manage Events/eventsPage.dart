// ignore_for_file: prefer_const_constructors

import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:ongolf_tech_mamagement_system/Manage%20Events/calendar/MyCalendar.dart';
import 'package:table_calendar/table_calendar.dart';

import '../basic components/contentTable.dart';


class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();

}



class _EventsPageState extends State<EventsPage> {
  final DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  final ValueNotifier<DateTime> _selectedDateNotifier = ValueNotifier<DateTime>(DateTime.now());
  String clubName1 = '';
  late List<Events> clubEvents;
  Events? tappedEvent;
  List<UserDetails> usersDetails = []; 
   PlatformFile? pickedFile;
  bool isChecked = false;
  bool isUploading = false;
  Uint8List ? selectedImageInBytes;
  String imageUrl = '';
  String clubProfileImageUrl = 'null';
  String clubName = 'null';

  
  TextEditingController formatController = TextEditingController();
  TextEditingController entryFeeController = TextEditingController();
  TextEditingController dueDateForRegController = TextEditingController();
  TextEditingController moreDetailController = TextEditingController();



    Future<void> getClubEvents() async {
    clubEvents = []; // Clear previous events
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
    clubEvents = events.where((event) => event.host == clubName1.split(" ").first).toList();
  }

Future<List<UserDetails>> getRSVPs(String currentTappedTitle, String clubName) async {
  final List<UserDetails> usersDetails = [];
  final snapshot = await FirebaseFirestore.instance.collection('Reservations')
      .where('Event Title', isEqualTo: currentTappedTitle)
      .where('Host', isEqualTo: clubName.split(" ").first)
      .get();

  for (final doc in snapshot.docs) {
    final String userId = doc['User ID'];
    final userSnapshot = await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (userSnapshot.exists) {
      final userData = userSnapshot.data() as Map<String, dynamic>;
      final String fullName = userData['Full Name'] ?? '';
      final String homeClub = userData['Home club'] ?? '';
      final String profilePictureUrl = userData['Profile Picture'] ?? '';
      final String handicap = userData['Handicap'].toString();

      final userDetails = UserDetails( fullName, homeClub, profilePictureUrl, handicap, userId,);

      usersDetails.add(userDetails);
    }
  }

  return usersDetails;
}


  final currentUser = FirebaseAuth.instance.currentUser;
  // Fetch club name from Firestore using the current user's ID
  // Replace 'clubs' with your Firestore collection name
 Future<void> getClubName() async {
  FirebaseFirestore.instance.collection('clubs').doc(currentUser!.uid).snapshots().listen((snapshot) {
    if (snapshot.exists) {
      final clubName = snapshot.data()!['Club Name'] as String;
      setState(() {
        clubName1 = clubName;
      });
    } else {
      // ignore: avoid_print
      print('Document does not exist');
    }
  });
}

//select image
    Future<void> selectedImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result == null) return;

    setState(() {
      pickedFile = result.files.first;
      selectedImageInBytes = result.files.first.bytes;
      isUploading = true;
    });
  }




@override
void initState() {
  super.initState();
  // Initialize user
  getClubName();
  getClubEvents();
  tappedEvent;
  isUploading = true;
}




 @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.green.shade100,
    body: Row(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: SizedBox(
              height: 1100,
              child: Column(
                children: [
                  const SizedBox(height: 8,),
                  BuildTableContainer(check: false,title: 'Event schedular', container: buildCalenderWidget()),
                  const SizedBox(height: 8,),
                  BuildTableContainer(check: false,title: "Scheduled events for $clubName1.", container: eventsContainer()),             
                ],
              ),
            ),
          ),
        ),

        // Display event details or 'Select event' message based on tappedEvent
        Expanded(
          child: SingleChildScrollView(
            child: Container(
              margin: const EdgeInsets.all(8),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  tappedEvent != null ?
                  Column(
                    children: [
                     // Assuming `date` is a property of the `Events` class
                      BuildTableContainer(check: false ,title: '${tappedEvent!.eventName} ', container: Container(
                        height: 465,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          image: DecorationImage(
                            image: NetworkImage(tappedEvent!.posterURL),
                            fit: BoxFit.fitHeight,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            rSVToggleBox(),
                           deleteEventButton(context),
                          ],
                        ),
                       )),
                      const SizedBox(height: 10),
                      BuildTableContainer(check: false, title: 'Update Event', container: updateEventContainer()),
                      //ListviewBuilder for the users that rsvped include the all the fetched user info, the profile picture, home club, full names
                      Container(
                         margin: const EdgeInsets.all(8),
                         decoration: BoxDecoration(
                           borderRadius: BorderRadius.circular(10),
                           color: Colors.grey[200],
                         ),
                         child: FutureBuilder<void>(
                           future: getRSVPs(tappedEvent!.eventName, clubName1),
                           builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
                             if (snapshot.connectionState == ConnectionState.waiting) {
                               return const Center(child: CircularProgressIndicator());
                             } else if (snapshot.hasError) {
                               return Center(child: Text('Error: ${snapshot.error}'));
                             } else {
                               usersDetails = snapshot.data as List<UserDetails>;
                               return ListView.builder(
                                 shrinkWrap: true,
                                 itemCount: usersDetails.length,
                                 itemBuilder: (BuildContext context, int index) {
                                   final user = usersDetails[index];
                                   return ListTile(
                                     leading: CircleAvatar(
                                       backgroundImage: NetworkImage(user.profilePictureUrl),
                                     ),
                                     title: Text(user.fullName),
                                     subtitle: Text(user.homeClub),
                                     trailing: SizedBox(
                                        width: 60, 
                                       child: Row(
                                         mainAxisSize: MainAxisSize.min,
                                         children: [Text(user.handicap),
                                         const Spacer(),
                                           IconButton(
                                               icon: const Icon(Icons.delete),
                                               onPressed: () {
                                                 showDialog(
                                                   context: context,
                                                   builder: (BuildContext context) {
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
                                                               .where('Host', isEqualTo: clubName1.split(" ").first)
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
                                                   },
                                                 );
                                               },
                                           ),
                                              
                                           
                                         ],
                                       ),
                                     ),
                                   );
                                 },
                               );
                             }
                           },
                         ),
                       )
                    ],
                  ) :
                  const Text(
                    'Select event',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

 Container rSVToggleBox() {
   return Container(
    margin: EdgeInsets.all(8),
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.black.withOpacity(0.5),
                      ),
                      child: Checkbox(
                        checkColor: Colors.white,
                           value: isChecked,
                           onChanged: (value) {
                             setState(() {
                               isChecked = value!;
                             });
                           },
                         ),
                    );
 }

 Container deleteEventButton(BuildContext context) {
   return Container(
    margin: EdgeInsets.all(8),
                         height: 40,
                         width: 40,
                         decoration: BoxDecoration(
                           borderRadius: BorderRadius.circular(10),
                           color: Colors.black.withOpacity(0.5),
                         ),
                         child: GestureDetector(
                           onTap: () {
                             showDialog(
                               context: context,
                               builder: (BuildContext context) {
                                 return AlertDialog(
                                   title: const Text('Confirm Delete'),
                                   content: const Text('Are you sure you want to delete this event?'),
                                   actions: <Widget>[
                                     TextButton(
                                       onPressed: () {
                                         Navigator.of(context).pop(); // Close the dialog
                                       },
                                       child: const Text('Cancel'),
                                     ),
                                     TextButton(
                                       onPressed: () {
                                         // Delete event from the "Events" collection
                                         FirebaseFirestore.instance.collection('Events')
                                           .where('Event Name', isEqualTo: tappedEvent!.eventName)
                                           .get()
                                           .then((snapshot) {
                                             for (final doc in snapshot.docs) {
                                               doc.reference.delete();
                                             }
                                           });
                                         // Delete reservations for the event
                                         FirebaseFirestore.instance.collection('Reservations')
                                           .where('Event Title', isEqualTo: tappedEvent!.eventName)
                                           .where('Host', isEqualTo: clubName1.split(" ").first)
                                           .get()
                                           .then((snapshot) {
                                             for (final doc in snapshot.docs) {
                                               doc.reference.delete();
                                             }
                                           });
                        
                                         Navigator.of(context).pop(); // Close the dialog
                                       },
                                       child: const Text('Delete'),
                                     ),
                                   ],
                                 );
                               },
                             );
                           },
                           child: const Icon(Icons.delete, color: Colors.white),
                         ),
                    );
 }

Container updateEventContainer() {
  return Container(
    width: MediaQuery.of(context).size.width /2.2,
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
      borderRadius:BorderRadius.circular(20),
      color: Colors.white,
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        
        SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              // Add other text form fields for other event details
              ListTile(
                title: Text('Format'),
                subtitle: TextFormField(
                  controller: formatController,
                  decoration: InputDecoration(
                    hintText: tappedEvent != null ? tappedEvent!.format : 'Enter event format',
                  ),
                ),
              ),
              ListTile(
                title: Text('Entry Fee'),
                subtitle: TextFormField(
                  controller: entryFeeController,
                  decoration: InputDecoration(
                    hintText: tappedEvent != null ? tappedEvent!.entryFee : 'Enter event entry fee',
                  ),
                ),
              ),
              ListTile(
                title: Text('Sign Up Due'),
                subtitle: TextFormField(
                  controller: dueDateForRegController,
                  decoration: InputDecoration(
                    hintText: tappedEvent != null ? tappedEvent!.signUpDue : 'Enter sign up due date',
                  ),
                ),
              ),
              ListTile(
                title: Text('More Detail & Info'),
                subtitle: TextFormField(
                  controller: moreDetailController,
                  decoration: InputDecoration(
                    hintText: tappedEvent != null ? tappedEvent!.moreInfo : 'Enter more details',
                  ),
                ),
              ),
              // Image preview
              ListTile(
                title: Text('Event Poster'),
                subtitle: pickedFile != null
                    ? Image.memory(
                        selectedImageInBytes!,
                        height: 100,
                        width: 100,
                        fit: BoxFit.cover,
                      )
                    : (tappedEvent != null && tappedEvent!.posterURL.isNotEmpty
                        ? Image.network(
                            tappedEvent!.posterURL,
                            height: 100,
                            width: 100,
                            fit: BoxFit.cover,
                          )
                        : const Text('No poster image')),
              ),
              ElevatedButton(
                onPressed: selectedImage,
                child: const Text('Select poster Image'),
              ),
            ],
          ),
        ),
        SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () async {
                String? imageUrl;

                if (pickedFile != null) {
                  Reference ref = FirebaseStorage.instance.ref().child('event_posters/${pickedFile!.name}');
                  await ref.putData(selectedImageInBytes!);
                  imageUrl = await ref.getDownloadURL();
                }

                // Fetch the document first
                FirebaseFirestore.instance.collection('Events')
                  .where('Event Name', isEqualTo: tappedEvent!.eventName)
                  .where('Club Host', isEqualTo: tappedEvent!.host)
                  .get()
                  .then((snapshot) {
                    for (DocumentSnapshot doc in snapshot.docs) {
                      // Update event in Firestore
                      doc.reference.update({
                        'Formate': formatController.text.isNotEmpty ? formatController.text : tappedEvent!.format,
                        'Entry Fee': entryFeeController.text.isNotEmpty ? entryFeeController.text : tappedEvent!.entryFee,
                        'Sign up due': dueDateForRegController.text.isNotEmpty ? dueDateForRegController.text : tappedEvent!.signUpDue,
                        'More info': moreDetailController.text.isNotEmpty ? moreDetailController.text : tappedEvent!.moreInfo,
                        'Event poster': pickedFile != null ? imageUrl : tappedEvent!.posterURL, // Keep the existing poster if no new poster is selected
                      }).then((_) {
                        // Print success message and close the dialog
                        print('Event updated successfully');
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Update Successful'),
                              content: const Text('The event was updated successfully.'),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(); // Close the dialog
                                    Navigator.of(context).pop(); // Close the update dialog
                                  },
                                  child: const Text('OK'),
                                ),
                              ],
                            );
                          },
                        );
                      }).catchError((error) {
                        // Print error message
                        print('Failed to update event: $error');
                        // Optionally, display an error message to the user
                      });
                    }
                  });
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ],
    ),
  );
}


 Container buildCalenderWidget() {
   return Container(
                  margin: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.grey[200],
                  ),
                  child: ValueListenableBuilder<DateTime>(
                    valueListenable: _selectedDateNotifier,
                    builder: (context, selectedDate, _) {
                      return MyCalendar(
                        selectedDay: selectedDate,
                        focusedDay: _focusedDay,
                        calendarFormat: _calendarFormat,
                        onDaySelected: (selectedDay) {
                          _handleDaySelected(selectedDay);
                        },
                        onFormatChanged: (format) {
                          _handleFormatChanged(format);
                        }, eventDays: const [],
                      );
                    },
                  ),
                );
 }

Container eventsContainer() {
  return Container(
    height: 340,
    child: FutureBuilder<void>(
      future: getClubEvents(),
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          return SingleChildScrollView(
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey[200],
              ),
              child: ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true, 
                physics: NeverScrollableScrollPhysics(),
                itemCount: clubEvents.length,
                itemBuilder: (BuildContext context, int index) {
                  final event = clubEvents[index];
                  return Column(
                    children: [
                      ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(event.posterURL),
                        ),
                        title: Text(event.eventName),
                        subtitle: Text(event.format),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            // Count the number of rsvp's and replace it with #
                            Text('#'),
                             SizedBox(width: 4),
                            Icon(Icons.web),
                          ],
                        ),
                        onTap: () {
                          setState(() {
                            tappedEvent = event;
                          });
                        },
                      ),
                      Divider()
                    ],
                  );
                },
              ),
            ),
          );
        }
      },
    ),
  );
}

  void _handleDaySelected(DateTime selectedDay) {
    _selectedDateNotifier.value = selectedDay;
  }

    void _handleFormatChanged(CalendarFormat format) {
    setState(() {
      _calendarFormat = format;
    });
  }

  //Call build Table Container
  
}




  
class Events {
  final String eventName;
  final String host;
  final String format;
  final String entryFee;
  final String signUpDue;
  final String moreInfo;
  final String posterURL;

  Events(
    this.eventName, 
    this.host, 
    this.format, 
    this.entryFee, 
    this.signUpDue, 
    this.moreInfo, 
    this.posterURL);

    
}



class UserDetails {
   final String userId;
  final String fullName;
  final String homeClub;
  final String profilePictureUrl;
  final String handicap;

  UserDetails(
    this.fullName, 
    this.homeClub, 
    this.profilePictureUrl, 
    this.handicap, this.userId
    );
}