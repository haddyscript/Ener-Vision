import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_project/CommonWidgets/appliance_container/snack_bar.dart';
import 'package:supabase_project/CommonWidgets/controllers/app_controllers.dart';
import 'package:supabase_project/ConstantTexts/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';

late WebSocketChannel _channel;

class HelpChatPage extends StatefulWidget {
  @override
  _HelpChatPageState createState() => _HelpChatPageState();
}

class _HelpChatPageState extends State<HelpChatPage> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> _messages = [];
  final String apiUrl = 'http://10.0.2.2:8080';
  bool isUserLoaded = false;
  String? userId;
  AppControllers controller = AppControllers();

  @override
  void initState() {
    super.initState();
    _loadUserId();
    _fetchMessages();

    // Set up WebSocket
    _channel = WebSocketChannel.connect(Uri.parse('ws://10.0.2.2:8080/ws'));

    // Listen for new messages
    _channel.stream.listen((data) {
      final Map<String, dynamic> newMessage = jsonDecode(data);

      // Check if the message is for this user
      if (newMessage['userId'] == userId || newMessage['userId'] == 'admin') {
        setState(() {
          _messages.add({
            'userId': newMessage['userId'],
            'message': newMessage['message'],
            'timestamp': DateTime.parse(newMessage['timestamp']),
          });

          // Sort messages to maintain the order
          _messages.sort((a, b) => a['timestamp'].compareTo(b['timestamp']));
        });
      }
    });
  }

  @override
  void dispose() {
    _channel.sink.close();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId');
    setState(() {
      isUserLoaded = userId != null;
    });
  }

  Future<void> _fetchMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    try {
      final response = await http.get(Uri.parse('$apiUrl/chats'));
      if (response.statusCode == 200) {
        final List<dynamic> groupedChats = jsonDecode(response.body);
        List<Map<String, dynamic>> allMessages = [];

        // Find the group for the current user
        final userChats = groupedChats.firstWhere(
          (group) => group['_id'] == userId,
          orElse: () => null,
        );

        if (userChats != null) {
          // Add user's messages
          for (var chat in userChats['chats']) {
            for (var message in chat['messages']) {
              allMessages.add({
                'userId': userId,
                'message': message['message'],
                'timestamp': DateTime.parse(message['timestamp']),
              });
            }

            // Add admin replies
            for (var reply in chat['adminReplies']) {
              allMessages.add({
                'userId': 'admin',
                'message': reply['message'],
                'timestamp': DateTime.parse(reply['timestamp']),
              });
            }
          }
        }

        // Sort messages by timestamp
        allMessages.sort((a, b) => a['timestamp'].compareTo(b['timestamp']));

        setState(() {
          _messages = allMessages;
        });
      } else {
        print('Failed to load messages: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching messages: $error');
    }
  }

  Future<void> _sendMessage() async {
    if (_controller.text.trim().isEmpty || userId == null) return;

    final String message = _controller.text;
    setState(() {
      _messages.add({'userId': userId, 'message': message});
    });

    try {
      final response = await http.post(
        Uri.parse('$apiUrl/chats'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user': userId, 'message': message}),
      );

      if (response.statusCode == 201) {
        _controller.clear();
      } else {
        print(
            'Failed to send message: ${response.statusCode} - ${response.body}');
      }
    } catch (error) {
      print('Error sending message: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF02A676),
        elevation: 0,
        toolbarHeight: 200,
        automaticallyImplyLeading: false,
        flexibleSpace: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(right: 30.0, left: 15.0, top: 30.0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    size: 35,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                const Spacer(),
                const CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage('assets/profile (2).png'),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: isUserLoaded
                ? _messages.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset('assets/dialogImage.png'),
                            const SizedBox(height: 20.0),
                            const Text(
                              'How can I help you today?',
                              style: TextStyle(
                                fontSize: 20,
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          bool isAdminMessage =
                              _messages[index]['userId'] == 'admin';
                          return Align(
                            alignment: isAdminMessage
                                ? Alignment.centerLeft
                                : Alignment.centerRight,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 14.0),
                              margin: const EdgeInsets.only(bottom: 10.0),
                              decoration: BoxDecoration(
                                color: isAdminMessage
                                    ? Colors.grey[300]
                                    : Colors.teal[100],
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: Text(
                                _messages[index]['message'],
                                style: const TextStyle(
                                    fontSize: 14.0, fontFamily: 'Montserrat'),
                              ),
                            ),
                          );
                        },
                      )
                : Center(child: CircularProgressIndicator()),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Send a message...',
                hintStyle: TextStyle(
                    fontFamily: 'Montserrat',
                    color: Colors.grey[700],
                    fontSize: 12.0),
                prefixIcon: const Icon(Icons.message),
                suffixIcon: TextButton(
                  onPressed: _sendMessage,
                  child: const Icon(
                    Icons.send_rounded,
                    color: AppColors.primaryColor,
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
