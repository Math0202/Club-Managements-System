import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:ongolf_tech_mamagement_system/Manage%20Club%20Page/clubs_page.dart';

class buildImagesForClubPage extends StatelessWidget {
  const buildImagesForClubPage({
    super.key,
    required this.widget,
  });

  final ClubsPage widget;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('Notice Board Images').where('clubName', isEqualTo: widget.clubName).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return CircularProgressIndicator();
          }
    
          List<DocumentSnapshot> images = snapshot.data!.docs;
          return Column(
            children: images.map((doc) {
              String imageUrl = doc['imageUrl'];
              String? note = doc['note'];
              DateTime uploadedAt = doc['uploadedAt'].toDate();
    
              return  Container(
           color: Colors.grey[300],
            padding: EdgeInsets.all(4),
            margin: EdgeInsets.all(2),
                child: Column(
                  children: [
                    InkWell(
                      onTap: () async {
                        bool confirmed = await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Delete Image'),
                            content: Text('Are you sure you want to delete this image?'),
                            actions: [
    TextButton(
      onPressed: () => Navigator.of(context).pop(false),
      child: Text('Cancel'),
    ),
    TextButton(
      onPressed: () => Navigator.of(context).pop(true),
      child: Text('Delete'),
    ),
                            ],
                          ),
                        );
                        if (confirmed) {
                          await FirebaseFirestore.instance.runTransaction((transaction) async {
                            transaction.delete(doc.reference);
                            await FirebaseStorage.instance.refFromURL(imageUrl).delete();
                          });
                        }
                      },
                      child: Image.network(imageUrl),
                    ),
                    Text('${uploadedAt.toLocal()}',style: TextStyle(fontSize: 28, fontWeight: FontWeight.w100 ),),
                    if (note != null && note.isNotEmpty)
                      Text('$note', style: TextStyle(fontWeight: FontWeight.w700,color: Colors.grey[800]),),
                   const SizedBox(
                    height: 6,
                   ),
                    
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(8),
    color: Colors.grey[300], // Makes the box itself transparent
    border: Border.all(
      color: Colors.white, // Sets the border color to white
      width: 1.0, // Sets the border width
    ),
                            ),
                            child: Icon(Icons.share,size: 20,
    color: Colors.blue),
                          ),
                          Text("Share (3)")
                        ],
                      ),
                      Column(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(8),
    color: Colors.transparent, // Makes the box itself transparent
    border: Border.all(
      color: Colors.white, // Sets the border color to white
      width: 1.0, // Sets the border width
    ),
                            ),
                            child: Icon(
    Icons.message,size: 20,
    color: Colors.blue),
                          ),
                          Text("Comment (8)")
                        ],
                      ),
                      Column(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(8),
    color: Colors.transparent, // Makes the box itself transparent
    border: Border.all(
      color: Colors.white, // Sets the border color to white
      width: 1.0, // Sets the border width
    ),
                            ),
                            child: Icon(Icons.thumb_up_outlined, size: 20,
    color: Colors.blue),
                          ),
                          Text("Like (37)")
                        ],
                      )
                      
                
                    ],
                  ),
                  Divider(),
                  ],
                ),
              );
            }).toList(),
          );
        },
      );
  }
}
