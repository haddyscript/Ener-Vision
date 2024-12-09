import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_project/AuthService/base_url.dart';

import '../../AuthService/services/user_data.dart';


class PostsProvider with ChangeNotifier {
  List<Map<String, dynamic>> _posts = [];
  bool _isLoading = false;

  List<Map<String, dynamic>> get posts => _posts;
  bool get isLoading => _isLoading;

  // Load posts from API
  Future<void> loadPosts() async {
    _isLoading = true;
    notifyListeners();

    try {
      String? token = await getToken();
      if (token == null) throw Exception('Token is null. Failed to authenticate.');

      final url = Uri.parse('${ApiConfig.baseUrl}/getAllPosts');
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map<String, dynamic> && data.containsKey('posts')) {
          _posts = List<Map<String, dynamic>>.from(data['posts']);

          // Add 'timeAgo' and sort posts
          _posts = _posts.map((post) {
            if (post.containsKey('createdAt')) {
              final DateTime postDate = DateTime.parse(post['createdAt']);
              post['timeAgo'] = _timeAgo(postDate);
            } else {
              post['timeAgo'] = 'Unknown time';
            }

            // Handle suggestions
            if (post.containsKey('suggestions')) {
              post['suggestions'] = (post['suggestions'] as List).map((suggestion) {
                return {
                  'id': suggestion['id'],
                  'content': suggestion['content'],
                  'suggestionText': suggestion['suggestionText'] ?? '',
                  'suggestedBy': suggestion['suggestedBy'] ?? 'Unknown',
                  'createdAt': suggestion['createdAt'] ?? ''
                };
              }).toList();
            }

            return post;
          }).toList();

          // Sort posts by `createdAt` (latest to oldest)
          _posts.sort((a, b) {
            DateTime timestampA = DateTime.parse(a['createdAt']);
            DateTime timestampB = DateTime.parse(b['createdAt']);
            return timestampB.compareTo(timestampA); // Latest first
          });

          // Save posts to Hive
          var box = await Hive.openBox('postsBox');
          await box.put('allPosts', _posts);
        } else {
          throw Exception('Unexpected response structure');
        }
      } else if (response.statusCode == 404) {
        throw Exception('No posts found');
      } else {
        throw Exception('Failed to load posts: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading posts: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load posts from Hive
  Future<void> loadPostsFromHive() async {
    _isLoading = true;
    notifyListeners();

    try {
      var box = await Hive.openBox('postsBox');
      if (box.containsKey('allPosts')) {
        _posts = List<Map<String, dynamic>>.from(box.get('allPosts'));

        // Sort posts by `createdAt` (latest to oldest)
        _posts.sort((a, b) {
          DateTime timestampA = DateTime.parse(a['createdAt']);
          DateTime timestampB = DateTime.parse(b['createdAt']);
          return timestampB.compareTo(timestampA); // Latest first
        });
      }
    } catch (e) {
      print('Error loading posts from Hive: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Format date as time ago
  String _timeAgo(DateTime date) {
    final duration = DateTime.now().difference(date);
    if (duration.inDays >= 1) {
      return '${duration.inDays} day(s) ago';
    } else if (duration.inHours >= 1) {
      return '${duration.inHours} hour(s) ago';
    } else if (duration.inMinutes >= 1) {
      return '${duration.inMinutes} minute(s) ago';
    } else {
      return 'Just now';
    }
  }
}
