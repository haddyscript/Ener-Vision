import 'package:flutter/material.dart';

class SuggestionTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String imagePath;
  final double imageWidth;
  final double imageHeight;
  final Color borderColor;
  final Color iconColor;
  final Color backgroundColor;
  final VoidCallback? onSend;

  const SuggestionTextField({
    Key? key,
    required this.controller,
    this.hintText = 'Suggest changes or additional tips...',
    this.imagePath = 'assets/suggestion.png',
    this.imageWidth = 50.0,
    this.imageHeight = 50.0,
    this.borderColor = const Color(0xFFE0E0E0),
    this.iconColor = const Color(0xFF1BBC9B),
    this.backgroundColor = Colors.white,
    this.onSend,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(18.0),
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(7.0),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 2.0),
            child: Image(
              image: AssetImage(imagePath),
              width: imageWidth,
              height: imageHeight,
            ),
          ),
          const SizedBox(width: 5.0),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hintText,
                hintStyle: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12.0,
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.send_rounded,
              color: iconColor,
              size: 24,
            ),
            onPressed: () {
              if (controller.text.isNotEmpty && onSend != null) {
                onSend!();
              }
            },
          ),
        ],
      ),
    );
  }
}

class Avatar extends StatelessWidget {
  final String profileImageUrl;
  final String placeholderImage;
  final double radius;
  final double imageSize;

  const Avatar({
    Key? key,
    required this.profileImageUrl,
    this.placeholderImage = 'assets/placeholder.png',
    this.radius = 20.0,
    this.imageSize = 40.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String validProfileImageUrl =
        profileImageUrl.isNotEmpty ? profileImageUrl : placeholderImage;

    return CircleAvatar(
      radius: radius,
      backgroundImage: NetworkImage(validProfileImageUrl),
      child: ClipOval(
        child: Image.network(
          validProfileImageUrl,
          width: imageSize,
          height: imageSize,
          fit: BoxFit.cover,
          errorBuilder:
              (BuildContext context, Object error, StackTrace? stackTrace) {
            return Image.asset(
              placeholderImage,
              width: imageSize,
              height: imageSize,
              fit: BoxFit.cover,
            );
          },
        ),
      ),
    );
  }
}

class TitleTags extends StatelessWidget {
  final String title;
  final String tags;
  const TitleTags({super.key, required this.title, required this.tags});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitle(title),
        const SizedBox(height: 4.0),
        _buildTags(tags),
      ],
    );
  }

  Widget _buildTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        fontFamily: 'Montserrat',
      ),
    );
  }

  Widget _buildTags(String tags) {
    return Text(
      tags,
      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
    );
  }

  Widget _buildIcon(int index) {
    return GestureDetector(
        onTap: () {
          // _editPostActionSheet(context, index);
        },
        child: const Icon(Icons.more_vert));
  }
}
