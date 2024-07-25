import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String senderId;
  final String receiverId;
  final String message;
  final Timestamp timestamp;
  String? fileUrl;

  Message({
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.timestamp, 
    this.fileUrl,
  });

    factory Message.fromMap(Map<String, dynamic> data) {
    return Message(
      senderId: data['senderId'],
      receiverId: data['receiverId'],
      message: data['message'],
      timestamp: data['timestamp'],
    );
  }

  //covert info into map
  Map<String, dynamic> toMap(){
    return{
      'senderId': senderId,
      'receiverId': receiverId,
      'message': message,
      'timeStamp': timestamp,
      'fileUrl': fileUrl,
    };
  }
  Message copyWith({
String? senderId,
String? receiverId,
String? message,
Timestamp? timestamp,
String? fileUrl,
}) {
return Message(
senderId: senderId ?? this.senderId,
receiverId: receiverId ?? this.receiverId,
message: message ?? this.message,
timestamp: timestamp ?? this.timestamp,
fileUrl: fileUrl ?? this.fileUrl,
);
}
}