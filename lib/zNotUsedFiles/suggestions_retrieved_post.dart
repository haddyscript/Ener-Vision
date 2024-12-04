// import 'dart:convert';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/gestures.dart';
// import 'package:flutter/material.dart';
//
// import 'package:supabase_project/AuthService/auth_service_posts.dart';
// import 'package:supabase_project/AuthService/auth_suggestions.dart';
// import 'package:supabase_project/CommonWidgets/appliance_container/snack_bar.dart';
// import 'package:supabase_project/CommonWidgets/box_decorations.dart';
// import 'package:supabase_project/CommonWidgets/controllers/app_controllers.dart';
// import 'package:supabase_project/CommonWidgets/dialogs/confirm_delete.dart';
// import 'package:supabase_project/CommonWidgets/dialogs/loading_animation.dart';
// import 'package:supabase_project/CommonWidgets/dialogs/post_view_dialog.dart';
// import 'package:supabase_project/ConstantTexts/colors.dart';
// import 'package:supabase_project/EnergyEfficiency/Community/create_post.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
// import 'package:supabase_project/EnergyEfficiency/Community/ellipse_icon.dart';
// import 'package:supabase_project/EnergyEfficiency/Community/empty_post_page.dart';
// import 'package:supabase_project/EnergyEfficiency/Community/suggestion_list.dart';
// import 'package:supabase_project/EnergyEfficiency/Community/top_bar.dart';
// import 'package:supabase_project/AuthService/auth_appliances.dart';
//
// class CommunityTab extends StatefulWidget {
//   const CommunityTab({super.key});
//
//   @override
//   State<CommunityTab> createState() => _CommunityTabState();
// }
//
// class _CommunityTabState extends State<CommunityTab> {
//   AppControllers controller = AppControllers();
//   final AppControllers controllers = AppControllers();
//   final ScrollController _scrollController = ScrollController();
//
//   bool isLoading = false;
//   bool showUsersPosts = false;
//   bool isUserPost = false;
//   String placeholderImage = 'assets/image (6).png';
//
//   int? activeSuggestionIndex;
//   int? _tappedIndex;
//   int? editingIndex;
//
//   String? username;
//   String postId = '';
//   String? error;
//
//   List<TextEditingController> editControllers = [];
//   List<dynamic> suggestions = [];
//   List<Map<String, dynamic>> posts = [];
//
//   static const String baseUrl = 'http://10.0.2.2:8080';
//
//   @override
//   void initState() {
//     super.initState();
//     getPosts();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       controller: _scrollController,
//       child: Column(
//         children: <Widget>[
//           const SizedBox(height: 20),
//           TopBar(onEditTap: () {
//             _showActionSheet(context);
//           }, onRefreshTap: () {
//             getPosts();
//           }),
//           _content(),
//         ],
//       ),
//     );
//   }
//
//   Widget _content() {
//     List<dynamic> sortedPosts = List.from(posts);
//     sortedPosts.sort((a, b) {
//       String timeAgoA = a['timeAgo'] ?? '';
//       String timeAgoB = b['timeAgo'] ?? '';
//       return timeAgoB.compareTo(timeAgoA);
//     });
//
//     return SizedBox(
//       height: 500,
//       child: SingleChildScrollView(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             if (isLoading)
//               const Center(
//                   child: LoadingWidget(
//                 message: 'Getting Post',
//                 color: AppColors.primaryColor,
//               ))
//             else if (sortedPosts.isEmpty)
//               const Center(child: Body())
//             else
//               ...sortedPosts.asMap().entries.map((entry) {
//                 var post = entry.value;
//                 int index = entry.key;
//                 return _buildUserPost(
//                   post['username'] ?? 'Username',
//                   post['title'] ?? 'No Title',
//                   post['description'] ?? 'No Description',
//                   post['timeAgo'] ?? 'Some time ago',
//                   post['tags'] ?? 'No tags',
//                   'https://example.com/user_avatar.jpg',
//                   'https://example.com/sample_image.jpg',
//                   index,
//                 );
//               }),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildUserPost(
//     String username,
//     String title,
//     String description,
//     String timeAgo,
//     String tags,
//     String profileImageUrl,
//     String postImageUrl,
//     int index,
//   ) {
//     List<dynamic> sortedPosts = List.from(posts);
//     final post = posts[index];
//
//     sortedPosts.sort((a, b) {
//       String timeAgoA = a['timeAgo'] ?? '';
//       String timeAgoB = b['timeAgo'] ?? '';
//       return timeAgoB.compareTo(timeAgoA);
//     });
//     return SingleChildScrollView(
//       child: Padding(
//         padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
//         child: Container(
//           padding: const EdgeInsets.all(10.0),
//           decoration: greyBoxDecoration(),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   BuildAvatar(
//                     profileImageUrl: profileImageUrl,
//                   ),
//                   const SizedBox(width: 10.0),
//                   _buildTitleTags(username, tags),
//                   const Spacer(),
//                   _buildTags(timeAgo),
//                   const SizedBox(width: 10.0),
//                   BuildIcon(
//                     index: index,
//                     onTap: (index) {
//                       _editPostActionSheet(context, index);
//                     },
//                   )
//                 ],
//               ),
//               BuildTitle(title: title),
//               BuildDescription(description: description),
//               const SizedBox(height: 10.0),
//               _buildSuggestionsButton(postImageUrl, index),
//               if (_tappedIndex == index) _buildSuggestionTextField(index),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildSuggestionTextField(int index) {
//     final post = posts[index];
//     final postId = post['_id'] ?? '6735ed7b6957b66f80af5b72';
//
//     return Container(
//       margin: const EdgeInsets.all(18.0),
//       padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(7.0),
//         border: Border.all(color: Colors.grey[300]!),
//       ),
//       child: Column(
//         children: [
//           Row(
//             children: [
//               const Padding(
//                 padding: EdgeInsets.only(left: 2.0),
//                 child: Image(
//                   image: AssetImage('assets/suggestion.png'),
//                   width: 50.0,
//                   height: 50.0,
//                 ),
//               ),
//               const SizedBox(width: 5.0),
//               Expanded(
//                 child: TextField(
//                   controller: controller.suggestionController,
//                   decoration: const InputDecoration(
//                     border: InputBorder.none,
//                     hintText: 'Suggest changes or additional tips...',
//                     hintStyle: TextStyle(
//                       color: Colors.grey,
//                       fontSize: 12.0,
//                     ),
//                   ),
//                 ),
//               ),
//               IconButton(
//                 icon: const Icon(
//                   Icons.send_rounded,
//                   color: Color(0xFF1BBC9B),
//                   size: 24,
//                 ),
//                 onPressed: () async {
//                   final suggestionText = controller.suggestionController.text;
//
//                   if (suggestionText.isNotEmpty) {
//                     try {
//                       // await addSuggestion(postId, {
//                       //   'suggestionText': suggestionText,
//                       // });
//                       showSnackBar(context, 'Suggestion added successfully');
//                       controller.suggestionController
//                           .clear(); // Clear the text field after successful submission
//                     } catch (e) {
//                       showSnackBar(context, 'Failed to add suggestion: $e');
//                     }
//                   } else {
//                     showSnackBar(context, 'Suggestion text cannot be empty');
//                   }
//                 },
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildSuggestionsButton(String profileImageUrl, int index) {
//     final String validProfileImageUrl =
//         profileImageUrl.isNotEmpty ? profileImageUrl : placeholderImage;
//     final postId = posts[index]['_id'] ?? '6735ed7b6957b66f80af5b72';
//     return Row(
//       children: [
//         Row(
//           children: List.generate(3, (index) {
//             return Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 3.0),
//               child: CircleAvatar(
//                 radius: 10.0,
//                 backgroundImage: NetworkImage(validProfileImageUrl),
//                 child: ClipOval(
//                   child: Image.network(
//                     validProfileImageUrl,
//                     width: 20.0,
//                     height: 20.0,
//                     fit: BoxFit.cover,
//                     errorBuilder: (BuildContext context, Object error,
//                         StackTrace? stackTrace) {
//                       return Image.asset(
//                         placeholderImage,
//                         fit: BoxFit.cover,
//                       );
//                     },
//                   ),
//                 ),
//               ),
//             );
//           }),
//         ),
//         // Column(
//         //   children: [_buildSuggestionsList()],
//         // ),
//         const Spacer(),
//         ElevatedButton(
//           onPressed: () {
//             // showPostDialog(index);
//             setState(() {
//               if (_tappedIndex == index) {
//                 _tappedIndex = index;
//
//                 fetchSuggestions(postId);
//               } else {
//                 _tappedIndex = index;
//               }
//             });
//             // Navigator.push(
//             //   context,
//             //   MaterialPageRoute(builder: (context) => SuggestionExample()),
//             // );
//           },
//           style: ElevatedButton.styleFrom(
//             backgroundColor: const Color(0xFF1BBC9B),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(20.0),
//             ),
//           ),
//           child: const Text('Add Suggestions'),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildTags(String tags) {
//     return Padding(
//       padding: const EdgeInsets.only(left: 10.0),
//       child: Text(
//         tags,
//         style: TextStyle(fontSize: 12, color: Colors.grey[600]),
//       ),
//     );
//   }
//
//   Widget _buildTitleTags(String title, String tags) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [BuildTitle(title: title), BuildTags(tags: tags)],
//     );
//   }
//
//   Future<void> getPosts() async {
//     setState(() {
//       isLoading = true;
//       isUserPost = false;
//     });
//
//     try {
//       final fetchedPosts = await PostsService.getPosts();
//       setState(() {
//         posts = fetchedPosts;
//       });
//     } catch (e) {
//       print('Failed to fetch posts: $e');
//       showSnackBar(context, 'Post not fetched');
//     } finally {
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }
//
//   Future<void> deletePost(String postId) async {
//     try {
//       await ApplianceService.deletePost(postId);
//       print('Post deleted successfully');
//     } catch (e) {
//       print('Error deleting appliance: $e');
//     }
//   }
//
//   Future<void> addSuggestionNew(
//       String postId, Map<String, dynamic> suggestionData) async {
//     try {
//       await ApplianceService.addSuggestionToAPost(postId, suggestionData);
//       print('Suggestion added successfully');
//     } catch (e) {
//       print('Error adding suggestion: $e');
//     }
//   }
//
//   Future<void> getUsersPost() async {
//     setState(() {
//       isLoading = true;
//       isUserPost = true;
//     });
//
//     try {
//       final fetchedPosts = await PostsService.fetchUsersPosts();
//       setState(() {
//         posts = fetchedPosts as List<Map<String, dynamic>>;
//       });
//     } catch (e) {
//       print('Failed to fetch posts: $e');
//     } finally {
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }
//
//   Future<void> fetchSuggestions(String postId) async {
//     setState(() {
//       isLoading = true;
//       error = null;
//     });
//
//     try {
//       final suggestionsData = await SuggestionService.getComments(postId);
//       setState(() {
//         suggestions = suggestionsData;
//         print(
//           'suggestions data loaded $suggestionsData',
//         );
//       });
//     } catch (e) {
//       print('Error: $e');
//       setState(() {
//         error = 'Failed to load suggestions. Please try again later.';
//       });
//     } finally {
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }
//
//   void onAddSuggestionButtonPressed(
//       String postId, Map<String, dynamic> suggestionData) {
//     if (postId != null) {
//       print("Adding suggestion for Post ID: $postId");
//       // addSuggestion(postId, suggestionData);
//     } else {
//       print("Post ID is null, cannot add suggestion.");
//     }
//   }
//
//   void showPostDialog(int index) {
//     var post = posts[index];
//
//     controllers.editApplianceNameController.text = post['applianceName'] ?? '';
//     controllers.editWattageController.text = post['wattage']?.toString() ?? '';
//     controllers.editUsagePatternController.text =
//         post['usagePatternPerDay']?.toString() ?? '';
//     controllers.editWeeklyPatternController.text =
//         post['selectedDays']?.toString() ?? '';
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return PostViewDialog(
//           post: post,
//           suggestions: [],
//           index: 1,
//         );
//       },
//     );
//   }
//
//   void _confirmDeletePost(int index) {
//     if (index < 0 || index >= posts.length) {
//       print('Invalid index for deleting post');
//       return;
//     }
//
//     final post = posts[index];
//
//     if (post['_id'] == null) {
//       print('Post ID is null, cannot delete');
//       return;
//     }
//
//     print('Attempting to delete post with ID: ${post['_id']}');
//
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return ConfirmDeleteDialog(
//           title: 'Delete Post?',
//           description:
//               'Are you sure you want to delete this Post? This cannot be undone.',
//           onDelete: () => deletePost(post['_id']).then((_) {}),
//           postDelete: getUsersPost,
//         );
//       },
//     );
//   }
//
//   void _togglePostView() {
//     setState(() {
//       showUsersPosts = !showUsersPosts;
//       if (showUsersPosts) {
//         getUsersPost();
//       } else {
//         getPosts();
//       }
//     });
//   }
//
//   void _showActionSheet(BuildContext context) {
//     showCupertinoModalPopup(
//       context: context,
//       builder: (BuildContext context) => CupertinoActionSheet(
//         title: const Text('Actions'),
//         actions: <CupertinoActionSheetAction>[
//           CupertinoActionSheetAction(
//             isDestructiveAction: false,
//             onPressed: () {
//               Navigator.pop(context);
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => ShareYourStoryPage()),
//               );
//             },
//             child: const Text('Create a new post'),
//           ),
//           CupertinoActionSheetAction(
//             onPressed: () {
//               Navigator.pop(context);
//               _togglePostView();
//             },
//             child: const Text('View All My Posts'),
//           ),
//         ],
//         cancelButton: CupertinoActionSheetAction(
//           onPressed: () {
//             Navigator.pop(context);
//           },
//           child: const Text(
//             'Cancel',
//             style: TextStyle(
//               color: Colors.redAccent,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   void _editPostActionSheet(BuildContext context, int index) {
//     showCupertinoModalPopup(
//       context: context,
//       builder: (BuildContext context) => CupertinoActionSheet(
//         title: const Text('Actions'),
//         actions: <CupertinoActionSheetAction>[
//           CupertinoActionSheetAction(
//             isDestructiveAction: true,
//             onPressed: () {
//               Navigator.pop(context);
//               if (isUserPost) {
//                 _confirmDeletePost(index);
//               } else {
//                 _confirmReportPost(index);
//               }
//             },
//             child: isUserPost
//                 ? const Text('Delete Post')
//                 : const Text('Report Post'),
//           ),
//         ],
//         cancelButton: CupertinoActionSheetAction(
//           onPressed: () {
//             Navigator.pop(context); // Close the action sheet
//           },
//           child: const Text(
//             'Cancel',
//             style: TextStyle(
//                 // color: Colors.redAccent,
//                 ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   void _confirmReportPost(int index) {
//     final post = posts[index];
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return ConfirmDeleteDialog(
//           title: 'Report Post?',
//           description: 'Are you sure you want to Report this Post? ',
//           onDelete: () => deletePost(post['_id']).then(
//             (_) {},
//           ),
//           postDelete: getPosts,
//         );
//       },
//     );
//   }
// }
