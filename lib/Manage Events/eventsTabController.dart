import 'package:flutter/material.dart';
import 'package:ongolf_tech_mamagement_system/Manage%20Events/PlayerManagementPage.dart';
import 'package:ongolf_tech_mamagement_system/Manage%20Events/PlayerResultsManagementPage.dart';
import 'package:ongolf_tech_mamagement_system/Manage%20Events/PlayerScoresManagementPage.dart';
import 'package:ongolf_tech_mamagement_system/Manage%20Events/PlayerSignUpPage.dart';
import 'package:ongolf_tech_mamagement_system/Manage%20Events/eventsPage.dart';

class eventsTabConntroller extends StatefulWidget {
  const eventsTabConntroller({super.key});

  @override
  State<eventsTabConntroller> createState() => _eventsTabConntrollerState();
}

class _eventsTabConntrollerState extends State<eventsTabConntroller> {


  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Column(
        children: const [
          // Create the tabs
           TabBar(
            unselectedLabelColor: Colors.white,
            labelColor: Color.fromARGB(255, 42, 185, 47),
            tabs: [
              Tab(
                icon: Icon(Icons.settings),
                text: 'Set-up',
              ),
              Tab(
                icon: Icon(Icons.play_circle),
                text: 'Sign-up',
              ),
              Tab(
                icon: Icon(Icons.manage_accounts),
                text: 'Manage',
              ),
              Tab(
                icon: Icon(Icons.book),
                text: 'Score',
              ),
              Tab(
                icon: Icon(Icons.calculate),
                text: 'Results',
              ),
            ],
          ),
          // Access the different tab content
          Expanded(
            child: TabBarView(
              children: [
                EventsPage(),
                PlayerSignUpPage(),
                PlayerManagementPage(),
                PlayerScoresManagementPage(),
                PlayerResultsManagementPage(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
