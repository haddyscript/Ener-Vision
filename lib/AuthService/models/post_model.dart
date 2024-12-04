import 'package:hive/hive.dart';
import 'package:supabase_project/AuthService/models/hive_model.dart';

@HiveType(typeId: 1)
class Post {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final String description;
  @HiveField(3)
  final String tags;
  @HiveField(4)
  final User userId;
  @HiveField(5)
  final List<String> suggestions; // Store as list of strings (IDs)
  @HiveField(6)
  final DateTime createdAt;
  @HiveField(7)
  final DateTime updatedAt;

  Post({
    required this.id,
    required this.title,
    required this.description,
    required this.tags,
    required this.userId,
    required this.suggestions,
    required this.createdAt,
    required this.updatedAt,
  });
}
