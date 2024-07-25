// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'package:flutter/material.dart';
import 'package:ongolf_tech_mamagement_system/manage%20players/playedMatchesTable.dart';

// ignore: camel_case_types
class playerProfile extends StatefulWidget {
  final String userName;
  final int handicap;
  final String profileImageUrl;
  final String homeClub;
  final String playerFullName;
  final DataTableSource data1 = MatchesPlayedTable();
  playerProfile({super.key,
  required this.userName,
  required this.handicap,
  required this.profileImageUrl,
  required this.homeClub,
  required this.playerFullName
  });

  @override
  State<playerProfile> createState() => _playerProfileState();
}

class _playerProfileState extends State<playerProfile> {


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.userName, style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 95, 228, 99),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 210,
              width: double.infinity,
              color: Colors.green.shade100,
              child: Row(
                children: [
                  Column(
                    children: [
                      Spacer(),
                      CircleAvatar(
                        radius: 90,
                        backgroundImage: widget.profileImageUrl != '' ? 
                        NetworkImage(widget.profileImageUrl) 
                        : null,
                      child: widget.profileImageUrl.isEmpty
                      ? Icon(Icons.person, size: 180,)
                      :null,
                      ),
                      Text("${widget.playerFullName}")
                    ],
                  ),
                  Column(
                    children: [
                      Spacer(),
                      Container(
                        height: 36,
                        width: 164,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Row(
                            children: [
                              Icon(Icons.eco, color: Colors.green),
                              Text(
                                'Handicap:  ${widget.handicap}',
                                style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Colors.black),
                              ),
                            ],
                          ),
                        ),
                      ),
                        GestureDetector(
                          child: Container(
                             margin: const EdgeInsets.only(top: 8),
                          height: 36,
                          width: 164,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: const Row(
                              children: [
                                Icon(Icons.contact_page_outlined),
                                Text(
                                  'Contact details',
                                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Colors.black),
                                ),
                              ],
                            ),
                          ),
                          ),
                          onTap: (){
                            showDialog(context: context, builder: (BuildContext context){
                              return AlertDialog(
                                title: Text("Contact Details"),
                                content: Container(
                                  height: 65,
                                  child: const Column(
                                    children: [
                                      Row(children: [Icon(Icons.phone_outlined), Text('    +264 81 803 1189')],),
                                      Row(children: [Icon(Icons.email_outlined), Text('    mentor@yahoo.com')],)
                                    ],
                                  ),
                                ),
                              );
                            } );
                          },
                        ),
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        height: 36,
                        width: 164,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Row(
                            children: [
                              Container(padding: EdgeInsets.all(4), child: Icon(Icons.settings)),
                             const Text(
                                'Edit profile',
                                style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Colors.black),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      Spacer(),
                      Row(
                        children: [
                          Icon(Icons.home),
                          Text(
                          '${widget.homeClub}',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 5,),
            Container(
              height: 370,
              width: 250,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.emoji_events_outlined),
                      Text("Tournaments won: 4", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w200),)
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.play_arrow_outlined),
                      Text("Tournerments played: 13", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w200),)
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.play_arrow_sharp),
                      Text("Matches played: 33", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w200),)
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.celebration),
                      Text("Double Eagles: 0", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w200),)
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.celebration),
                      Text("Eagles: 3", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w200),)
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.celebration_outlined),
                      Text("Birdies: 9", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w200),)
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.celebration_outlined),
                      Text("Pars: 77", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w200),)
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.celebration_outlined),
                      Text("Bogys: 178", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w200),)
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.golf_course_outlined),
                      Text("Stroke Avarage: 95", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w200),)
                    ],
                  ),
                   Row(
                    children: [
                      Icon(Icons.sports_golf_outlined),
                      Text("Longest Drive: 190m", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w200),)
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.directions_walk_outlined),
                      Text("Tracked course meters: 6,190", style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w200),)
                    ],
                  ),
                  Spacer(),
                  Row(
                    children: [
                      Icon(Icons.verified_outlined),
                      Text("Verification State: Verified", style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w900),)
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.card_membership_outlined),
                      Text("Golf Member since: 2020", style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w900),)
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
            Container(
              child: PaginatedDataTable(
                source: widget.data1,
                 columns: [
                  DataColumn(label: Text('Club')),
                  DataColumn(label: Text('Date')),
                  DataColumn(label: Text('Strokes')),
                  DataColumn(label: Text('Approved')),
                ],
                header: Column(
                  children: [
                    Center(
                      child: Text(
                        'Your Last 20 rounds.',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade300),
                      ),
                    ),
                    Divider(
                      indent: 0,
                      thickness: 5,
                      color: Colors.black,
                    ),
                  ],
                ),
                columnSpacing: 30,
              ),
            ),
            Container(
              margin: EdgeInsets.only(bottom: 8),
              height: 36,
              width: 200,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Row(
                  children: [
                    Icon(Icons.eco, color: Colors.green),
                    Text(
                      'Refresh handicap',
                      style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
