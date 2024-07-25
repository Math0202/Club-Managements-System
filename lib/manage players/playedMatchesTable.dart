import 'dart:math';
import 'package:flutter/material.dart';

class MatchesPlayedTable extends DataTableSource{
  final List<Map<String, dynamic>> data1 = List.generate(
    20, 
    (index) => {
      "Club": "Windhoek Golf course",
      "Date": '11 Dec 2024',
      "Stokes": Random().nextInt(98),
      "Formate": 'Stable ford',
      "Approved ": Random().nextBool(),

    });
  @override
  DataRow? getRow(int index) {
    return DataRow(cells: [
      DataCell(Text(data1[index]['Club'].toString())),
      DataCell(Text(data1[index]['Date'].toString())),
      DataCell(Text(data1[index]['Strokes'].toString())),
      DataCell(Text(data1[index]['Approved'].toString())),
    ]);
  }

  @override
  // TODO: implement isRowCountApproximate
  bool get isRowCountApproximate => false;

  @override
  // TODO: implement rowCount
  int get rowCount => data1.length;

  @override
  // TODO: implement selectedRowCount
  int get selectedRowCount => 0;

}