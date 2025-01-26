// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api, prefer_const_constructors

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../constants.dart';

final _firestore = FirebaseFirestore.instance;
User? loggedInUser;

class ChatScreen extends StatefulWidget {
  static const String id = "chat_screen";

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _auth = FirebaseAuth.instance;
  TextEditingController textController = TextEditingController();

  String messageType = 'text';
  String fileName = '';
  String messageText = '';

  void getCurrentUser() {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
        print(loggedInUser?.email);
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                //getMessageStreams();
                _auth.signOut();
                Navigator.pop(context);
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Color(0xFF006AFF),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MessageStream(),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: messageType == 'image'
                        ? Text(
                            '$fileName',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          )
                        : TextField(
                            onChanged: (value) {
                              messageText = value;
                            },
                            controller: textController,
                            decoration: kMessageTextFieldDecoration,
                          ),
                  ),
                  IconButton(
                      onPressed: _selectPicker, icon: Icon(Icons.attach_file)),
                  TextButton(
                    style: TextButton.styleFrom(
                      textStyle: kSendButtonTextStyle,
                      padding: EdgeInsets.only(right: 15, left: 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      minimumSize: Size(0, 0),
                    ),
                    onPressed: () {
                      textController.clear();
                      _firestore.collection('messages').add({
                        'type': messageType,
                        'text': messageText,
                        'sender': loggedInUser?.email,
                        'timestamp': FieldValue.serverTimestamp(),
                      });

                      setState(() {
                        messageType = 'text';
                        fileName = '';
                      });
                    },
                    child: const Text('Send'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectPicker() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      // Read the image file as bytes
      final List<int> imageBytes = await image.readAsBytes();

      // Convert the image bytes to a Base64 string
      final String base64Image = base64Encode(imageBytes);

      print("Base64 Image: $base64Image");
      
      textController.clear();

      setState(() {
        messageText = base64Image;
        messageType = 'image';
        fileName = image.name;
      });

      // You can now use the base64Image string as needed
    } else {
      print("No image selected.");
    }
  }
}

class MessageStream extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream:
            _firestore.collection('messages').orderBy('timestamp').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final messages = snapshot.data!.docs.reversed;
            List<MessageBubble> messageBubbles = [];
            for (var message in messages) {
              final messageText = message['text'];
              final messageSender = message['sender'];
              final currentUser = loggedInUser?.email;

              final messageBubble = MessageBubble(
                text: messageText,
                sender: messageSender,
                isMyMessage: currentUser == messageSender,
                type: message['type'],
              );
              messageBubbles.add(messageBubble);
            }
            return Expanded(
              child: ListView(
                reverse: true,
                padding: EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 20,
                ),
                children: messageBubbles,
              ),
            );
          } else {
            return Center(
              child: SizedBox(
                height: 40.0,
                child: CircularProgressIndicator(
                  backgroundColor: Colors.lightBlueAccent,
                ),
              ),
            );
          }
        });
  }
}

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    required this.text,
    required this.sender,
    this.isMyMessage = false,
    this.type = 'text',
  });

  final String text;
  final String sender;
  final bool isMyMessage;
  final String type;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment:
            isMyMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            sender,
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
          Material(
            color: isMyMessage ? Color(0xFF006AFF) : Colors.pinkAccent,
            borderRadius: isMyMessage
                ? BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(0))
                : BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                    topLeft: Radius.circular(0),
                    topRight: Radius.circular(30)),
            elevation: 5.0,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 10,
              ),
              child: type == 'text'
                  ? Text(
                      text,
                      style: TextStyle(fontSize: 15, color: Colors.white),
                    )
                  : Image.memory(base64Decode(text)),
            ),
          ),
        ],
      ),
    );
  }
}
