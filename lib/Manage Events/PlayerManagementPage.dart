import 'package:flutter/material.dart';
import 'package:ongolf_tech_mamagement_system/basic%20components/contentTable.dart';
import 'package:ongolf_tech_mamagement_system/basic%20components/contentTable2.dart';

class PlayerManagementPage extends StatefulWidget {
  const PlayerManagementPage({super.key});

  @override
  State<PlayerManagementPage> createState() => _PlayerManagementPageState();
}

class _PlayerManagementPageState extends State<PlayerManagementPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: BuildTableContainer(
                check: false,
                title: "Not Grouped Players",
                container: ungrouped(context),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
            width: double.infinity,
            margin: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.grey.shade900),
            ),
            child: Center(
              child: TextField(
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Search for Group [Name/#] or Player',
                  prefixIcon: Icon(Icons.person_search),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
          ),
                  BuildTableContainer2(
                    check: true,
                    title: "Group I",
                    container: grouped(context),
                  ),
                  BuildTableContainer2(
                    check: true,
                    title: "Tap in Bardie",
                    container: grouped(context),
                  ),
                  BuildTableContainer2(
                    check: true,
                    title: "The A team",
                    container: grouped(context),
                  ),
                  BuildTableContainer2(
                    check: true,
                    title: "Team Eagle",
                    container: grouped(context),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Container ungrouped(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height - 90,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        color: Colors.white,
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.grey.shade900),
            ),
            child: Center(
              child: TextField(
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Search for player',
                  prefixIcon: Icon(Icons.person_search),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: 19,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        CircleAvatar(
                          radius: 20,
                          child: Icon(Icons.person),
                        ),
                        Text(
                          'Full Name(Hcp)',
                          style: TextStyle(),
                        ),
                        Text('No Payment'),
                        Row(
                          children: [
                            Text('Group'),
                            Icon(
                              Icons.arrow_drop_down
                            )
                          ],
                        ),
                        Icon(Icons.check_box_outline_blank),
                        Icon(Icons.delete),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Container grouped(BuildContext context) {
    return Container(
      height: 230,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        color: Colors.white,
      ),
      child: ListView.builder(
        itemCount: 4,
        itemBuilder: (context, index) {
          return Column(
            children: [
              Divider(),
              Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        CircleAvatar(
                          radius: 20,
                          child: Icon(Icons.person),
                        ),
                        Text(
                          'Full Name(Hcp))',
                          style: TextStyle(),
                        ),
                        Text('No Payment'),
                        Row(
                          children: [
                            Text('Change Group'),
                            Icon(
                              Icons.arrow_drop_down
                            )
                          ],
                        ),
                        Icon(Icons.check_box_outline_blank),
                        Icon(Icons.delete),
                      ],
                    ),
            ],
          );
        },
      ),
    );
  }
}
