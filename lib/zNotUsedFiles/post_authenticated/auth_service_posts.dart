import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_project/AuthService/preferences.dart';

import '../../AuthService/base_url.dart';

class PostsService {
  // Fetch posts from the API

  static Future<List<Map<String, dynamic>>> getPosts() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/getAllPosts');
    String? token = await getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Token is missing');
    }

    try {
      final response = await http.get(
        url,
        headers: <String, String>{
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Ensure the response contains a 'posts' key
        if (data is Map<String, dynamic> && data.containsKey('posts')) {
          List<Map<String, dynamic>> posts =
              List<Map<String, dynamic>>.from(data['posts']);

          // Add 'timeAgo' to each post
          posts = posts.map((post) {
            if (post.containsKey('createdAt')) {
              try {
                final DateTime postDate = DateTime.parse(post['createdAt']);
                post['timeAgo'] = _formatDateTime(postDate);
              } catch (e) {
                post['timeAgo'] = 'Invalid date';
              }
            } else {
              post['timeAgo'] = 'Unknown time';
            }
            return post;
          }).toList();

          return posts; // Return only the posts as a list
        } else {
          throw Exception(
              'Unexpected response structure: No "posts" key found');
        }
      } else if (response.statusCode == 404) {
        throw Exception('No posts found');
      } else {
        throw Exception(
            'Failed to load posts, status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching posts: $e');
    }
  }

  static Future<Map<String, dynamic>> fetchUsersPosts() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    if (userId == null) {
      throw Exception('User ID not found in shared preferences');
    }

    final url = Uri.parse('${ApiConfig.baseUrl}/getAllPosts/$userId/posts');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // Ensure the response contains both 'username' and 'posts'
      if (data is Map<String, dynamic> &&
          data.containsKey('username') &&
          data.containsKey('posts')) {
        List<Map<String, dynamic>> posts =
            List<Map<String, dynamic>>.from(data['posts']);

        // Add 'timeAgo' to each post
        posts = posts.map((post) {
          if (post.containsKey('createdAt')) {
            final DateTime postDate = DateTime.parse(post['createdAt']);
            post['timeAgo'] = _timeAgo(postDate);
          } else {
            post['timeAgo'] = 'Unknown time';
          }
          return post;
        }).toList();

        return {
          'username': data['username'],
          'posts': posts,
        };
      } else {
        throw Exception('Unexpected response structure');
      }
    } else if (response.statusCode == 404) {
      throw Exception('User not found');
    } else {
      throw Exception('Failed to load posts');
    }
  }

  static String _timeAgo(DateTime dateTime) {
    final Duration difference = DateTime.now().difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  static String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

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
  }

  static String _monthName(int month) {
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

  static Future<void> deleteAPost(String postId) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/deletePost/$postId');
    print('Sending DELETE request to: $url');

    final response = await http.delete(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      print('Post with ID $postId deleted successfully.');
    } else {
      final responseBody = jsonDecode(response.body);
      print('Failed to delete appliance. Server response: ${response.body}');
      throw Exception('Failed to delete appliance: ${responseBody['message']}');
    }
  }

  static Future<void> deletePost(String postId) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/posts/$postId');
    final response = await http.delete(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    if (response.statusCode == 200) {
      print('Post deleted successfully');
    } else {
      final responseBody = jsonDecode(response.body);
      throw Exception('Failed to delete Post: ${responseBody['message']}');
    }
  }
  // It's almost 3am and I still couldn't figure out how to add suggestions to the specific post hays kapoy na.

  // Helper method to calculate "time ago"

  static Future<List<Map<String, dynamic>>> getPostsOld() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/getAllPosts');
    final response = await http.get(url, headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    });

    if (response.statusCode == 200) {
      List<dynamic> fetchedPosts = jsonDecode(response.body)['posts'] ?? [];

      return fetchedPosts.map<Map<String, dynamic>>((post) {
        DateTime createdAt = DateTime.parse(post['createdAt']);
        String timeAgo = _timeAgo(createdAt);
        return {
          'title': post['title'] ?? 'No title',
          'description': post['description'] ?? 'No description',
          'tags': post['tags'] ?? 'No tags',
          'imagePath': 'assets/image (6).png',
          'timeAgo': timeAgo,
          'username': post['userId'] != null
              ? post['userId']['username']
              : 'Unknown user',
        };
      }).toList();
    } else {
      throw Exception('Failed to load Posts');
    }
  }
}
