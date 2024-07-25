// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:mime/mime.dart';
import 'package:ongolf_tech_mamagement_system/community/chattingServices/message.dart';
import 'package:video_player/video_player.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:chewie/chewie.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

class ChatService extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String getGroupKey(DateTime timestamp) {
  return DateFormat('yyyy-MM-dd').format(timestamp);
}

  Future<void> sendMessage(String receiverId, {String? message, String? fileUrl, String? groupName}) async {
    final currentUserId = _firebaseAuth.currentUser!.uid;
    final Timestamp timestamp = Timestamp.now();

    if (message != null || fileUrl != null) {
      Message newMessage = Message(
        senderId: currentUserId,
        receiverId: receiverId,
        message: message ?? '',
        timestamp: timestamp,
        fileUrl: fileUrl,
      );
        // For group chats
      if  (groupName != null) {
              String chatRoomId = groupName;
              await _firestore
                  .collection('chat_rooms')
                  .doc(chatRoomId)
                  .collection('messages')
                  .add(newMessage.toMap());
      } else {
        // For one-to-one chats
        List<String> ids = [currentUserId, receiverId];
        ids.sort();
        String chatRoomId = ids.join("-");

        await _firestore
            .collection('chat_rooms')
            .doc(chatRoomId)
            .collection('messages')
            .add(newMessage.toMap());
      }}

      //print('Message sent: $message');
    }
  

  Stream<QuerySnapshot> getMessages(String currentUserId, String receivedUserID, String? groupName) {
    if ( groupName != null ) {
      String chatRoomId = groupName;
      return _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timeStamp', descending: false)
        .snapshots();
  
    }else{
     List<String> ids = [currentUserId, receivedUserID];
    ids.sort();
    String chatRoomId = ids.join("-");
    return _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timeStamp', descending: false)
        .snapshots();
  }}

    
  
  }



class ChatPage extends StatefulWidget {
  final String receivedUserID;
  final String receivedUserFullName;
  final bool isGroupChat;
  final String ? clubName;
  final  String userImageUrl;

  const ChatPage({
    super.key, 
    required this.userImageUrl,
    required this.receivedUserID, 
    required this.receivedUserFullName, 
    this.clubName, required this.isGroupChat,
  
    });

  @override
  // ignore: library_private_types_in_public_api
  _ChatPageState createState() => _ChatPageState();
}
class _ChatPageState extends State<ChatPage> with AutomaticKeepAliveClientMixin<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  late ScrollController scrollController;
  String? _fileUrl;

    late Future<String> _userImageUrlFuture;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _userImageUrlFuture = Future.value(widget.userImageUrl);
    scrollController = ScrollController(); // Initialize the scroll controller
    scrollController.addListener(() {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
        // ignore: avoid_print
        print("At the bottom");
      }
    });
  }

  void sendMessage() async {
    if (_messageController.text.isEmpty && _fileUrl != null) {
      // Clear the file URL and dispose of the file
      setState(() {
        _fileUrl = null;
      });
    } else if (_messageController.text.isNotEmpty || _fileUrl != null) {
      // Show a circular progress indicator
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Sending message...'),
              ],
            ),
          );
        },
      );

        await _chatService.sendMessage(
        widget.receivedUserID,
        message: _messageController.text,
        fileUrl: _fileUrl,
        groupName: widget.clubName
      );
      
      
      _messageController.clear();
      setState(() {
        _fileUrl = null;
      });

      Navigator.of(context).pop();
    }
  }

  void pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      File file = File(result.files.single.path!);

      // Show a progress indicator while uploading
      showDialog(
        // ignore: use_build_context_synchronously
        context: context,
        builder: (BuildContext context) {
          return const AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Uploading file...'),
              ],
            ),
          );
        },
      );

      // Storing the file in Firebase Storage and getting the download URL
      Reference ref = FirebaseStorage.instance.ref().child(result.files.single.name);
      UploadTask uploadTask = ref.putFile(file);
      TaskSnapshot taskSnapshot = await uploadTask;
      String fileUrl = await taskSnapshot.ref.getDownloadURL();

      setState(() {
        _fileUrl = fileUrl;
        _messageController.text = result.files.single.name;
      });

      // ignore: use_build_context_synchronously
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Expanded(
      child: Scaffold(
        backgroundColor: Colors.green.shade100,
        appBar: AppBar(
          backgroundColor: Colors.green.shade100,
         title:  Row(
          children: [
            FutureBuilder<String>(
              future: _userImageUrlFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.grey, // Placeholder color
                  );
                }
                if (snapshot.hasError) {
                  return const Icon(Icons.error); // Error icon
                }
                return CircleAvatar(
                  radius: 25,
                  backgroundImage: NetworkImage(snapshot.data!),
                );
              },
            ),
            const SizedBox(width: 8),
            Text(widget.receivedUserFullName),
          ],
        ),
       centerTitle: true,
      ),
        body: PageStorage(
          bucket: PageStorageBucket(),
          key: const PageStorageKey('chatPageKey'), // Unique key for the ChatPage
          child: Column(
            children: [
              Expanded(
                child: _buildMessagesList(),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.attach_file),
                    onPressed: pickFile,
                  ),
                  Expanded(
                    child: TextField(
                      maxLines: null,
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Enter message or select a file',
                        hintStyle: TextStyle(color: Colors.grey[500]),
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blueGrey),
                        ),
                        fillColor: Colors.grey.shade200,
                        filled: true,
                      ),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      IconButton(
                        onPressed: sendMessage,
                        icon: const Icon(
                          Icons.send,
                          size: 30,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10,)
            ],
          ),
        ),
      ),
    );
  }

  // Build messages list
  Widget _buildMessagesList() {
    return StreamBuilder(
      stream: _chatService.getMessages(widget.receivedUserID, _firebaseAuth.currentUser!.uid, widget.clubName),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error ${snapshot.error}');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: Text("loading..."));
        }

        // Scroll to the bottom when the snapshot is updated
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            scrollController.animateTo(scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
          }
        });

        final messages = snapshot.data!.docs.map((document) => _buildMessagesItem(document)).toList();
        return ListView.builder(
          controller: scrollController, // Attach a scroll controller
          itemCount: messages.length,
          itemBuilder: (context, index) {
            return messages[index];
          },
        );
      },
    );
  }

  Widget _buildMessagesItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    var alignment = (data['senderId'] == _firebaseAuth.currentUser!.uid)
        ? Alignment.centerRight
        : Alignment.centerLeft;

    DateTime timestamp = data['timeStamp'].toDate();
    String formattedTime = DateFormat('HH:mm').format(timestamp);
    String formattedDate = DateFormat('yyyy-MM-dd').format(timestamp);

    var messageBubble = Align(
      alignment: alignment,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        margin: const EdgeInsets.only(bottom: 4, left: 8, right: 8, top: 4),
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
        decoration: BoxDecoration(
          color: (data['senderId'] == _firebaseAuth.currentUser!.uid) ? Colors.green[200] : Colors.green.shade400,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
            bottomLeft: (alignment == Alignment.centerRight) ? const Radius.circular(12) : Radius.zero,
            bottomRight: (alignment == Alignment.centerLeft) ? const Radius.circular(12) : Radius.zero,
          ),
        ),
        child: SizedBox(
          child: Column(
            children: [
              
              _buildMessageContent(data),
              Text(formattedDate,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
                fontSize: 10
              ),
              ),
              Text('--- $formattedTime ---',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
                fontSize: 10
              ),
              )
            ],
          ),
        ),
      ),
    );
    return messageBubble;
  }

  Widget _buildMessageContent(Map<String, dynamic> data) {
  VideoPlayerController? videoPlayerController;
  ChewieController? chewieController;

  if (data['fileUrl'] != null) {
    String fileName = Uri.parse(data['fileUrl']).path.split('/').last;
    String? mimeType = lookupMimeType(fileName, headerBytes: null);
    if (mimeType != null) {
      if (mimeType.startsWith('image/')) {
        // Display the image within the app
       // print('Displaying image...');
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () {
                // Show the image in a full-screen dialog
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return Scaffold(
                      backgroundColor: Colors.grey[300],
                      appBar: AppBar(backgroundColor: Colors.grey[300],
                      ),
            body:  Center(
              child: InteractiveViewer(
                panEnabled: true,
                 scaleEnabled : true,
                boundaryMargin: const EdgeInsets.all(20.0),
                
                minScale: 1,
                maxScale: 20.0,
                child: Image.network(
                   data['fileUrl'],
                  fit: BoxFit.contain,
                ),
              ),
            ),
          );

                  },
                );
              },
              child: Stack(
                children: [
                  Image.network(
                    data['fileUrl'],
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(10)
                      ),
                      padding: const EdgeInsets.all(4),
                      
                      child: IconButton(
                        icon: const Icon(
                          Icons.save,
                          color: Colors.white,
                        ),
                        onPressed: () async {
                          final status = await Permission.storage.request();
                          if (status.isGranted) {
                            final imageId = DateTime.now().millisecondsSinceEpoch.toString();
                            final imageDirectory = await getApplicationDocumentsDirectory();
                            final imagePath = '${imageDirectory.path}/$imageId.jpg';
                            await ImageGallerySaver.saveImage(data['fileUrl'], quality: 80, name: imageId);
                            // ignore: use_build_context_synchronously
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Image saved to gallery')));
                          } else {
                            // ignore: use_build_context_synchronously
                            ScaffoldMessenger.of(context).showSnackBar( const SnackBar(content: Text('Permission denied')));
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (data['message'] != null && data['message'].isNotEmpty) const SizedBox(height: 8),
            if (data['message'] != null && data['message'].isNotEmpty) Text(data['message'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500), ),
          ],
        );
      } else if (mimeType.startsWith('video/')) {
          // Display the video within the app
       return Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    InkWell(
      onTap: () {
        // Show the video in a full-screen dialog
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return Dialog(
              child: AspectRatio(
                aspectRatio: 1, // Adjust the aspect ratio as needed
                child: Chewie(
                  controller: chewieController!,
                ),
              ),
            );
          },
        );
      },
      child: AspectRatio(
        aspectRatio: 1, // Adjust the aspect ratio as needed
        child: Chewie(
          controller: chewieController = ChewieController(
            // ignore: deprecated_member_use
            videoPlayerController: videoPlayerController = VideoPlayerController.network(data['fileUrl']),
            looping: false,
          ),
        ),
      ),
    ),
    if (data['message'] != null && data['message'].isNotEmpty) const SizedBox(height: 8),
    if (data['message'] != null && data['message'].isNotEmpty) Text(data['message'], 
    style:const TextStyle(fontSize: 16, fontWeight: FontWeight.w500), ),
          ],
         );
        }
      }

      // Display a generic message for other file types
     // print('Displaying generic file...');
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              var fileUrl = data['fileUrl'];
              launchUrl(Uri.parse(fileUrl));
            },
            child: Container(
              decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10)
                      ),
              child: const Row(
                children: [
                  Icon(Icons.file_open, size: 70,),
                  Spacer(),
                  Icon(Icons.file_download, size: 40,),
                ],
              ),
            ),
          ),
          if (data['message'] != null && data['message'].isNotEmpty) const SizedBox(height: 8),
          if (data['message'] != null && data['message'].isNotEmpty) Text(data['message'],style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500), ),
        ],
      );
    } else {
      return Text(
        data['message'],
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500), 
      );
    }
  }
  
  getApplicationDocumentsDirectory() {}
}
