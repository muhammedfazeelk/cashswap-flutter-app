import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ChatScreen extends StatefulWidget {
  final String roomId;

  const ChatScreen({
    super.key,
    required this.roomId,
  });

  @override
  State<ChatScreen> createState() =>
      _ChatScreenState();
}

class _ChatScreenState
    extends State<ChatScreen> {

  late WebSocketChannel channel;

  final TextEditingController
      messageController =
      TextEditingController();

  final List<Map<String, dynamic>>
      messages = [];

  final String wsBaseUrl = kIsWeb
      ? 'ws://127.0.0.1:8000'
      : 'ws://192.168.1.5:8000';

  @override
  void initState() {
    super.initState();
    connectSocket();
  }

  void connectSocket() {
    channel = WebSocketChannel.connect(
      Uri.parse(
        '$wsBaseUrl/ws/${widget.roomId}',
      ),
    );

    channel.stream.listen(
      (message) {
        setState(() {
          messages.add(
            jsonDecode(message),
          );
        });
      },
      onError: (e) {
        print(e);
      },
    );
  }

  void sendMessage() {
    if (messageController.text
        .trim()
        .isEmpty) {
      return;
    }

    final uid =
        FirebaseAuth.instance
            .currentUser!
            .uid;

    channel.sink.add(
      jsonEncode(
        {
          "sender": uid,
          "message":
              messageController.text,
        },
      ),
    );

    messageController.clear();
  }

  @override
  void dispose() {
    channel.sink.close();
    messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(
      BuildContext context) {

    return Scaffold(
      backgroundColor:
          const Color(
              0xFFF8FAFC),

      appBar: AppBar(
        elevation: 0,
        backgroundColor:
            Colors.white,

        title: const Text(
          "Secure Chat",
          style: TextStyle(
            color:
                Color(0xFF0F172A),
            fontWeight:
                FontWeight.bold,
          ),
        ),
      ),

      body: Column(
        children: [

          Expanded(

            child:
                messages.isEmpty

                    ? const Center(
                        child: Text(
                          "Start chatting securely",
                          style: TextStyle(
                            fontSize: 16,
                            color:
                                Colors.grey,
                          ),
                        ),
                      )

                    : ListView.builder(

                        padding:
                            const EdgeInsets
                                .all(16),

                        itemCount:
                            messages.length,

                        itemBuilder:
                            (context,
                                index) {

                          final myUid =
                              FirebaseAuth
                                  .instance
                                  .currentUser!
                                  .uid;

                          final isMine =
                              messages[index]
                                      [
                                      "sender"] ==
                                  myUid;

                          return Align(

                            alignment:
                                isMine

                                    ? Alignment
                                        .centerRight

                                    : Alignment
                                        .centerLeft,

                            child:
                                Container(

                              margin:
                                  const EdgeInsets
                                      .only(
                                bottom:
                                    12,
                              ),

                              padding:
                                  const EdgeInsets
                                      .symmetric(
                                horizontal:
                                    18,
                                vertical:
                                    14,
                              ),

                              decoration:
                                  BoxDecoration(

                                color:
                                    isMine

                                        ? const Color(
                                            0xFF2563EB)

                                        : Colors
                                            .grey
                                            .shade300,

                                borderRadius:
                                    BorderRadius
                                        .circular(
                                            18),
                              ),

                              child:
                                  Text(

                                messages[
                                        index]
                                    [
                                    "message"],

                                style:
                                    TextStyle(

                                  color:
                                      isMine

                                          ? Colors
                                              .white

                                          : Colors
                                              .black,

                                  fontSize:
                                      16,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),

          Container(

            padding:
                const EdgeInsets
                    .all(16),

            decoration:
                const BoxDecoration(
              color: Colors.white,
            ),

            child: Row(

              children: [

                Expanded(

                  child:
                      TextField(

                    controller:
                        messageController,

                    decoration:
                        InputDecoration(

                      hintText:
                          "Type message...",

                      filled:
                          true,

                      fillColor:
                          const Color(
                              0xFFF1F5F9),

                      border:
                          OutlineInputBorder(

                        borderRadius:
                            BorderRadius
                                .circular(
                                    18),

                        borderSide:
                            BorderSide
                                .none,
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                  width: 10,
                ),

                CircleAvatar(

                  radius: 28,

                  backgroundColor:
                      const Color(
                          0xFF2563EB),

                  child:
                      IconButton(

                    onPressed:
                        sendMessage,

                    icon:
                        const Icon(
                      Icons.send,
                      color:
                          Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}