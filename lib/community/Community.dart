// ignore_for_file: library_private_types_in_public_api

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ongolf_tech_mamagement_system/Manage%20Club%20Page/clubs_page.dart';
import 'package:ongolf_tech_mamagement_system/Manage%20Events/eventsPage.dart';
import 'package:ongolf_tech_mamagement_system/Pro%20Shop/proShop.dart';
import 'package:ongolf_tech_mamagement_system/community/chattingServices/chat.dart';
import 'package:ongolf_tech_mamagement_system/community/clubs.dart';
import 'package:ongolf_tech_mamagement_system/homePage.dart';

class Community extends StatefulWidget {
  const Community({Key? key}) : super(key: key);

  @override
  State<Community> createState() => _CommunityState();
}

class _CommunityState extends State<Community> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Map<String, dynamic>? selectedChat;

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  @override
    void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.green.shade100,
        body: Row(
          children: [
            SizedBox(
              width: 340,
              child: Stack(
                children: [
                  SafeArea(
                    child: Column(
                      children: [
                        SizedBox(
                          height: 50,
                          child: Container(
                            margin: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: Colors.grey.shade900),
                            ),
                            child: const Center(
                              child: TextField(
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Search...',
                                  prefixIcon: Icon(Icons.person_search),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 1),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 50,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 197,
                      decoration: BoxDecoration(
                        color: Colors.green.shade200,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: Column(
                        children: [
                          const Spacer(),
                          Center(
                            child: Text(
                              'Golf clubs and other communities.',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey[800]),
                            ),
                          ),
                          Spacer(),
                          SizedBox(
                            height: 160,
                            child: StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance.collection('clubs').snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.hasError) {
                                  return const Text("Error");
                                }
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const Text('Loading...');
                                }
                                return ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: snapshot.data!.docs.length,
                                  itemBuilder: (context, index) {
                                    final clubDoc = snapshot.data!.docs[index];
                                    final clubData = clubDoc.data() as Map<String, dynamic>;
                                    final club = Clubs(
                                      id: clubDoc.id,
                                      name: clubData['Club Name'],
                                      imagePath: clubData['Profile Picture'].toString(),
                                    );
                                    return ClubWidget(
                                    club: club,
                                    onTap: (chatInfo) {
                                    setState(() {
                                    selectedChat = chatInfo;
                                   });
                                  },
                                );
                              });
                            },
                          ),
                          )],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 220,
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.green.shade400,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: Column(
                        children: [
                          Center(
                            child: Text(
                              'Chats',
                              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.grey[800]),
                            ),
                          ),
                          Expanded(
                            child: _buildUserList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            //when a user taps on a group or a chat this should be updated with the infomation/ chat content of the tapped chatroom
            if (selectedChat != null && selectedChat!['isGroupChat'] == false ) ...[
              Expanded(
                child: ChatPage(
                  receivedUserID: selectedChat!['receivedUserID'],
                  receivedUserFullName: selectedChat!['receivedUserFullName'],
                  isGroupChat: selectedChat!['isGroupChat'], 
                  userImageUrl:  selectedChat!['Profile Picture'].toString(),
                  
                ),
              ),
            ]else if (selectedChat != null && selectedChat!['isGroupChat'] == true) ...[
              Expanded(
                child: ChatPage(
                  receivedUserID: selectedChat!['receivedUserID'],
                  receivedUserFullName: selectedChat!['receivedUserFullName'],
                  isGroupChat: selectedChat!['isGroupChat'],
                  clubName: selectedChat!['clubName']  as String?,
                   userImageUrl: selectedChat!['Profile Picture'].toString(),
                  
                ),
              ),
            ] else
            Expanded(
              child: (
                 Container(
                  color: Colors.green.shade100,
                  child: const Center(
                   child: Text("Select a conversation or group.",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w400
                    ),
                    ),
                  ),
                )
              ),
            ),
          ],
        ),
      ),
    );
  }

Widget _buildUserList() {
  return StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance.collection('users').snapshots(),
    builder: (context, userSnapshot) {
      if (userSnapshot.hasError) {
        return const Text("Error");
      }
      if (userSnapshot.connectionState == ConnectionState.waiting) {
        return const Text('Loading...');
      }

      return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('clubs').snapshots(),
        builder: (context, clubSnapshot) {
          if (clubSnapshot.hasError) {
            return const Text("Error");
          }
          if (clubSnapshot.connectionState == ConnectionState.waiting) {
            return const Text('Loading...');
          }

          final clubDocs = clubSnapshot.data!.docs;
          final clubData = clubDocs.map((doc) => doc.data()).toList();

          return ListView.builder(
            itemCount: userSnapshot.data!.docs.length + clubDocs.length,
            itemBuilder: (context, index) {
              if (index < userSnapshot.data!.docs.length) {
                final userData = userSnapshot.data!.docs[index].data() as Map<String, dynamic>;
                return _buildUserListItem(userData);
              } else {
                final clubIndex = index - userSnapshot.data!.docs.length;
                final club = Club(
                  id: clubDocs[clubIndex].id,
                  name: (clubData[clubIndex] as Map<String, dynamic>)['Club Name'],
                  imagePath: (clubData[clubIndex] as Map<String, dynamic>)['Profile Picture'].toString(),
                );
                return _buildClubListItem(club);
              }
            },
          );
        },
      );
    },
  );
}

Widget _buildClubListItem(Club club) {
  return ListTile(
    title: Column(
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 29,
              backgroundColor: Colors.white,
              child: CircleAvatar(
                radius: 27,
                backgroundImage: NetworkImage(club.imagePath),
              ),
            ),
            const SizedBox(width: 8),
            Text(club.name),
          ],
        ),
        Divider(
          indent: 40,
        ),
      ],
    ),
      onTap: () {
              setState(() {
              selectedChat = {
                'receivedUserID': club.id,
                'receivedUserFullName': club.name,
                'isGroupChat': false,
                'clubName': club.name,
                'profilePicture': club..toString(),
              };
            });
    },
  );
}

Widget _buildUserListItem(Map<String, dynamic> userData) {
  User? currentUser = _auth.currentUser;

  if (currentUser != null && currentUser.email != userData['email']) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(userData['uid']).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          Map<String, dynamic> user = snapshot.data!.data() as Map<String, dynamic>;
          return ListTile(
            title: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 29,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 27,
                        backgroundImage: NetworkImage(user['Profile Picture']),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(child: Text(userData['Full Name'])),
                  ],
                ),
                Divider(
                  indent: 40,
                ),
              ],
            ),
            onTap: () {
              setState(() {
              selectedChat = {
                'receivedUserID': userData['uid'],
                'receivedUserFullName': userData['Full Name'],
                'isGroupChat': false,
                'clubName': userData['Club Name'],
                'profilePicture': user['Profile Picture'].toString(),
              };
            });
            },
          );
        } else {
          return ListTile(
            title: Row(
              children: [
                CircleAvatar(radius: 32, backgroundColor: Colors.grey),
                const SizedBox(width: 8),
                Flexible(child: Text(userData['Full Name'])),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatPage(
                    receivedUserFullName: userData['Full Name'],
                    receivedUserID: userData['uid'],
                    isGroupChat: false, 
                    userImageUrl: userData['Profile Picture'].toString(),
                    
                  ),
                ),
              );
            },
          );
        }
      },
    );
  } else {
    return Container();
  }
}
}

class Club {
  final String id;
  final String name;
  final String imagePath;

  Club({
    required this.id,
    required this.name,
    required this.imagePath,
  });
}


class PlayerWidget extends StatelessWidget {
  final String receiverImagePath;
  final String receiverFullName;

  const PlayerWidget({
    required this.receiverImagePath,
    required this.receiverFullName,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage(receiverImagePath),
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      receiverFullName,
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700]),
                    ),
                  ),
                  
                ],
              ),
            ],
          ),
          const Divider(
            indent: 70,
          )
        ],
      ),
    );
  }
}class ClubWidget extends StatelessWidget {
  final Clubs club;
  final Function(Map<String, dynamic>) onTap;

  const ClubWidget({
    Key? key,
    required this.club,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Column(
        children: [
          Stack(
            children: [
              GestureDetector(
                onTap: () {
                  onTap({
                    'receivedUserID': club.id,
                    'receivedUserFullName': club.name,
                    'isGroupChat': true,
                    'clubName': club.name,
                  });
                },
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    radius: 48,
                    backgroundImage: NetworkImage(club.imagePath),
                  ),
                ),
              ),
            ],
          ),
          Text(
            club.name.split(' ')[0],
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700]),
          )
        ],
      ),
    );
  }
}
