import 'package:flutter/material.dart';

import '../AuthService/auth_service_posts.dart';
import '../CommonWidgets/appliance_container/snack_bar.dart';
import 'package:hive/hive.dart';

class PostsProvider with ChangeNotifier {
  List<Map<String, dynamic>> _posts = [];

  List<Map<String, dynamic>> get posts => _posts;

  Future<void> getPostsFromApi() async {
    final fetchedPosts = await fetchPostsFromApi();
    _posts = fetchedPosts;
    notifyListeners();
  }
}

Future<List<Map<String, dynamic>>> fetchPostsFromApi() async {
  try {
    // Fetch posts directly from the API
    final List<Map<String, dynamic>>? fetchedPosts =
        await PostsService.getPosts();
    print('Fetched all posts: $fetchedPosts');

    if (fetchedPosts != null && fetchedPosts.isNotEmpty) {
      // Optionally, save the posts in Hive for future use
      var box = await Hive.openBox('postsBox');
      await box.put('allPosts', fetchedPosts);

      // Fetch suggestions for each post (only if 'id' is not null)
      for (var post in fetchedPosts) {
        String? postId = post['id']; // Assuming the post has an 'id' field

        if (postId != null) {
          // Fetch suggestions for each post with a valid 'id'
          // await fetchSuggestions(postId);
        } else {
          print('Skipping post with null id');
        }
      }
    } else {
      throw Exception('No posts found or invalid post data format.');
    }
  } catch (e) {
    print('Failed to fetch posts: $e');
  }
  return [];
}
