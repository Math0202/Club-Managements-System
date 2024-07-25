import 'package:flutter/material.dart';

class Player {
  String rank;
  String playerName;
  int rounds;
  int earnings;

  Player({
    required this.rank,
    required this.playerName,
    required this.rounds,
    required this.earnings,
  });

  Map<String, dynamic> toMap() {
    return {
      'rank': rank,
      'playerName': playerName,
      'rounds': rounds,
      'earnings': earnings,
    };
  }

  factory Player.fromMap(Map<String, dynamic> map) {
    return Player(
      rank: map['rank'],
      playerName: map['playerName'],
      rounds: map['rounds'],
      earnings: map['earnings'],
    );
  }
}

class ClubLeaderBoardTable extends DataTableSource {
  final List<Player> players;

  ClubLeaderBoardTable(this.players);

  @override
  DataRow? getRow(int index) {
    if (index >= players.length) return null;
    final player = players[index];
    return DataRow(cells: [
      DataCell(Text(player.rank)),
      DataCell(Text(player.playerName)),
      DataCell(Text(player.rounds.toString())),
      DataCell(Text(player.earnings.toString())),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => players.length;

  @override
  int get selectedRowCount => 0;
}
