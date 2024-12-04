import 'package:flutter/material.dart';

String placeholderImage = 'assets/image (6).png';

class PostImage extends StatelessWidget {
  final String postImageUrl;

  const PostImage({Key? key, required this.postImageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String validPostImageUrl =
        postImageUrl.isNotEmpty ? postImageUrl : placeholderImage;
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.network(
        validPostImageUrl,
        width: double.infinity,
        height: 200.0,
        fit: BoxFit.cover,
        errorBuilder:
            (BuildContext context, Object error, StackTrace? stackTrace) {
          return Image.asset(
            placeholderImage,
            width: double.infinity,
            height: 200.0,
            fit: BoxFit.cover,
          );
        },
      ),
    );
  }
}
