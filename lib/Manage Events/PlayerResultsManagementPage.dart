import 'package:flutter/material.dart';
import 'package:ongolf_tech_mamagement_system/basic%20components/contentTable.dart';
import 'package:ongolf_tech_mamagement_system/basic%20components/dropDownBar.dart';
import 'package:ongolf_tech_mamagement_system/basic%20components/my_button.dart';

class PlayerResultsManagementPage extends StatefulWidget {
  const PlayerResultsManagementPage({super.key});

  @override
  State<PlayerResultsManagementPage> createState() => _PlayerResultsManagementPageState();
}

class _PlayerResultsManagementPageState extends State<PlayerResultsManagementPage> {
  final List<String> notGrouped = [
    'Select',
    'Player - Stroke - Gross',
    'Player - Stroke - Net (gross holes)',
    'Player - Stroke - Net (net holes)',
    'Player - Points - Gross/Quota',
    'Player - Points - Net',
    'Player - Win by gross or net',
    'Player - Selected holes',
    'Player - Drop worst hole(s)',
    'Skins - Gross',
    'Skins - Net',
    'Skins - Gross and Net'
  ];
  String selectedNotGrouped = 'Select';

  final List<String> team = [
    'Select',
    'Team - Scramble - Gross',
    'Team - Scramble - Net',
    'Team - Aggregate - Stroke - Gross',
    'Team - Aggregate - Stroke - Net',
    'Team - Aggregate - Points - Gross',
    'Team - Aggregate - Points - Net',
    'Team - Aggregate - Points - Less quota',
    'Team - Aggregate - Best total X of Y - Gross',
    'Team - Aggregate - Best total X of Y - Net',
    'Team - Best balls (custom) - Stroke or points'
  ];
  String selectedTeam = 'Select';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  buildDropdownContainer(
                  label: 'Calculate Individual Player scores:',
                  items: notGrouped, 
                  value: selectedNotGrouped, 
                  onChanged: (newValue ) { 
                    setState(() {
                      selectedNotGrouped = newValue!;
                    });
                   },
                ),
                  BuildTableContainer(
                    check: false,
                    title: "Not Grouped Players",
                    container: buildNotGroupedTable(),
                  ),
                  MyButton(onTap: (){}, text: 'Submit All')
                ],
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                   buildDropdownContainer(
                  label: 'Calculate Teams scores :',
                  items: team, 
                  value: selectedTeam, 
                  onChanged: (newValue ) { 
                    setState(() {
                      selectedTeam = newValue!;
                    });
                   },
                ),
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
                  hintText: 'Search for Group [Name/#] or Player',
                  prefixIcon: Icon(Icons.person_search),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
          ),
                  BuildTableContainer(
                    check: true,
                    title: "Group I",
                    container: buildGroupedTable(),
                  ),
                  BuildTableContainer(
                    check: true,
                    title: "Tap in Bardie",
                    container: buildGroupedTable(),
                  ),
                  BuildTableContainer(
                    check: true,
                    title: "The A team",
                    container: buildGroupedTable(),
                  ),
                  BuildTableContainer(
                    check: true,
                    title: "Team Eagle",
                    container: buildGroupedTable(),
                  ),
                   MyButton(onTap: (){}, text: 'Submit All')
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Container buildNotGroupedTable() {
    return Container(
      width: double.infinity,
       decoration: BoxDecoration(
        color:Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
          
        )
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 19,
            columns: [
              DataColumn(label: Text('')),
              DataColumn(label: Text('Player Name')),
              DataColumn(label: Text('Hcp')),
              DataColumn(label: Text('OUT',style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('IN',style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('TOTAL',style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Points')),
              DataColumn(label: Text('Earnings')),
              DataColumn(label: Text('check')),
            ], 
            rows: List.generate(
            20,
            (index) => DataRow(
              cells: [
                DataCell(CircleAvatar(radius: 20, child: Icon(Icons.person),)),
                DataCell(Text('Full Name'), placeholder: true),
                DataCell(Text('#'), placeholder: true),
                DataCell(Text('0'), placeholder: true),
                DataCell(Text('0'), placeholder: true),
                DataCell(Text('0'), placeholder: true),
                DataCell(Text('#'), placeholder: true),
                DataCell(Text('')),
                DataCell(Icon(Icons.check_box_outline_blank)),
            ]),
        ),
      ),
          )),
    );
  }
 Container buildGroupedTable() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color:Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
          
        )
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 19,
            columns: [
              DataColumn(label: Text('')),
              DataColumn(label: Text('Player Name')),
              DataColumn(label: Text('Hcp')),
              DataColumn(label: Text('OUT',style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('IN',style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('TOTAL',style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Points')),
              DataColumn(label: Text('Earnings')),
              DataColumn(label: Text('check')),
            ], 
            rows: List.generate(
            4,
            (index) => DataRow(
              cells: [
                DataCell(CircleAvatar(radius: 20, child: Icon(Icons.person),)),
                DataCell(Text('Full Name'), placeholder: true),
                DataCell(Text('#'), placeholder: true),
                DataCell(Text('0'), placeholder: true),
                DataCell(Text('0'), placeholder: true),
                DataCell(Text('0'), placeholder: true),
                DataCell(Text('#'), placeholder: true),
                DataCell(Text('')),
                DataCell(Icon(Icons.check_box_outline_blank)),
            ]),
        ),
      ),
          )),
    );
  }
}