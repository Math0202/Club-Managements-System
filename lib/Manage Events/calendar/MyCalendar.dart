import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ongolf_tech_mamagement_system/Manage%20Events/Events.dart';
import 'package:ongolf_tech_mamagement_system/basic%20components/dropDownBar.dart';
import 'package:ongolf_tech_mamagement_system/basic%20components/my_textfied.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:photo_view/photo_view.dart';



class MyCalendar extends StatefulWidget {
  final DateTime selectedDay;
  final DateTime focusedDay;
  final CalendarFormat calendarFormat;
  final void Function(DateTime) onDaySelected;
  final void Function(CalendarFormat) onFormatChanged;

  const MyCalendar({
    super.key,
    required this.selectedDay,
    required this.focusedDay,
    required this.calendarFormat,
    required this.onDaySelected,
    required this.onFormatChanged, required List<DateTime> eventDays,
  });

  @override
  _MyCalendarState createState() => _MyCalendarState();
  
}

class _MyCalendarState extends State<MyCalendar> {
    PlatformFile? pickedFile;
    Uint8List ? selectedImageInBytes;
    bool isUploading = false;
    String imageUrl = '';



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

  // Store events
  Map<DateTime, List<Events>> events = {};

//get docDetails
Future<void> getDeventDetailsFetchingcId() async {
  await FirebaseFirestore.instance.collection('Events').get().then((snapshot1) {
    snapshot1.docs.forEach((document) async {
      DocumentSnapshot docSnapshot = await document.reference.get();

      if (docSnapshot.exists) {
        var clubName = docSnapshot.get('Club Host');
        var entryFee = docSnapshot.get('Entry Fee');
        var eventName = docSnapshot.get('Event Name');
        var format = docSnapshot.get('Formate');
        var moreInfo = docSnapshot.get('More info');
        var due = docSnapshot.get('Sign up due');
        var selectedDay = docSnapshot.get('SelectedDay');
        var posterURL =  docSnapshot.get('Event poster');
         setState(() {
          events.update(
            (selectedDay as Timestamp).toDate(), // Convert Timestamp to DateTime
            (value) => [...value, Events(eventName, clubName, format, entryFee, due, moreInfo, posterURL ?? '')] ,
            ifAbsent: () => [Events(eventName, clubName, format, entryFee, due, moreInfo,posterURL ?? '')],
          );
        });
      }
    });
  });
}

 List<String> clubNames = ["All",'Omeya','DZ', 'NAGU', 'Windhoek', 'Tsumeb', 'Oshakati'];
  String selectedClubName = 'All';
//build dropdown elements-----------------------------------------------------------------------
 

  List<String> colors = ["Select",'Yellow', 'Red', 'Blue', 'Green', 'White'];
  String selectedMenColor = 'Select';
  String selectedLadiesColor = 'Select';

  List<String> format= ["Select",'Scamble Drive', 'Stableford', 'Blue', 'Medal', 'Skins'];
  String formatVale = 'Select';

  List<int> numberPerTeam = [0,1, 2, 3, 4, 5, 6,7,8];
  int numberperTeam = 0;

  List<int> numberOfTeams = [0,1, 2, 3, 4, 5, 6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30];
  int numberofTeams = 0;

  List<int> numberOfholes = [9,18,27,36];
  int numberofholes = 18;

  List<int> numberOfRounds = [0,1, 2, 3, 4, 5, 6,7,8];
  int numberofRounds = 0;
 //for strings


Widget buildDropdownContainer2({
  required String label,
  required int value,
  required List<int> items,
  required Function(int?) onChanged,
}) {
  return Container(
    width: 375,
    decoration: BoxDecoration(
      color: Colors.grey.shade200,
      borderRadius: BorderRadius.circular(5),
    ),
    child: Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[500],
              fontWeight: FontWeight.bold,
            ),
          ),
          DropdownButton<int>(
            value: value,
            onChanged: onChanged,
            items: items.map<DropdownMenuItem<int>>((int item) {
              return DropdownMenuItem<int>(
                value: item,
                child: Text(item.toString()), // Convert int to string for display
              );
            }).toList(),
          ),
        ],
      ),
    ),
  );
}

//end of dropdown -----------------------------------------------------------------

  late final ValueNotifier<List<Events>> _selectedEvents;

  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

 


  TextEditingController titleController = TextEditingController();
  TextEditingController clubNameController = TextEditingController();
  TextEditingController formatController = TextEditingController();
  TextEditingController entryFeeController = TextEditingController();
  TextEditingController dueDateForRegController = TextEditingController();
  TextEditingController moreDetailController = TextEditingController();



  final ValueNotifier<DateTime> _selectedDateNotifier = ValueNotifier<DateTime>(DateTime.now());

@override
void initState() {
  super.initState();
  getDeventDetailsFetchingcId(); // Call method to fetch events
  _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay));
  }

List<Events> _getEventsForDay(DateTime day){
  return events[day] ?? [];
}

  Future<void> eventDetails(
    TextEditingController titleController,
    String selectedClubName,
    TextEditingController formatController,
    TextEditingController entryFeeController,
    TextEditingController dueDateForRegController,
    TextEditingController moreDetailController,
    DateTime selectedDayField,
    Map<DateTime, List<Events>> events,
    ValueNotifier<List<Events>> selectedEvents,
    String? posterURL,
  ) async {
   
    try {

       // Upload image file
        String imageUrl = '';
        if (pickedFile != null) {
          Reference ref = FirebaseStorage.instance
              .ref()
              .child('Event poster');
          await ref.putData(selectedImageInBytes!);
          imageUrl = await ref.getDownloadURL();
        } 

      await FirebaseFirestore.instance.collection("Events").doc().set({
        
        'Event Name': titleController.text,
        'Club Host': selectedClubName,
        'Formate': formatController.text,
        'Format': formatController.text,
        'Entry Fee': entryFeeController.text,
        'Sign up due': dueDateForRegController.text,
        'More info': moreDetailController.text,
        'SelectedDay': Timestamp.fromDate(selectedDayField),
        if(imageUrl.isNotEmpty) "Event poster": imageUrl 
         else "Event poster": 'https://i.pinimg.com/564x/cb/b8/6c/cbb86c239142b1acf2ea5c102f155137.jpg'

      });
    } catch (e) {
      print('Error: $e');
    }
  }


@override
Widget build(BuildContext context) {
  return Column(
    children: [
      ValueListenableBuilder<DateTime>(
        valueListenable: _selectedDateNotifier,
        builder: (context, selectedDate, _) {
          return TableCalendar(
            focusedDay: widget.focusedDay,
            firstDay: DateTime.utc(2022, 3, 14),
            lastDay: DateTime(2030, 11, 11),
            startingDayOfWeek: StartingDayOfWeek.monday,
            selectedDayPredicate: (day) {
              return isSameDay(widget.selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
                _selectedDateNotifier.value = selectedDay;
              });
              widget.onDaySelected(selectedDay);
              // Convert selectedDay to local time
              final localSelectedDay = selectedDay.toLocal();

              List<Events>? eventList = events[localSelectedDay];
              if (eventList == null || eventList.isEmpty) {
              } else {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text(eventList[0].title),
                      content: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                                  children: [
                                 Text('Title: ${eventList[0].title}'),
                                 Text('Host: ${eventList[0].host}'),
                                 Text('Format: ${eventList[0].format}'),
                                 Text('Entry Fee: ${eventList[0].entryFee}'),
                                 Text('Sign-up Due: ${eventList[0].signUpDue}'),
                                 Text('More Info: ${eventList[0].moreInfo}'),
                                 if(eventList[0].posterURL != '')
                                GestureDetector(
                               onTap: () {
                                 Navigator.of(context).push(MaterialPageRoute(
                                   builder: (_) => Scaffold(
                                     appBar: AppBar(),
                                     body: PhotoView(
                                       imageProvider: NetworkImage(eventList[0].posterURL),
                                       loadingBuilder: (context, event) {
                                         return const Center(
                                           child: CircularProgressIndicator(),
                                         );
                                       },
                                       backgroundDecoration: const BoxDecoration(color: Colors.black),
                                     ),
                                   ),
                                 ));
                               },
                               child: SizedBox(
                                 height: 300, width: 500,
                                 child: Image.network(eventList[0].posterURL),
                               ),
                             ),
                       ],
                      ),
                      
                    
                    );
                  },
                );
              }
            },
            availableCalendarFormats: const {
              CalendarFormat.month: 'Month',
            },
            calendarFormat: widget.calendarFormat,
            onFormatChanged: (format) {
              widget.onFormatChanged(format);
            },
            eventLoader: (day) {
              DateTime dayWithTime = Timestamp.fromDate(day).toDate();
              List<Events>? eventList = events[dayWithTime];
              if (selectedClubName == "All") {
                return eventList ?? [];
              } else {
                return eventList != null
                    ? eventList.where((event) => event.host == selectedClubName).toList()
                    : [];
              }
            },
          );
        },
      ),
      const SizedBox(height: 8.0),
      DropdownButton<String>(
        value: selectedClubName,
        onChanged: (String? newValue) {
          setState(() {
            selectedClubName = newValue!;
            _selectedEvents.value = _getEventsForDay(_selectedDay);
          });
        },
        items: clubNames.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      ),
      
      const SizedBox(height: 10.0),
      FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return StatefulBuilder(
                builder: (context, setState) {
                  return AlertDialog(
                    scrollable: true,
                    title: Center(child: Text('Date: ${DateFormat('dd MMMM yyyy').format(_selectedDateNotifier.value)}')), // Format selected date
                    content: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          MyTextFied(
                            controller: titleController,
                              obscureText: false,
                              hintText: 'Event Title',
                              TextInputType:TextInputType.text,
                          ),
                          buildDropdownContainer(
                            label: '  Hosting Club:',
                            value: selectedClubName,
                            items: clubNames,
                            onChanged: (newValue) {
                              setState(() {
                                selectedClubName = newValue!;
                              });
                            },
                          ),
                          const SizedBox(height: 2),
                          buildDropdownContainer(
                            label: '  Tee Color Men:',
                            value: selectedMenColor,
                            items: colors,
                            onChanged: (newValue) {
                              setState(() {
                                selectedMenColor = newValue!;
                              });
                            },
                          ),
                          const SizedBox(height: 2),
                          buildDropdownContainer(
                            label: '  Tee Color Ladies:',
                            value: selectedLadiesColor,
                            items: colors,
                            onChanged: (newValue) {
                              setState(() {
                                selectedLadiesColor = newValue!;
                              });
                            },
                          ),
                          const SizedBox(height: 2),
                          buildDropdownContainer(
                            label: '  Formate:',
                            value: formatVale,
                            items: format,
                            onChanged: (newValue) {
                              setState(() {
                                formatVale = newValue!;
                              });
                            },
                          ),
                          const SizedBox(height: 2),
                          buildDropdownContainer2(
                            label: '  Number of Rounds/day',
                            value: numberofRounds,
                            items: numberOfRounds,
                            onChanged: (newValue) {
                              setState(() {
                                numberofRounds = newValue!;
                              });
                            },
                          ),
                          const SizedBox(height : 2),
                          buildDropdownContainer2(
                            label: '  Number of Teams',
                            value: numberofTeams,
                            items: numberOfTeams,
                            onChanged: (newValue) {
                              setState(() {
                                numberofTeams = newValue!;
                              });
                            },
                          ),
                          const SizedBox(height: 2),
                          buildDropdownContainer2(
                            label: '  Players Per Team',
                            value: numberperTeam,
                            items: numberPerTeam,
                            onChanged: (newValue) {
                              setState(() {
                                numberperTeam = newValue!;
                              });
                            },
                          ),
                          const SizedBox(height: 2),
                          buildDropdownContainer2(
                            label: '  Number of Holes/day',
                            value: numberofholes,
                            items: numberOfholes,
                            onChanged: (newValue) {
                              setState(() {
                                numberofholes = newValue!;
                              });
                            },
                          ),
                          MyTextFied(
                           obscureText: false,
                            controller: formatController,
                             
                              hintText: 'Format',
                           
                          ),
                          MyTextFied(
                            obscureText: false,
                            controller: entryFeeController,
                            
                              hintText: 'Entry fee',
                              TextInputType: TextInputType.number,
                          ),
                          MyTextFied(
                            obscureText: false,
                            controller: dueDateForRegController,
                           
                              hintText: 'Due for Entry',
                            TextInputType: TextInputType.datetime,
                          ),
                          MyTextFied(
                            obscureText: false,
                            controller: moreDetailController,
                            
                              hintText: 'More Detail & info',
                            
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
                            child: const Text('Select poster Image'),
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      ElevatedButton(
                        onPressed: () {
                          events.addAll({
                            _selectedDateNotifier.value: [
                              Events(
                                titleController.text,
                                selectedClubName,
                                formatController.text,
                                entryFeeController.text,
                                dueDateForRegController.text,
                                moreDetailController.text,
                                  imageUrl,
                              )
                            ]
                          });
                          eventDetails(
                            titleController,
                            selectedClubName,
                            formatController,
                            entryFeeController,
                            dueDateForRegController,
                            moreDetailController,
                            _selectedDateNotifier.value,
                            events,
                            _selectedEvents,
                             imageUrl,
                          );
                          Navigator.of(context).pop();
                        },
                        child: Text('Create'),
                      )
                    ],
                  );
                },
              );
            },
          );
        },
        child: const Icon(Icons.event_note),
      ),
      const SizedBox(height: 10,)
    ],
  );
}

}

