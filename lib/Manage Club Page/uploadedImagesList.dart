import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class UploadedImagesList extends StatefulWidget {
  final String clubName;

  UploadedImagesList({required this.clubName});

  @override
  _UploadedImagesListState createState() => _UploadedImagesListState();
}

class _UploadedImagesListState extends State<UploadedImagesList> {
  User? user = FirebaseAuth.instance.currentUser;
  TextEditingController commentController = TextEditingController();

  void toggleLike(DocumentSnapshot doc) async {
    DocumentReference docRef = doc.reference;
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user?.uid).get();
    String userName = userDoc['Full Name'];

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot freshSnap = await transaction.get(docRef);
      List likes = freshSnap['likes'] ?? [];
      if (likes.contains(userName)) {
        likes.remove(userName);
      } else {
        likes.add(userName);
      }
      transaction.update(docRef, {'likes': likes});
    });
  }

  void addComment(DocumentSnapshot doc) async {
    DocumentReference docRef = doc.reference;
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user?.uid).get();
    String userName = userDoc['Full Name'];
    String profilePicture = userDoc['Profile Picture'];
    String homeClub = userDoc['Home club'];

    if (commentController.text.isNotEmpty) {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot freshSnap = await transaction.get(docRef);
        List comments = freshSnap['comments'] ?? [];
        comments.add({
          'userName': userName,
          'profilePicture': profilePicture,
          'homeClub': homeClub,
          'comment': commentController.text,
          'commentedAt': Timestamp.now(),
        });
        transaction.update(docRef, {'comments': comments});
      });
      commentController.clear();
    }
  }

void showComments(DocumentSnapshot doc) {
  showModalBottomSheet(
    context: context,
    builder: (context) {
      List comments = (doc.data() as Map<String, dynamic>?)?['comments'] ?? [];

      return Column(
        children: [
          Expanded(
            child: ListView(
              children: comments.isEmpty
                  ? [Text('No comments yet')]
                  : comments.map<Widget>((comment) {
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(comment['profilePicture']),
                        ),
                        title: Text(comment['userName']),
                        subtitle: Text(comment['comment']),
                        trailing: Text(comment['homeClub']),
                      );
                    }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: commentController,
                    decoration: InputDecoration(hintText: 'Drop a comment'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    addComment(doc);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ],
      );
    },
  );
}

void showLikes(DocumentSnapshot doc) {
  showModalBottomSheet(
    context: context,
    builder: (context) {
      List likes = (doc.data() as Map<String, dynamic>?)?['likes'] ?? [];

      return ListView(
        children: likes.isEmpty
            ? [Text('No likes yet')]
            : likes.map<Widget>((like) {
                return ListTile(
                  title: Text(like),
                );
              }).toList(),
      );
    },
  );
}


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
            List likes = (doc.data() as Map<String, dynamic>?)?['likes'] ?? [];
            List comments = (doc.data() as Map<String, dynamic>?)?['comments'] ?? [];
            int likeCount = likes.length;
            int commentCount = comments.length;

            return Container(
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
                  Text('${uploadedAt.toLocal()}', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w100)),
                  if (note != null && note.isNotEmpty)
                    Text('$note', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.grey[800])),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.grey[300],
                              border: Border.all(
                                color: Colors.white,
                                width: 1.0,
                              ),
                            ),
                            child: Icon(Icons.share, size: 20, color: Colors.blue),
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
                              color: Colors.transparent,
                              border: Border.all(
                                color: Colors.white,
                                width: 1.0,
                              ),
                            ),
                            child: Icon(Icons.message, size: 20, color: Colors.blue),
                          ),
                          TextButton(
                            onPressed: () => showComments(doc),
                            child: Text("Comment ($commentCount)"),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.transparent,
                              border: Border.all(
                                color: Colors.white,
                                width: 1.0,
                              ),
                            ),
                            child: Icon(Icons.thumb_up_outlined, size: 20, color: Colors.blue),
                          ),
                          TextButton(
                            onPressed: () => showLikes(doc),
                            child: Text("Like ($likeCount)"),
                          ),
                        ],
                      ),
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
