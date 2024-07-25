// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:ongolf_tech_mamagement_system/Manage%20Club%20Page/clubs_leader_boards.dart';
import 'package:ongolf_tech_mamagement_system/Manage%20Club%20Page/imagesWidgets.dart';
import 'package:ongolf_tech_mamagement_system/Manage%20Events/calendar/MyCalendar.dart';
import 'package:ongolf_tech_mamagement_system/Manage%20Restaurant/Eat&Drink.dart';
import 'package:ongolf_tech_mamagement_system/basic%20components/my_textfied.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter/material.dart';

class ClubsPage extends StatefulWidget {
  final String assetPath;
  final String clubName;
  final String description;
  
  const ClubsPage({
    super.key,
    required this.assetPath,
    required this.clubName,
    required this.description,
  });


  @override
  State<ClubsPage> createState() => _ClubsPageState();
}

class _ClubsPageState extends State<ClubsPage> {
  late CalendarFormat _calendarFormat;
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  final TextEditingController urlController = TextEditingController();
  final TextEditingController docNoteController = TextEditingController();
  final TextEditingController imageNoteController = TextEditingController();
  String physicalAddress = 'click to update';
  String contactName = 'click to update';
  String contactTitle = 'click to update';
  String clubNumber = 'click to update';
  String clubEmail = 'click to update';
  Uint8List ? selectedImageInBytes;
  FilePickerResult? pickedFile;
String? selectedImageName;

  

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    _calendarFormat = CalendarFormat.month;
    _fetchAddress();
    _fetchContactInfo();
  }
  //uploading an image
  Future<void> selectImage() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
  if (result != null) {
    PlatformFile file = result.files.first;
    Uint8List? fileBytes = file.bytes;

    if (fileBytes != null) {
      setState(() {
        selectedImageInBytes = fileBytes;
        selectedImageName = file.name;
      });
    }
  }
}
Future<void> uploadImage() async {
  if (selectedImageInBytes != null && selectedImageName != null) {
    // Upload to Firebase Storage
    TaskSnapshot snapshot = await FirebaseStorage.instance
        .ref('images/$selectedImageName')
        .putData(selectedImageInBytes!);
    String downloadURL = await snapshot.ref.getDownloadURL();

    // Save to Firestore
    FirebaseFirestore.instance.collection('Notice Board Images').add({
      'imageUrl': downloadURL,
      'note': imageNoteController.text,
      'uploadedAt': Timestamp.now(),
      'clubName': widget.clubName,
    });

    // Clear the note controller and reset the image preview
    setState(() {
      selectedImageInBytes = null;
      selectedImageName = null;
      imageNoteController.clear();
    });
  }
}

Widget buildImagePreview() {
  if (selectedImageInBytes != null && selectedImageName != null) {
    return Column(
      children: [
        Text(
          'Image: $selectedImageName',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 20,),
        Image.memory(
          selectedImageInBytes!,
          height: 200,
          fit: BoxFit.cover,
        ),
        SizedBox(height: 20,),
        MyTextFied(
          controller: imageNoteController,
          hintText: 'Add a note to image',
          obscureText: false,
        ),
        SizedBox(height: 25,),
        ElevatedButton(
          onPressed: uploadImage,
          child: Text('Upload Image'),
        ),
      ],
    );
  } else {
    return SizedBox.shrink();
  }
}



  //selecting documents
  void selectDocument() async {
  pickedFile = (await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['pdf', 'doc', 'docx'],
  ));
  setState(() {});
}

 Future<void> uploadDocument() async {
  if (pickedFile != null && pickedFile!.files.isNotEmpty) {
    PlatformFile file = pickedFile!.files.first;
    String fileName = file.name;
    String filePath = 'documents/$fileName';

    try {
      await FirebaseStorage.instance.ref(filePath).putData(file.bytes!);
      String downloadURL = await FirebaseStorage.instance.ref(filePath).getDownloadURL();

      await FirebaseFirestore.instance.collection('documents').add({
        'fileName': fileName,
        'fileURL': downloadURL,
        'note': docNoteController.text,
        'uploadedAt': Timestamp.now(),
        'Club Name' : clubName
      });

      // Reset picked file and note controller
      pickedFile = null;
      docNoteController.clear();

      // Update UI
      setState(() {});
    } catch (e) {
      print('Upload error: $e');
    }
  }
}


Widget buildDocumentPreview() {
  if (pickedFile != null && pickedFile!.files.isNotEmpty) {
    return Column(
      children: [
        Text('Document: ${pickedFile!.files.single.name}',style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),),
        SizedBox(height: 20,),
              MyTextFied(
                controller: docNoteController,
                hintText: 'Add a note to document',
                obscureText: false,
              ),
              SizedBox(height: 25,),
              ElevatedButton(
          onPressed: uploadDocument,
          child: Text('Upload Document'),
        ),
      ],
    );
  } else {
    return SizedBox.shrink();
  }
}

Widget buildUploadedDocumentsList() {
  return StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance
        .collection('documents')
        .where('Club Name', isEqualTo: clubName)
        .snapshots(),
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return CircularProgressIndicator();
      }

      List<DocumentSnapshot> documents = snapshot.data!.docs;
      return Column(
        children: documents.map((doc) {
          String fileName = doc['fileName'];
          String fileURL = doc['fileURL'];
          String note = doc['note'];
          DateTime uploadedAt = doc['uploadedAt'].toDate();

          return Column(
            children: [
              GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Confirm Delete'),
                    content: Text('Are you sure you want to delete $fileName?'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Close the dialog
                        },
                        child: Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          // Delete the document
                          doc.reference.delete();
                          Navigator.of(context).pop(); // Close the dialog
                        },
                        child: Text('Delete'),
                      ),
                    ],
                  ),
                );
              },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Document: $fileName', style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold, color: Colors.grey[800]),),
                    Icon(Icons.download)
                  ],
                ),
              ),
              Text('Uploaded Date: $uploadedAt'),
              if (note.isNotEmpty)
              Text('Note: $note'),
              Divider(),
            ],
          );
        }).toList(),
      );
    },
  );
}

  // Club physical address fetching
  Future<void> _fetchAddress() async {
    var doc = await FirebaseFirestore.instance
        .collection('Club Info')
        .where('Type', isEqualTo: 'Location')
        .where('Club Name', isEqualTo: clubName)
        .limit(1)
        .get();

    if (doc.docs.isNotEmpty) {
      setState(() {
        physicalAddress = doc.docs.first['Text'];
      });
    }
  }

    Future<void> _fetchContactInfo() async {
    var doc = await FirebaseFirestore.instance
        .collection('Club Info')
        .where('Type', isEqualTo: 'Contact')
        .where('Club Name', isEqualTo: clubName)
        .limit(1)
        .get();

    if (doc.docs.isNotEmpty) {
      setState(() {
        contactName = doc.docs.first['Name'];
        contactTitle = doc.docs.first['Title'];
        clubNumber = doc.docs.first['Number'];
        clubEmail = doc.docs.first['Email'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Implement the layout for club details page/screen here
    return Scaffold(
      backgroundColor: Colors.green.shade100,
      body: SingleChildScrollView(
        child: Row(
          children: [
            Column(
              children: [
                Container(
                  margin: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border:Border.all(),
                  ),
                  width: 390,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                       Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(widget.assetPath),
                            fit: BoxFit.cover,
                          ),
                        ),
                        height: 200,
                      ),
                     Container(
                      padding: const EdgeInsets.only(right:8),
                      alignment: Alignment.centerRight,
                        child:
                          InkWell(
                           // onTap: addImages,
                            child: const Text(
                              'Course Gallery',
                              style: TextStyle(fontSize: 18, color: Colors.blue, fontWeight: FontWeight.w300)
                            ),
                          ),
                        
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(left:5),
                        child: Text('Course Discription:\n${widget.description}',
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                      const SizedBox(height: 30,),
                      Text(
                            'Offered facilities',
                            style: TextStyle(fontSize: 20, color: Colors.grey[900], fontWeight: FontWeight.w900)
                          ),
                           const Divider(
                          ),
                         //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>.
                           buildButtons(),
                           ElevatedButton(onPressed:addAffinity, child: Text("Add")),
                          //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                        const SizedBox(height: 42,),
                     
                            SingleChildScrollView(
                      child: Column(
                        children: [
                          
                          Divider(
                            color: Colors.green,
                          ),
                          // Display uploaded images
                          buildImagesForClubPage(widget: widget),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                                onPressed: selectImage,
                                child: Text("Add Image"),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                       SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      Text("Documents", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                                      Divider(
                                      indent: 0,
                                      thickness: 10,
                                      color: Colors.green.shade500,
                                      ),
                                    buildUploadedDocumentsList(),
                                      Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                  
                                  ElevatedButton(
                                    onPressed: selectDocument,
                                    child: Text("Add Document"),
                                  ),
                                  
                                ],
                              ),
                          ]
                        ),
                       ),
                      SizedBox(height: 40,),
                      SizedBox(
                        height: 760,
                        width: 400,
                        child: buildClubChampionTable(clubName: clubName,)),
                      SizedBox(height: 40,),
                      buildFooter(),
                    ],
                  ),
                ),
              ],
            ),
            Column(
              children: [
                buildDocumentPreview(),
                buildImagePreview(),
              ],
            )
          ],
        ),
      ),
    );
  }

  //Build buttons==-=----------------------------
   final List<Map<String, dynamic>> dropdownItems = [
    {"icon": Icons.golf_course, "text": "Golf Booking"},
    {"icon": Icons.restaurant, "text": "Food & Drinks"},
    {"icon": Icons.sports_golf, "text": "Driving Range"},
    {"icon": Icons.menu_book, "text": "Coaches"},
    {"icon": Icons.swap_calls, "text": "Item Rental"},
  ];

  String? selectedItem;
  TextEditingController titleController = TextEditingController();
  TextEditingController bodyController = TextEditingController();

  void addAffinity() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Affinity'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<String>(
                hint: Text("Select Item"),
                value: selectedItem,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedItem = newValue;
                  });
                },
                items: dropdownItems.map((item) {
                  return DropdownMenuItem<String>(
                    value: item['text'],
                    child: Row(
                      children: [
                        Icon(item['icon']),
                        SizedBox(width: 10),
                        Text(item['text']),
                      ],
                    ),
                  );
                }).toList(),
              ),
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: 'Title'),
              ),
              TextField(
                maxLines: 21,
                controller: bodyController,
                decoration: InputDecoration(labelText: 'Body'),
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
              onPressed: () {
                if (selectedItem != null &&
                    titleController.text.isNotEmpty &&
                    bodyController.text.isNotEmpty) {
                  FirebaseFirestore.instance.collection('Affinities').add({
                    'Club Name': widget.clubName, // Assuming club name is in assetPath
                    'Title': titleController.text,
                    'Body': bodyController.text,
                    'Type': selectedItem,
                  }).then((_) {
                    Navigator.pop(context);
                  });
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }
  IconData? getIcon(String type) {
    final item = dropdownItems.firstWhere((element) => element['text'] == type);
    return item['icon'];
  }

  Widget buildButtons() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('Affinities').where('Club Name', isEqualTo: widget.clubName).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }
        final documents = snapshot.data!.docs;
        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: documents.length,
          itemBuilder: (context, index) {
            final data = documents[index].data() as Map<String, dynamic>;
            final icon = getIcon(data['Type']);
            return Container(
              margin: EdgeInsets.symmetric(horizontal: 8),
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: Colors.black,
                    width: 1,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        shadowColor: Colors.green.shade500,
                        title: Text(data['Title']),
                        backgroundColor: Colors.green.shade300,
                        content: Container(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                Text(
                                  data['Body'],
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w200,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('Close'),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: Row(
                  children: [
                    if (icon != null) Icon(icon, color: Colors.black),
                    SizedBox(width: 8),
                    Text(
                      data['Type'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }


//end ====================================================


//Build footer ---------------------------------------------------------------------
  Container buildFooter() {
    return Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: Colors.green,
                      width: 3,),
                      borderRadius: BorderRadius.all(Radius.circular(10))
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                GestureDetector(
            onTap: () {
              _showContactDialog();
            },
                  child: Column(
                    children: [
                      Text('Contact',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      Text(contactName),
                      Text(contactTitle),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Text('details',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                    Text('+264 (0) $clubNumber'),
                    Text(clubEmail),
                  ],
                )
              ],
                      ),
                          Spacer(),
          GestureDetector(
            onTap: () async {
              // Fetch existing text from Firebase
              var doc = await FirebaseFirestore.instance
                  .collection('Club Info')
                  .where('Type', isEqualTo: 'Location')
                  .where('Club Name', isEqualTo: clubName)
                  .limit(1)
                  .get();

              if (doc.docs.isNotEmpty) {
                physicalAddress = doc.docs.first['Text'];
              }

              urlController.text = ''; // Clear the previous input

              showDialog(
                // ignore: use_build_context_synchronously
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text('Club physical address'),
                    content: TextField(
                      controller: urlController,
                      decoration: InputDecoration(hintText: physicalAddress),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('Close'),
                      ),
                      TextButton(
                        onPressed: () async {
                          String newText = urlController.text;
                          if (newText.isNotEmpty) {
                            if (doc.docs.isEmpty) {
                              await FirebaseFirestore.instance.collection('Club Info').add({
                                'Text': newText,
                                'Type': 'Location',
                                'Club Name': clubName,
                              });
                            } else {
                              await FirebaseFirestore.instance
                                  .collection('Club Info')
                                  .doc(doc.docs.first.id)
                                  .update({
                                'Text': newText,
                                'Type': 'Location',
                                'Club Name': clubName,
                              });
                            }
                            urlController.clear();
                          }
                          Navigator.of(context).pop();
                        },
                        child: Text('OK'),
                      ),
                    ],
                  );
                },
              );
            },
            child: Column(
              children: [
                Text(
                  physicalAddress,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black),
                ),
              ],
            ),
          ),
          Spacer(),
                       Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              buildIcon(context, 'assets/email.jpg', 'Email', 'Enter Email address'),
              buildIcon(context, 'assets/Facebook.jpg', 'Facebook', 'Enter Facebook URL'),
              buildIcon(context, 'assets/Instagram.jpg', 'Instagram', 'Enter Instagram URL'),
              buildIcon(context, 'assets/LinkedIn.jpg', 'LinkedIn', 'Enter LinkedIn URL'),
              buildIcon(context, 'assets/WhatsApp.jpg', 'WhatsApp', 'Enter WhatsApp Number'),
              buildIcon(context, 'assets/website.jpg', 'Website', 'Enter Website URL'),
            ],
          ),
          SizedBox(height: 30),
                    ],
                  ),
                );
  }

  //update contact info
    Future<void> _showContactDialog() async {
      var doc = await FirebaseFirestore.instance
        .collection('Club Info')
        .where('Type', isEqualTo: 'Contact')
        .where('Club Name', isEqualTo: clubName)
        .limit(1)
        .get();

    if (doc.docs.isNotEmpty) {
      setState(() {
        contactName = doc.docs.first['Name'];
        contactTitle = doc.docs.first['Title'];
        clubNumber = doc.docs.first['Number'];
        clubEmail = doc.docs.first['Email'];
      });
    }
    TextEditingController nameController = TextEditingController(text: contactName);
    TextEditingController titleController = TextEditingController(text: contactTitle);
    TextEditingController numberController = TextEditingController(text: clubNumber);
    TextEditingController emailController = TextEditingController(text: clubEmail);

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Update Contact Info'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: numberController,
                decoration: InputDecoration(labelText: 'Number'),
              ),
              TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await _updateContactInfo(
                  nameController.text,
                  titleController.text,
                  numberController.text,
                  emailController.text,
                );
                Navigator.of(context).pop();
              },
              child: Text('Update'),
            ),
          ],
        );
      },
    );
  }
  Future<void> _updateContactInfo(String name, String title, String number, String email) async {
    await FirebaseFirestore.instance.collection('Club Info').doc(clubName).set({
      'Type': 'Contact',
      'Club Name': clubName,
      'Name': name,
      'Title': title,
      'Number': number,
      'Email': email,
    });
    setState(() {
      contactName = name;
      contactTitle = title;
      clubNumber = number;
      clubEmail = email;
    });
  }

  //end*******************************

  Widget buildIcon(BuildContext context, String assetPath, String title, String hintText) {
    return GestureDetector(
      onTap: () async {
      // Fetch existing URL from Firebase
      var doc = await FirebaseFirestore.instance
          .collection('Club URLs')
          .where('Type', isEqualTo: title)
          .where('Club Name', isEqualTo: clubName)
          .limit(1)
          .get();

      if (doc.docs.isNotEmpty) {
        hintText = doc.docs.first['URL'];
      }

      urlController.text = '';
        showDialog(
          // ignore: use_build_context_synchronously
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(title),
              content: TextField(
                controller: urlController,
                decoration: InputDecoration(hintText: hintText),
              ),
              actions:[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Close'),
              ),
              TextButton(
                onPressed: () async {
                  String url = urlController.text;
                  if (url.isNotEmpty && doc.docs.isEmpty) {
                    await FirebaseFirestore.instance.collection('Club URLs').add({
                      'URL': url,
                      'Type': title,
                      'Club Name': clubName,
                    });
                    urlController.clear();
                  }else if(url.isNotEmpty && doc.docs.isNotEmpty){
                    await FirebaseFirestore.instance
                    .collection('Club URLs')
                    .doc(doc.docs.first.id)
                    .update({
                      'URL': url,
                      'Type': title,
                      'Club Name': clubName,
                    });
                    urlController.clear();
                  }
                  // ignore: use_build_context_synchronously
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
            );
          },
        );
      },
      child: SizedBox(
        height: 30,
        child: Image.asset(assetPath, fit: BoxFit.contain),
      ),
    );
  }

//footer end*************************************************************


  Future<void> _showEventsCalendar(BuildContext context) async {
    final List<DateTime> events = await _getClubEvents();

    showDialog(
      // ignore: use_build_context_synchronously
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text( 'Choose ${widget.clubName.split(" ").first} at the bottom of the calendar.'),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.6,
            child: MyCalendar(
              selectedDay: _selectedDay,
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              onDaySelected: (selectedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                });
              },
              eventDays: events, 
              // ignore: non_constant_identifier_names
              onFormatChanged: (CalendarFormat ) {  },
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }


 Future<List<DateTime>> _getClubEvents() async {
  final QuerySnapshot eventsSnapshot = await FirebaseFirestore.instance
      .collection('Events')
      .where('Club Host', isEqualTo: widget.clubName.split(" ").first)
      .get();

  print("Number of documents: ${eventsSnapshot.docs.length}");

  List<DateTime> events = [];

  eventsSnapshot.docs.forEach((doc) {
    print("Document data: ${doc.data()}");
    Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
    Timestamp timestamp = data?['Event Date'] ?? Timestamp(0, 0);
    DateTime eventDate = timestamp.toDate();
    events.add(eventDate);
  });

  return events;
}

}


// ignore: camel_case_types
class buildClubChampionTable extends StatefulWidget {
  final String clubName;

  const buildClubChampionTable({Key? key, required this.clubName}) : super(key: key);

  @override
  _buildClubChampionTableState createState() => _buildClubChampionTableState();
}

// ignore: camel_case_types
class _buildClubChampionTableState extends State<buildClubChampionTable> {
  late ClubLeaderBoardTable dataSource;
  final TextEditingController rankController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController roundsController = TextEditingController();
  final TextEditingController earningsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    dataSource = ClubLeaderBoardTable([]);
    _fetchPlayers();
  }

  Future<void> _fetchPlayers() async {
    try {
      var snapshot = await FirebaseFirestore.instance
          .collection('Club Champions')
          .where('Club Name', isEqualTo: widget.clubName)
          .orderBy('earnings', descending: true)
          .get();

      List<Player> players = snapshot.docs.map((doc) => Player.fromMap(doc.data())).toList();
      setState(() {
        dataSource = ClubLeaderBoardTable(players);
      });
    } catch (e) {
      print('Error fetching players: $e');
    }
  }

Future<void> _addPlayer(Player player) async {
  try {
    var collection = FirebaseFirestore.instance.collection('Club Champions');
    var snapshot = await collection
        .where('Club Name', isEqualTo: widget.clubName)
        .orderBy('earnings', descending: true)
        .limit(10)
        .get();

    if (snapshot.docs.length == 10) {
      var lowestEarningDoc = snapshot.docs.last;
      await collection.doc(lowestEarningDoc.id).delete();
      print('Deleted player with lowest earnings: ${lowestEarningDoc.id}');
    }

    await collection.add({
      'rank': player.rank,
      'playerName': player.playerName,
      'rounds': player.rounds,
      'earnings': player.earnings,
      'Club Name': widget.clubName,
    });

    print('Player added: ${player.playerName}');
    _fetchPlayers();
  } catch (e) {
    print('Error adding player: $e');
  }
    _fetchPlayers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      body: Column(
        children: [
          Expanded(
            child: PaginatedDataTable(
              source: dataSource,
              columns: [
                DataColumn(label: Text('Position')),
                DataColumn(label: Text('Player Name')),
                DataColumn(label: Text('Rounds')),
                DataColumn(label: Text('Earnings')),
              ],
              header: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Center(
                    child: Text(
                      'Club Champions 2024',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: const Color.fromARGB(255, 112, 153, 114),
                      ),
                    ),
                  ),
                  Divider(
                    indent: 0,
                    thickness: 5,
                    color: Colors.green.shade300,
                  ),
                ],
              ),
              columnSpacing: 30,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => _fetchPlayers(),
                child: Text('Fetch Players'),
              ),
              ElevatedButton(
                onPressed: () => _showAddPlayerDialog(),
                child: Text('Add Player'),
              ),

            ],
          ),
        ],
      ),
    );
  }

  Future<void> _showAddPlayerDialog() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Player'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: rankController,
                decoration: InputDecoration(labelText: 'Rank'),
              ),
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Player Name'),
              ),
              TextField(
                controller: roundsController,
                decoration: InputDecoration(labelText: 'Rounds'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: earningsController,
                decoration: InputDecoration(labelText: 'Earnings'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final player = Player(
                  rank: rankController.text,
                  playerName: nameController.text,
                  rounds: int.parse(roundsController.text),
                  earnings: int.parse(earningsController.text),
                );

                await _addPlayer(player);
                Navigator.of(context).pop();
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }
}