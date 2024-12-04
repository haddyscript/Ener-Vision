import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_project/PreCode/chats_page.dart';

class FAQsPage extends StatefulWidget {
  @override
  _FAQsPageState createState() => _FAQsPageState();
}

class _FAQsPageState extends State<FAQsPage> {
  List<Map<String, String>> _faqData = [];
  List<bool> _isOpen = [];
  String _searchQuery = "";
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchFAQs();
  }

  Future<void> _fetchFAQs() async {
    try {
      final response = await http.get(Uri.parse('http://10.0.2.2:8080/faqs'));

      if (response.statusCode == 200) {
        final List<dynamic> faqs = json.decode(response.body);
        setState(() {
          _faqData = faqs
              .map<Map<String, String>>((faq) => {
                    'question': faq['question'] as String,
                    'answer': faq['answer'] as String,
                  })
              .toList();

          _isOpen = List.generate(_faqData.length, (index) => false);
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
        throw Exception('Failed to load FAQs');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
      print(e);
    }
  }

  List<Map<String, String>> _getFilteredFAQs() {
    if (_searchQuery.isEmpty) {
      return _faqData.take(6).toList();
    } else {
      return _faqData
          .where((faq) => faq["question"]!
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()))
          .toList();
    }
  }

  Widget _buildFAQTile(int index, String question, String answer) {
    return Card(
      child: Column(
        children: [
          ListTile(
            title: Text(
              question,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontFamily: 'Montserrat',
              ),
            ),
            trailing: IconButton(
              icon: Icon(
                _isOpen[index] ? Icons.remove : Icons.add,
              ),
              onPressed: () {
                setState(() {
                  _isOpen[index] = !_isOpen[index];
                });
              },
            ),
          ),
          if (_isOpen[index])
            Padding(
              padding: const EdgeInsets.only(
                  bottom: 12.0, right: 12.0, left: 12.0, top: 0),
              child: Text(
                answer,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[700],
                  fontFamily: 'Montserrat',
                ),
                textAlign: TextAlign.justify,
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, String>> filteredFAQs = _getFilteredFAQs();

    return Scaffold(
      appBar: _buildAppBar(),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator()) // Show loading spinner
          : _hasError
              ? const Center(
                  child: Text(
                      'Failed to load FAQs. Please try again later.')) // Handle error state
              : Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Text(
                            'Frequently Asked Questions (FAQs)',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                fontFamily: 'Montserrat'),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Everything you need to know about EnerVision',
                            style: TextStyle(
                                color: Colors.grey, fontFamily: 'Montserrat'),
                          ),
                          const SizedBox(height: 14),
                          TextField(
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.search),
                              hintText: 'Search Help',
                              hintStyle:
                                  const TextStyle(fontFamily: 'Montserrat'),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onChanged: (query) {
                              setState(() {
                                _searchQuery = query;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: filteredFAQs.isNotEmpty
                                ? filteredFAQs.asMap().entries.map((entry) {
                                    int index = entry.key;
                                    var faq = entry.value;
                                    return _buildFAQTile(index,
                                        faq["question"]!, faq["answer"]!);
                                  }).toList()
                                : [const Text('No matching FAQs found')],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Text(
                            'Still stuck? Help is a mail away',
                            style: TextStyle(
                                fontSize: 14,
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 15.0),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (context) => HelpChatPage()),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00C29A),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 100.0, vertical: 12.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Text(
                              'Send a Message',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: 'Montserrat',
                                  color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.bolt), label: 'Your Energy'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Community'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'App Settings'),
        ],
      ),
    );
  }

  PreferredSize _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(100.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: _buildBoxDecoration(),
        child: SafeArea(
          child: Column(
            children: [
              _buildTopBar(),
            ],
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildBoxDecoration() {
    return const BoxDecoration(
      color: Color(0xFF02A676),
    );
  }

  Widget _buildTopBar() {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 20.0, right: 5.0),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop(); // Navigate back
                  },
                  child: const Icon(
                    Icons.arrow_back,
                    size: 30.0,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 100.0),
                const Text(
                  'Help Desk',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Montserrat',
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: CircleAvatar(
            radius: 30,
            backgroundImage: Image.asset(
              'assets/profile (2).png',
              width: 50.0,
              height: 50.0,
            ).image,
          ),
        ),
      ],
    );
  }
}
