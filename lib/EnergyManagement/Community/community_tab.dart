import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:supabase_project/AuthService/auth_service_posts.dart';
import 'package:supabase_project/AuthService/auth_suggestions.dart';
import 'package:supabase_project/AuthService/base_url.dart';
import 'package:supabase_project/CommonWidgets/appliance_container/snack_bar.dart';
import 'package:supabase_project/CommonWidgets/box_decorations.dart';
import 'package:supabase_project/CommonWidgets/controllers/app_controllers.dart';
import 'package:supabase_project/CommonWidgets/controllers/text_utils.dart';
import 'package:supabase_project/CommonWidgets/dialogs/confirm_delete.dart';
import 'package:supabase_project/CommonWidgets/dialogs/loading_animation.dart';
import 'package:supabase_project/CommonWidgets/dialogs/post_view_dialog.dart';
import 'package:supabase_project/ConstantTexts/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import 'package:event_bus/event_bus.dart';
import 'package:supabase_project/EnergyManagement/Community/top_bar.dart';

import '../../zNotUsedFiles/post_authenticated/create_post.dart';
import 'create_post.dart';
import 'ellipse_icon.dart';
import 'empty_post_page.dart';

EventBus eventBus = EventBus();

class PostUpdatedEvent {}

class CommunityTab extends StatefulWidget {
  const CommunityTab({super.key});

  @override
  State<CommunityTab> createState() => _CommunityTabState();
}

class _CommunityTabState extends State<CommunityTab> {
  AppControllers controller = AppControllers();
  final AppControllers controllers = AppControllers();
  final ScrollController _scrollController = ScrollController();
  bool isLoading = false;
  bool showUsersPosts = false;
  bool isUserPost = false;
  String placeholderImage = 'assets/image (6).png';

  int? activeSuggestionIndex;
  int? _tappedIndex;
  int? editingIndex;

  String? username;
  String postId = '';
  String? error;

  List<TextEditingController> editControllers = [];
  List<Map<String, dynamic>> posts = [];
  late List<Map<String, dynamic>> suggestions = [];
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
    getPosts();
    //
    // eventBus.on<PostUpdatedEvent>().listen((event) {
    // getPostsFromApi();
    // });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> deleteSuggestion(String suggestionId) async {
    try {
      await SuggestionService.deleteSuggestion(suggestionId);
      print('Suggestion deleted successfully');
      // Optionally, update your UI state here (e.g., remove the suggestion from the list)
    } catch (e) {
      print("Error deleting Suggestion: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            children: <Widget>[
              TopBar(onEditTap: () {
                _showActionSheet(context);
              }, onRefreshTap: () {
                getPostsFromApi();
              }),
              _content(),
            ],
          ),
        ),
        Positioned(
          bottom: 40.0,
          right: 20.0,
          child: ElevatedButton(
            onPressed: () async {
              _showActionSheet(context);
            },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(24),
            ),
            child: const Icon(
              Icons.add,
              size: 16,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> getPostsFromApi() async {
    setState(() {
      isLoading = true;
    });
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
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> getPosts() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Attempt to load posts from Hive (cached posts)
      List<Map<String, dynamic>> postsFromHive =
          await PostsService.getPostsFromHive();
      showSnackBar(context, 'Fetched posts from Hive');

      print('Fetched all from hive: $postsFromHive');

      // If no posts exist in Hive, fetch from API
      if (postsFromHive.isEmpty) {
        final List<Map<String, dynamic>>? fetchedPosts =
            await PostsService.getPosts();
        print('Fetched all posts: $fetchedPosts');
        // showSnackBar(context, 'Fetched posts from API');

        if (fetchedPosts != null && fetchedPosts.isNotEmpty) {
          setState(() {
            posts = fetchedPosts;
          });

          // Save the fetched posts in Hive for future use
          var box = await Hive.openBox('postsBox');
          await box.clear(); // Clear previous posts if necessary

          for (var post in fetchedPosts) {
            await box.put(post['id'], post); // Each post saved under its own ID
          }

          // Fetch suggestions for each post (only if 'id' is not null)
          for (var post in fetchedPosts) {
            String? postId = post['id']; // Assuming the post has an 'id' field

            if (postId != null) {
              await fetchSuggestions(postId);
            } else {
              print('Skipping post with null id');
            }
          }
        } else {
          throw Exception('Invalid post data format.');
        }
      } else {
        setState(() {
          posts = postsFromHive;
        });

        // Fetch suggestions for each post (only if 'id' is not null)
        for (var post in postsFromHive) {
          String? postId = post['id']; // Assuming the post has an 'id' field

          if (postId != null) {
            // Fetch suggestions for each post with a valid 'id'
            await fetchSuggestions(postId);
          } else {
            print('Skipping post with null id');
          }
        }
      }
    } catch (e) {
      print('Failed to fetch posts: $e');
      showSnackBar(context, 'Failed to fetch posts. Please try again later.');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchSuggestions(String postId) async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final suggestionsData = await SuggestionService.getComments(postId);
      setState(() {
        suggestions = suggestionsData;
        print(
          'Suggestions data loaded for post $postId: $suggestionsData',
        );
      });
    } catch (e) {
      print('Error: $e');
      setState(() {
        error =
            'Failed to load suggestions for post $postId. Please try again later.';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }


  Widget _content() {
    List<dynamic> sortedPosts = List.from(posts);

    // Sort posts by `timeAgo` (latest to oldest)
    sortedPosts.sort((a, b) {
      DateTime? timeA = DateTime.tryParse(a['timeAgo'] ?? '');
      DateTime? timeB = DateTime.tryParse(b['timeAgo'] ?? '');
      return (timeB ?? DateTime.now()).compareTo(timeA ?? DateTime.now());
    });

    return SizedBox(
      height: 520,
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (isLoading)
              const Center(
                child: LoadingWidget(
                  message: 'Getting Post',
                  color: AppColors.primaryColor,
                ),
              )
            else if (sortedPosts.isEmpty)
              const Center(child: Body())
            else
              ...sortedPosts.asMap().entries.map((entry) {
                var post = entry.value;
                int index = entry.key;

                // Sort suggestions by `createdAt` (latest to oldest)
                if (post['suggestions'] != null &&
                    post['suggestions'].isNotEmpty) {
                  post['suggestions'].sort((a, b) {
                    DateTime? timeA = DateTime.tryParse(a['createdAt'] ?? '');
                    DateTime? timeB = DateTime.tryParse(b['createdAt'] ?? '');
                    return (timeB ?? DateTime.now()).compareTo(timeA ?? DateTime.now());
                  });
                }

                return Container(
                  margin: const EdgeInsets.all(10.0),
                  decoration: greyBoxDecoration(),
                  child: Column(
                    children: [
                      _buildUserPost(
                        post['username'] ?? 'Unknown User',
                        post['title'] ?? 'No Title',
                        post['description'] ?? 'No Description',
                        post['timeAgo'] ?? 'Some time ago',
                        post['tags'] ?? 'No tags',
                        '',
                        '',
                        index,
                      ),
                      // Only show suggestions for the current post
                      if (post['suggestions'] != null &&
                          post['suggestions'].isNotEmpty)
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 200),
                          child: ScrollbarTheme(
                            data: ScrollbarThemeData(
                              thumbColor: WidgetStateProperty.all(AppColors.primaryColor),
                              trackColor: WidgetStateProperty.all(Colors.grey[300]),
                              trackBorderColor: WidgetStateProperty.all(Colors.transparent),
                              thickness: WidgetStateProperty.all(10),
                              radius: const Radius.circular(20),
                              thumbVisibility: WidgetStateProperty.all(true),
                            ),
                            child: Scrollbar(
                              thumbVisibility: true,
                              controller: _scrollController,
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: post['suggestions'].length,
                                itemBuilder: (context, suggestionIndex) {
                                  var suggestion = post['suggestions'][suggestionIndex] ?? "Suggestions";
                                  return Container(
                                    padding: const EdgeInsets.only(left: 15, bottom: 5),
                                    margin: const EdgeInsets.symmetric(vertical: 5),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(7.0),
                                      border: Border.all(color: Colors.grey[300]!),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              suggestion['suggestedBy'] ?? username,
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
                                            PopupMenuButton<String>(
                                              icon: const Icon(Icons.more_horiz),
                                              itemBuilder: (BuildContext context) {
                                                return {'Edit', 'Delete'}
                                                    .map((String choice) {
                                                  return PopupMenuItem<String>(
                                                    value: choice,
                                                    child: Text(choice),
                                                  );
                                                }).toList();
                                              },
                                              onSelected: (String value) async {
                                                if (value == 'Delete') {
                                                  _confirmDeleteSuggestion(index);
                                                } else if (value == 'Edit') {
                                                  // Handle edit logic here
                                                  print('Edit tapped');
                                                }
                                              },
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
                          ),
                        ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildUserPost(
    String username,
    String title,
    String description,
    String timeAgo,
    String tags,
    String profileImageUrl,
    String postImageUrl,
    int index,
  ) {
    List<dynamic> sortedPosts = List.from(posts);
    final post = posts[index];

    sortedPosts.sort((a, b) {
      DateTime? timeA = DateTime.tryParse(a['timeAgo'] ?? '');
      DateTime? timeB = DateTime.tryParse(b['timeAgo'] ?? '');
      return (timeB ?? DateTime.now()).compareTo(timeA ?? DateTime.now());
    });

    // sortedPosts.sort((a, b) {
    //   DateTime? timeA = DateTime.tryParse(a['timeAgo'] ?? '');
    //   DateTime? timeB = DateTime.tryParse(b['timeAgo'] ?? '');
    //   return (timeB ?? DateTime.now()).compareTo(timeA ?? DateTime.now());
    // });

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopPost(username, timeAgo, tags, profileImageUrl, index),
              BuildTitle(title: title),
              BuildDescription(description: description),
              // PostImage(postImageUrl: postImageUrl),
              const SizedBox(height: 10.0),
              _buildAddSuggestions(profileImageUrl, postImageUrl, index),
              if (_tappedIndex == index) _buildSuggestionTextField(index),
              // _buildSuggestionsList(),
            ],
          ),
        ),
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
            _editPostActionSheet(context, index);
          },
        ),
      ],
    );
  }

  Widget _buildAddSuggestions(
    String profileImageUrl,
    String postImageUrl,
    int index,
  ) {
    final post = posts[index];

    final String validProfileImageUrl =
        profileImageUrl.isNotEmpty ? profileImageUrl : placeholderImage;

    return Row(
      children: [
        Row(
          children: List.generate(3, (index) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3.0),
              child: CircleAvatar(
                radius: 10.0,
                backgroundImage: NetworkImage(validProfileImageUrl),
                child: ClipOval(
                  child: Image.network(
                    validProfileImageUrl,
                    width: 20.0,
                    height: 20.0,
                    fit: BoxFit.cover,
                    errorBuilder: (BuildContext context, Object error,
                        StackTrace? stackTrace) {
                      return Image.asset(
                        placeholderImage,
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                ),
              ),
            );
          }),
        ),
        const Spacer(),
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(

                builder: (context) => PostViewDialog(
                  post: post,
                  // suggestions: suggestions,
                  index: index, onPostsUpdated: getPostsFromApi,
                ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1BBC9B),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
          ),
          child: Text(
            'Add Suggestions',
          ),
        )
      ],
    );
    // return Row(
    //   children: [
    //     Row(
    //       children: List.generate(3, (index) {
    //         return Padding(
    //           padding: const EdgeInsets.symmetric(horizontal: 3.0),
    //           child: CircleAvatar(
    //             radius: 10.0,
    //             backgroundImage: NetworkImage(validProfileImageUrl),
    //             child: ClipOval(
    //               child: Image.network(
    //                 validProfileImageUrl,
    //                 width: 20.0,
    //                 height: 20.0,
    //                 fit: BoxFit.cover,
    //                 errorBuilder: (BuildContext context, Object error,
    //                     StackTrace? stackTrace) {
    //                   return Image.asset(
    //                     placeholderImage,
    //                     fit: BoxFit.cover,
    //                   );
    //                 },
    //               ),
    //             ),
    //           ),
    //         );
    //       }),
    //     ),
    //     const Spacer(),
    //     ElevatedButton(
    //       onPressed: () {
    //         if (_tappedIndex == index) {
    //           setState(() {
    //             _tappedIndex = null;
    //           });
    //         } else {
    //           setState(() {
    //             // postId = post['id'];
    //             // postId = post['id'] ?? post['_id'];
    //             print('Attempting: $postId');
    //             //
    //             // fetchSuggestions(postId);
    //             _tappedIndex = index;
    //           });
    //         }
    //       },
    //       style: ElevatedButton.styleFrom(
    //         backgroundColor: const Color(0xFF1BBC9B),
    //         shape: RoundedRectangleBorder(
    //           borderRadius: BorderRadius.circular(20.0),
    //         ),
    //       ),
    //       child: Text(
    //         _tappedIndex == index ? 'Hide Suggestions' : 'Add Suggestions',
    //       ),
    //     )
    //   ],
    // );
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
                  padding: EdgeInsets.only(left: 2.0),
                  child: Image(
                    image: AssetImage('assets/suggestion.png'),
                    width: 50.0,
                    height: 50.0,
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
                IconButton(
                  icon: const Icon(
                    Icons.send_rounded,
                    color: Color(0xFF1BBC9B),
                    size: 24,
                  ),
                  onPressed: () async {
                    SuggestionService.addSuggestion(
                      context: context,
                      suggestionController: controller.suggestionController,
                      posts: posts,
                      index: index,
                    );
                    await fetchSuggestions(postId);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 10.0),
        ],
      ),
    );
  }

  // Future<void> fetchSuggestions(String postId) async {
  //   setState(() {
  //     isLoading = true;
  //     error = null;
  //   });
  //
  //   try {
  //     final suggestionsData = await SuggestionService.getComments(postId);
  //     setState(() {
  //       suggestions = suggestionsData;
  //       print(
  //         'suggestions data loaded $suggestionsData',
  //       );
  //     });
  //   } catch (e) {
  //     print('Error: $e');
  //     setState(() {
  //       error = 'Failed to load suggestions. Please try again later.';
  //     });
  //   } finally {
  //     setState(() {
  //       isLoading = false;
  //     });
  //   }
  // }
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

  void _confirmDeleteSuggestion(int index) {
    // Ensure the index is valid and within the bounds of the list
    if (index < 0 || index >= suggestions.length) {
      print('Invalid index: $index. Cannot delete suggestion.');
      return;
    }

    final suggestion = suggestions[index];

    // Verify that the suggestion object has a valid '_id'
    if (suggestion == null || suggestion['_id'] == null) {
      print('No valid suggestion or _id found.');
      return;
    }

    // Show confirmation dialog for deletion
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 16,
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.warning,
                  color: AppColors.primaryColor,
                  size: 50,
                ),
                const SizedBox(height: 20),
                _popupTitle('Delete Suggestion?'),
                const SizedBox(height: 10),
                _popupDescription(
                  'Are you sure you want to delete this suggestion? This cannot be undone.',
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        deleteSuggestion(suggestion['_id']).then((_) {
                          Navigator.of(context).pop();
                        }).catchError((e) {
                          // Handle any errors during deletion
                          print('Error deleting suggestion: $e');
                          Navigator.of(context).pop(); // Close dialog if error
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                      ),
                      child: const Text(
                        'Delete',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> deletePost(String postId) async {
    try {
      await PostsService.deleteAPost(postId);
      showSnackBar(context, 'Post deleted successfully');
      print('Post deleted successfully');
    } catch (e) {
      print('Error deleting Post: $e');
    }
  }

  Future<void> getUsersPost() async {
    setState(() {
      isLoading = true;
      isUserPost = true;
    });
    try {
      final fetchedData = await PostsService.fetchUsersPosts();
      print('Fetched data: $fetchedData'); // Log the fetched data

      setState(() {
        posts = List<Map<String, dynamic>>.from(fetchedData['posts']);
        username = fetchedData['username'];
      });
    } catch (e) {
      print('Failed to fetch posts: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Future<void> getPosts() async {
  //   setState(() {
  //     isLoading = true;
  //   });
  //
  //   try {
  //     // Attempt to load posts from Hive (cached posts)
  //     List<Map<String, dynamic>> postsFromHive =
  //         await PostsService.getPostsFromHive();
  //     print('Fetched all from hive: $postsFromHive');
  //
  //     // If no posts exist in Hive, fetch from API
  //     if (postsFromHive.isEmpty) {
  //       final List<Map<String, dynamic>>? fetchedPosts =
  //           await PostsService.getPosts();
  //       print('Fetched all posts: $fetchedPosts');
  //
  //       if (fetchedPosts != null && fetchedPosts.isNotEmpty) {
  //         setState(() {
  //           posts = fetchedPosts;
  //         });
  //
  //         // Save the fetched posts in Hive for future use
  //         var box = await Hive.openBox('postsBox');
  //         await box.put('allPosts', fetchedPosts);
  //       } else {
  //         throw Exception('Invalid post data format.');
  //       }
  //     } else {
  //       // If posts are available in Hive, display them
  //       setState(() {
  //         posts = postsFromHive;
  //       });
  //     }
  //   } catch (e) {
  //     print('Failed to fetch posts: $e');
  //     showSnackBar(context, 'Failed to fetch posts. Please try again later.');
  //   } finally {
  //     setState(() {
  //       isLoading = false;
  //     });
  //   }
  // }

  void showPostDialog(int index) {
    var post = posts[index];
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return PostViewDialog(
          post: post,
          // suggestions: suggestions,
          index: index, onPostsUpdated: getPostsFromApi,
        );
      },
    );
  }

  void _confirmDeletePost(int index) {
    if (index < 0 || index >= posts.length || posts[index]['_id'] == null) {
      print('Invalid index or missing post ID for deletion');
      return;
    }

    final postId = posts[index]['_id'];
    print('Attempting to delete post with ID: $postId');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ConfirmDeleteDialog(
          title: 'Delete Post?',
          description: 'Are you sure you want to delete this post?',
          onDelete: () => deletePost(postId),
          postDelete: getUsersPost,
        );
      },
    );
  }

  void _togglePostView() {
    setState(() {
      showUsersPosts = !showUsersPosts;

      // Clear previous posts to prevent data mixing
      posts.clear(); // Assuming `posts` is your list of posts being displayed

      if (showUsersPosts) {
        getUsersPost(); // Fetch posts for the logged-in user
      } else {
        getPosts(); // Fetch all posts
      }
    });
  }

  void _showActionSheet(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: const Text('Actions'),
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            isDestructiveAction: false,
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CreatePostPage()),
              );
            },
            child: const Text('Create a new post'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _togglePostView();
            },
            child: const Text('View All My Posts'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text(
            'Cancel',
            style: TextStyle(
              color: Colors.redAccent,
            ),
          ),
        ),
      ),
    );
  }

  void _editPostActionSheet(BuildContext context, int index) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: const Text('Actions'),
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
              if (isUserPost) {
                _confirmDeletePost(index);
              } else {
                _confirmReportPost(index);
              }
            },
            child: isUserPost
                ? const Text('Delete Post')
                : const Text('Report Post'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () {
            Navigator.pop(context); // Close the action sheet
          },
          child: const Text(
            'Cancel',
            style: TextStyle(
                // color: Colors.redAccent,
                ),
          ),
        ),
      ),
    );
  }

  void _confirmReportPost(int index) {
    final post = posts[index];
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ConfirmDeleteDialog(
          title: 'Report Post?',
          description: 'Are you sure you want to Report this Post? ',
          onDelete: () => deletePost(post['_id']).then(
            (_) {},
          ),
          postDelete: getPosts,
        );
      },
    );
  }
}
