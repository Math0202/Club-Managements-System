import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SampleTablePage extends StatefulWidget {
  final String currentTappedTitle;
  const SampleTablePage({super.key, required this.currentTappedTitle});

  @override
  _SampleTablePageState createState() => _SampleTablePageState();
}

class _SampleTablePageState extends State<SampleTablePage> {
  late SampleDataSource _dataSource;
  String clubName = 'Windhoek';
  final currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _dataSource = SampleDataSource();
    fetchData();

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
        print('Document does not exist');
      }
    });
  }

  Future<void> fetchData() async {
    final querySnapshot = await FirebaseFirestore.instance.collection('Reservations')
        .where('Host', isEqualTo: clubName.split(" ").first)
        .get();
    
    final List<Map<String, dynamic>> reservations = [];
    
    for (var doc in querySnapshot.docs) {
      var data = doc.data();
      data['Time'] = (data['Time'] as Timestamp).toDate();
      
      // Fetch the player's full name using the 'User ID' from the 'users' collection
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(data['User ID']).get();
      if (userDoc.exists) {
        data['Player Name'] = userDoc.data()!['Full Name'];
      } else {
        data['Player Name'] = 'Unknown';
      }
      
      reservations.add(data);
    }
    
    setState(() {
      _dataSource.data = reservations;
      _dataSource.notifyListeners();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: buildSampleTable(),
      ),
    );
  }

  Widget buildSampleTable() {
    return PaginatedDataTable(
      header: Column(
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
        ],
      ),
      columns: const [
        DataColumn(label: Text('Player Name')),
        DataColumn(label: Text('RSVP Time')),
        DataColumn(label: Text('Gender')),
        DataColumn(label: Text('Handicap')),
        DataColumn(label: Text('Group')),
        DataColumn(label: Text('Color')),
        DataColumn(label: Text('Flight')),
        DataColumn(label: Text('Payment')),
      ],
      source: _dataSource,
      rowsPerPage: 5,
      availableRowsPerPage: const [5, 10, 20],
      onRowsPerPageChanged: (rowsPerPage) {},
    );
  }
}

class SampleDataSource extends DataTableSource {
  List<Map<String, dynamic>> data = [];

  @override
  DataRow? getRow(int index) {
    if (index >= data.length) return null;
    final row = data[index];
    return DataRow.byIndex(index: index, cells: [
      DataCell(Text(row['Player Name'] ?? '')),
      DataCell(Text(DateFormat('yyyy-MM-dd HH:mm').format(row['Time']))),
      DataCell(Text(row['Gender'] ?? '')),
      DataCell(Text(row['Handicap']?.toString() ?? '')),
      DataCell(Text(row['Group'] ?? '')),
      DataCell(Text(row['Color'] ?? '')),
      DataCell(Text(row['Flight'] ?? '')),
      DataCell(Text(row['Payment'] ? 'Yes' : 'No')),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => data.length;

  @override
  int get selectedRowCount => 0;

  
}
