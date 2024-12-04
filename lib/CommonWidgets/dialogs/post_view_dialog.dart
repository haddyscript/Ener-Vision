import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:supabase_project/AuthService/auth_service_posts.dart';
import 'package:supabase_project/CommonWidgets/appliance_container/snack_bar.dart';
import 'package:supabase_project/CommonWidgets/controllers/app_controllers.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../AuthService/auth_suggestions.dart';
import '../../ConstantTexts/Theme.dart';
import '../../EnergyManagement/Community/ellipse_icon.dart';
import '../../EnergyManagement/Community/energy_effieciency_page.dart';
import '../appbar-widget.dart';
import 'package:hive/hive.dart';
import 'package:event_bus/event_bus.dart';

EventBus eventBus = EventBus();

class PostUpdatedEvent {}

class PostViewDialog extends StatefulWidget {
  final Map<String, dynamic> post;
  final int index;
  final Function onPostsUpdated;

  const PostViewDialog({
    Key? key,
    required this.post,
    required this.index,
    required this.onPostsUpdated,
  }) : super(key: key);

  @override
  State<PostViewDialog> createState() => _PostViewDialogState();
}

class _PostViewDialogState extends State<PostViewDialog> {
  final formatter = NumberFormat('#,##0.00', 'en_PHP');
  late List<Map<String, dynamic>> suggestions = [];
  List<Map<String, dynamic>> localSuggestions = []; // Local suggestions

  void addSuggestion(Map<String, dynamic> newSuggestion) {
    setState(() {
      suggestions.insert(0, newSuggestion); // Add to the top of the list
    });
  }

  String _formatDateTime(String? createdAt) {
    if (createdAt == null || createdAt.isEmpty) {
      return "Unknown date";
    }

    try {
      final DateTime dateTime = DateTime.parse(createdAt);
      final DateTime now = DateTime.now();
      final Duration difference = now.difference(dateTime);

      if (difference.inMinutes < 60) {
        return "${difference.inMinutes} minutes ago";
      } else if (difference.inHours < 24) {
        return "${difference.inHours} hours ago";
      } else if (difference.inDays < 7) {
        return "${difference.inDays} days ago";
      } else {
        // Format as "day month year" for older dates
        return "${dateTime.day} ${_monthName(dateTime.month)} ${dateTime.year}";
      }
    } catch (e) {
      print('Error parsing date: $e');
      return "Invalid date";
    }
  }

  final ScrollController _scrollController = ScrollController();
  AppControllers controller = AppControllers();
  List<Map<String, dynamic>> posts = [];

  String username = '[Username]';

  String _monthName(int month) {
    const months = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December"
    ];
    return months[month - 1];
  }

  @override
  void initState() {
    super.initState();
    suggestions =
        List<Map<String, dynamic>>.from(widget.post['suggestions'] ?? []);
    _loadUsername();
  }

  Future<void> getPostsFromApi() async {
    try {
      // Fetch posts directly from the API
      final List<Map<String, dynamic>>? fetchedPosts =
          await PostsService.getPosts();
      showSnackBar(context, 'Fetched posts from Api');
      print('Fetched all posts: $fetchedPosts');

      if (fetchedPosts != null && fetchedPosts.isNotEmpty) {
        setState(() {
          posts = fetchedPosts;
        });

        // Optionally, save the posts in Hive for future use
        var box = await Hive.openBox('postsBox');
        await box.put('allPosts', fetchedPosts);

        // Fetch suggestions for each post (only if 'id' is not null)
        for (var post in fetchedPosts) {
          String? postId = post['id']; // Assuming the post has an 'id' field

          if (postId != null) {
            // Fetch suggestions for each post with a valid 'id'
            await fetchSuggestions(postId);
          } else {
            print('Skipping post with null id');
          }
        }
      } else {
        throw Exception('No posts found or invalid post data format.');
      }
    } catch (e) {
      print('Failed to fetch posts: $e');
      showSnackBar(context, 'Failed to fetch posts. Please try again later.');
    } finally {}
  }

  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    final storedUsername = prefs.getString('username');

    setState(() {
      username = storedUsername ?? '[Username]';
    });
  }

  @override
  Widget build(BuildContext context) {
    int index = 0;
    return Scaffold(
      appBar: customAppBar1(
        showBackArrow: true,
        showProfile: false,
        title: '${widget.post['tags'] ?? 'N/A'}',
        onBackPressed: () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const EnergyEfficiencyPage(
                selectedIndex: 1,
              ),
            ),
          );
        },
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Column(
                children: [
                  _showPostTopBar(
                    index,
                    widget.post['title'] ?? 'Post Title',
                    widget.post['description'] ?? 'Description',
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const SizedBox(height: 20),
              _buildSuggestionTextField(widget.index),
              buildSuggestionsList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSuggestionsList() {
    if (suggestions.isEmpty) {
      return const Text('No suggestions yet');
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        var suggestion = suggestions[index];
        return Container(
          padding: const EdgeInsets.only(left: 15, bottom: 5),
          margin: const EdgeInsets.symmetric(vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(17.0),
            border: Border.all(
              color: Colors.grey[500]!,
              width: 2.0,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    suggestion['suggestedBy'] ?? "Unknown User",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                      color: Color(0xFF1BBC9B),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _formatDateTime(
                      suggestion['createdAt'],
                    ),
                    style: const TextStyle(
                      fontSize: 12.0,
                      color: Colors.grey,
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_horiz),
                    itemBuilder: (BuildContext context) {
                      return {'Edit', 'Delete'}.map((String choice) {
                        return PopupMenuItem<String>(
                          value: choice,
                          child: Text(choice),
                        );
                      }).toList();
                    },
                    onSelected: (String value) async {
                      if (value == 'Delete') {
                        // Handle delete logic
                      } else if (value == 'Edit') {
                        // Handle edit logic
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 5.0),
              Text(
                suggestion['suggestionText'] ?? "No suggestion provided",
                style: const TextStyle(
                  fontSize: 14.0,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 5.0),
            ],
          ),
        );
      },
    );
  }

  // Widget buildSuggestionsList() {
  //   return Column(
  //     children: widget.post['suggestions']?.isNotEmpty ?? false
  //         ? [_suggestionsWidget()]
  //         : [],
  //   );
  // }

  Widget _showPostTopBar(
    int index,
    String title,
    String description,
  ) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTopPost(
            widget.post['username'] ?? '',
            widget.post['timeAgo'] ?? 'Some Time Ago',
            widget.post['tags'] ?? '',
            widget.post['imageUpload'] ?? '',
            index,
          ),
          const SizedBox(height: 10),
          BuildTitle(title: title),
          const SizedBox(height: 10),
          BuildDescription(description: description),
          // PostImage(postImageUrl: postImageUrl),
          const SizedBox(height: 10.0),
        ],
      ),
    );
  }

  Widget _buildTopPost(
    String username,
    String timeAgo,
    String tags,
    String profileImageUrl,
    int index,
  ) {
    return Row(
      children: [
        BuildAvatar(
          profileImageUrl: profileImageUrl,
        ),
        const SizedBox(width: 10.0),
        TagsAndTitle(title: username, tags: tags),
        const Spacer(),
        BuildTags(tags: timeAgo),
        const SizedBox(width: 10.0),
        BuildIcon(
          index: index,
          onTap: (index) {
            // _editPostActionSheet(context, index);
          },
        ),
      ],
    );
  }

  Widget _suggestionsWidget(List<Map<String, dynamic>> allSuggestions) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 450),
      child: Scrollbar(
        thumbVisibility: true,
        controller: _scrollController,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: allSuggestions.length,
          itemBuilder: (context, suggestionIndex) {
            var suggestion = allSuggestions[suggestionIndex];
            return Container(
              padding: const EdgeInsets.only(left: 15, bottom: 5),
              margin: const EdgeInsets.symmetric(vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(17.0),
                border: Border.all(
                  color: Colors.grey[500]!,
                  width: 2.0,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        suggestion['suggestedBy'] ?? 'Anonymous',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                          color: Color(0xFF1BBC9B),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _formatDateTime(suggestion['createdAt']),
                        style: const TextStyle(
                          fontSize: 12.0,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5.0),
                  Text(
                    suggestion['suggestionText'] ?? "Text",
                    style: const TextStyle(
                      fontSize: 14.0,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 5.0),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSuggestionTextField(int index) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(7.0),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(7.0),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 10.0, right: 20),
                  child: Image(
                    image: AssetImage('assets/suggestionImage.png'),
                  ),
                ),
                const SizedBox(width: 5.0),
                Expanded(
                  child: TextField(
                    controller: controller.suggestionController,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Suggest changes or additional tips...',
                      hintStyle: TextStyle(
                        color: Colors.grey,
                        fontSize: 12.0,
                      ),
                    ),
                  ),
                ),
                Builder(builder: (context) {
                  return IconButton(
                    icon: const Icon(
                      Icons.send_rounded,
                      color: Color(0xFF1BBC9B),
                      size: 24,
                    ),
                    onPressed: () {
                      if (controller.suggestionController.text.trim().isEmpty)
                        return;

                      // final currentUsername = username;

                      final newSuggestion = {
                        'suggestionText':
                            controller.suggestionController.text.trim(),
                        'suggestedBy': username,
                        'createdAt': DateTime.now().toIso8601String(),
                      };

                      addSuggestion(newSuggestion);

                      // Optionally send to the server
                      SuggestionService.addSuggestionNew(
                        context: context,
                        suggestionController: controller.suggestionController,
                        posts: posts,
                        postId: widget.post['id'],
                      );
                      // getPostsFromApi();
                      // eventBus.fire(PostUpdatedEvent());

                      controller.suggestionController.clear();
                    },
                  );
                }),
                const SizedBox(width: 10.0),
              ],
            ),
          ),
          const SizedBox(height: 10.0),
        ],
      ),
    );
  }

  Future<void> fetchSuggestions(String postId) async {
    try {
      final postData = await SuggestionService.getPostSuggestions(postId);
      setState(() {
        suggestions = postData as List<Map<String, dynamic>>;
        print(
          'Suggestions data loaded for post $postId: $postData',
        );
      });
      // Now you can do something with the post data, e.g. update UI or state
      print(postData); // Example to print the post data
    } catch (e) {
      print('Error fetching post: $e');
    }
  }
}

Widget _popupTitle(String title) {
  return Text(
    title,
    style: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: Colors.black,
      fontFamily: 'Montserrat',
    ),
  );
}

Widget _popupDescription(String description) {
  return Text(
    description,
    textAlign: TextAlign.center,
    style: TextStyle(
      fontSize: 14,
      color: Colors.grey[500],
      fontFamily: 'Montserrat',
    ),
  );
}

// void _confirmDeleteSuggestion(int index) {
//   // Ensure the index is valid and within the bounds of the list
//   if (index < 0 || index >= widget.suggestions.length) {
//     print('Invalid index: $index. Cannot delete suggestion.');
//     return;
//   }
//
//   final suggestion = widget.suggestions[index];
//
//   // Verify that the suggestion object has a valid '_id'
//   if (suggestion == null || suggestion['_id'] == null) {
//     print('No valid suggestion or _id found.');
//     return;
//   }
//   Future<void> deleteSuggestion(String suggestionId) async {
//     try {
//       await SuggestionService.deleteSuggestion(suggestionId);
//       print('Suggestion deleted successfully');
//       // Optionally, update your UI state here (e.g., remove the suggestion from the list)
//     } catch (e) {
//       print('Error deleting Suggestion: $e');
//     }
//   }
//
//   // Show confirmation dialog for deletion
//   showDialog(
//     context: context,
//     builder: (BuildContext context) {
//       return Dialog(
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(20),
//         ),
//         elevation: 16,
//         backgroundColor: Colors.white,
//         child: Padding(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const Icon(
//                 Icons.warning,
//                 color: AppColors.primaryColor,
//                 size: 50,
//               ),
//               const SizedBox(height: 20),
//               _popupTitle('Delete Suggestion?'),
//               const SizedBox(height: 10),
//               _popupDescription(
//                 'Are you sure you want to delete this suggestion? This cannot be undone.',
//               ),
//               const SizedBox(height: 20),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   TextButton(
//                     onPressed: () {
//                       Navigator.of(context).pop();
//                     },
//                     child: const Text('Cancel'),
//                   ),
//                   ElevatedButton(
//                     onPressed: () {
//                       deleteSuggestion(suggestion['_id']).then((_) {
//                         Navigator.of(context).pop();
//                       }).catchError((e) {
//                         // Handle any errors during deletion
//                         print('Error deleting suggestion: $e');
//                         Navigator.of(context).pop(); // Close dialog if error
//                       });
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: AppColors.primaryColor,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 20, vertical: 12),
//                     ),
//                     child: const Text(
//                       'Delete',
//                       style: TextStyle(
//                         fontSize: 12,
//                         color: Colors.white,
//                         fontFamily: 'Montserrat',
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       );
//     },
//   );
// }

//Key value row usage
// Key value row usage

// KeyValueRow(
// label: 'Title',
// value: '${widget.post['title'] ?? 'N/A'}',
// ),
// KeyValueRow(
// label: 'Tags',
// value: '${widget.post['tags'] ?? 'N/A'}',
// ),
// KeyValueRow(
// label: 'Description',
// value: '${widget.post['description'] ?? 'hours'} ',
// ),
class KeyValueRow extends StatelessWidget {
  final String label;
  final String value;

  const KeyValueRow({
    Key? key,
    required this.label,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
