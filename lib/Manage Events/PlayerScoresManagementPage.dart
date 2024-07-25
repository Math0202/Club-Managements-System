import 'package:flutter/material.dart';
import 'package:ongolf_tech_mamagement_system/basic%20components/contentTable.dart';

class PlayerScoresManagementPage extends StatefulWidget {
  const PlayerScoresManagementPage({super.key});

  @override
  State<PlayerScoresManagementPage> createState() => _PlayerScoresManagementPageState();
}

class _PlayerScoresManagementPageState extends State<PlayerScoresManagementPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
        BuildTableContainer(
          check: false,
            title: "Not Grouped Players",
            container: buildNotGroupedTable(),
          ),
    BuildTableContainer(
        check: false,
              title: "Group I",
              container: buildGroupedTable(),
            ),
            BuildTableContainer(
              check: false,
              title: "Tap in Bardie",
              container: buildGroupedTable(),
            ),
            BuildTableContainer(
              check: false,
              title: "The A team",
              container: buildGroupedTable(),
            ),
            BuildTableContainer(
              check: false,
              title: "Team Eagle",
              container: buildGroupedTable(),
            ),
        ]
      )
    );
  }

  Container buildNotGroupedTable() {
    return Container(
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
              DataColumn(label: Text('1')),
              DataColumn(label: Text('2')),
              DataColumn(label: Text('3')),
              DataColumn(label: Text('4')),
              DataColumn(label: Text('5')),
              DataColumn(label: Text('6')),
              DataColumn(label: Text('7')),
              DataColumn(label: Text('8')),
              DataColumn(label: Text('9')),
              DataColumn(label: Text('OUT',style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('10')),
              DataColumn(label: Text('11')),
              DataColumn(label: Text('12')),
              DataColumn(label: Text('13')),
              DataColumn(label: Text('14')),
              DataColumn(label: Text('15')),
              DataColumn(label: Text('16')),
              DataColumn(label: Text('17')),
              DataColumn(label: Text('18')),
              DataColumn(label: Text('IN',style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('TOTAL',style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Season \nPoints')),
              DataColumn(label: Text('Earnings')),
              DataColumn(label: Text('Update')),
              DataColumn(label: Text('check')),
            ], 
            rows: List.generate(
            20,
            (index) => DataRow(
              cells: [
                
                DataCell(CircleAvatar(radius: 20, child: Icon(Icons.person),)),
                DataCell(Text('Full Name'), placeholder: true),
                DataCell(Text('#'), placeholder: true),
                DataCell(Text(''), showEditIcon: true),
                DataCell(Text(''), showEditIcon: true),
                DataCell(Text(''), showEditIcon: true),
                DataCell(Text(''), showEditIcon: true),
                DataCell(Text(''), showEditIcon: true),
                DataCell(Text(''), showEditIcon: true),
                DataCell(Text(''), showEditIcon: true),
                DataCell(Text(''), showEditIcon: true),
                DataCell(Text(''), showEditIcon: true),
                DataCell(Text('0'), placeholder: true),
                DataCell(Text(''), showEditIcon: true),
                DataCell(Text(''), showEditIcon: true),
                DataCell(Text(''), showEditIcon: true),
                DataCell(Text(''), showEditIcon: true),
                DataCell(Text(''), showEditIcon: true),
                DataCell(Text(''), showEditIcon: true),
                DataCell(Text(''), showEditIcon: true),
                DataCell(Text(''), showEditIcon: true),
                DataCell(Text(''), showEditIcon: true),
                DataCell(Text('0'), placeholder: true),
                DataCell(Text('0'), placeholder: true),
                DataCell(Text('#'), placeholder: true),
                DataCell(Text('')),
                DataCell(Icon(Icons.save)),
                DataCell(Icon(Icons.check_box_outline_blank)),
            ]),
        ),
      ),
          )),
    );
  }
 Container buildGroupedTable() {
    return Container(
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
              DataColumn(label: Text('1')),
              DataColumn(label: Text('2')),
              DataColumn(label: Text('3')),
              DataColumn(label: Text('4')),
              DataColumn(label: Text('5')),
              DataColumn(label: Text('6')),
              DataColumn(label: Text('7')),
              DataColumn(label: Text('8')),
              DataColumn(label: Text('9')),
              DataColumn(label: Text('OUT',style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('10')),
              DataColumn(label: Text('11')),
              DataColumn(label: Text('12')),
              DataColumn(label: Text('13')),
              DataColumn(label: Text('14')),
              DataColumn(label: Text('15')),
              DataColumn(label: Text('16')),
              DataColumn(label: Text('17')),
              DataColumn(label: Text('18')),
              DataColumn(label: Text('IN',style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('TOTAL',style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Season \nPoints')),
              DataColumn(label: Text('Earnings')),
              DataColumn(label: Text('Update')),
              DataColumn(label: Text('check')),
            ], 
            rows: List.generate(
            4,
            (index) => DataRow(
              cells: [
                DataCell(CircleAvatar(radius: 20, child: Icon(Icons.person),)),
                DataCell(Text('Full Name'), placeholder: true),
                DataCell(Text('#'), placeholder: true),
                DataCell(Text(''), showEditIcon: true),
                DataCell(Text(''), showEditIcon: true),
                DataCell(Text(''), showEditIcon: true),
                DataCell(Text(''), showEditIcon: true),
                DataCell(Text(''), showEditIcon: true),
                DataCell(Text(''), showEditIcon: true),
                DataCell(Text(''), showEditIcon: true),
                DataCell(Text(''), showEditIcon: true),
                DataCell(Text(''), showEditIcon: true),
                DataCell(Text('0'), placeholder: true),
                DataCell(Text(''), showEditIcon: true),
                DataCell(Text(''), showEditIcon: true),
                DataCell(Text(''), showEditIcon: true),
                DataCell(Text(''), showEditIcon: true),
                DataCell(Text(''), showEditIcon: true),
                DataCell(Text(''), showEditIcon: true),
                DataCell(Text(''), showEditIcon: true),
                DataCell(Text(''), showEditIcon: true),
                DataCell(Text(''), showEditIcon: true),
                DataCell(Text('0'), placeholder: true),
                DataCell(Text('0'), placeholder: true),
                DataCell(Text('#'), placeholder: true),
                DataCell(Text('')),
                DataCell(Icon(Icons.save)),
                DataCell(Icon(Icons.check_box_outline_blank)),
            ]),
        ),
      ),
          )),
    );
  }
}