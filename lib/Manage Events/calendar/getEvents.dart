import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class GetEvents extends StatelessWidget {
  final String documentId;

  GetEvents({required this.documentId});

  @override
  Widget build(BuildContext context) {
    // Reference to the document
    DocumentReference eventRef = FirebaseFirestore.instance.collection('Events').doc(documentId);

    return FutureBuilder<DocumentSnapshot>(
      future: eventRef.get(),
      builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          Map<String, dynamic> data = snapshot.data!.data as Map<String, dynamic>;
          
          return Text('Club Name: ${data['Club Host']}'); // Or any loading indicator widget
        }

        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Text('Document does not exist');
        }

        // Data retrieved successfully
        Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
        // Use the data here, for example:
        print('Club Name: ${data['Club Host']}');
        return Text('Event Name: ${data['Club Host']}');
      },
    );
  }
}
