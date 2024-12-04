import 'package:flutter/material.dart';
import 'package:readmore/readmore.dart';
import 'package:supabase_project/ConstantTexts/colors.dart';

class BuildIcon extends StatelessWidget {
  final int index;
  final Function(int) onTap; // Accepts a callback function to handle tap events

  const BuildIcon({
    Key? key,
    required this.index,
    required this.onTap, // Make this parameter required
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(index), // Use the callback when tapped
      child: const Icon(Icons.more_vert),
    );
  }
}

class BuildIconNew extends StatelessWidget {
  final Function(int) onTap; // Accepts a callback function to handle tap events

  const BuildIconNew({
    Key? key,
    required this.onTap, // Make this parameter required
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // onTap: () => onTap(index), // Use the callback when tapped
      child: const Icon(Icons.more_vert),
    );
  }
}

class BuildTitle extends StatelessWidget {
  final String title;

  const BuildTitle({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          fontFamily: 'Montserrat',
        ),
      ),
    );
  }
}

class BuildTags extends StatelessWidget {
  final String tags;

  const BuildTags({Key? key, required this.tags}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10.0),
      child: Text(
        tags,
        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
      ),
    );
  }
}

class TagsAndTitle extends StatelessWidget {
  final String tags;
  final String title;

  const TagsAndTitle({super.key, required this.tags, required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [BuildTitle(title: title), BuildTags(tags: tags)],
    );
  }
}

class BuildTitleTags extends StatelessWidget {
  final String title;
  final String tags;

  const BuildTitleTags({Key? key, required this.title, required this.tags})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BuildTitle(title: title),
        BuildTags(tags: tags),
      ],
    );
  }
}

class BuildDescription extends StatelessWidget {
  final String description;

  const BuildDescription({Key? key, required this.description})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 30, left: 10, right: 10),
      child: ReadMoreText(
        description,
        trimLines: 3,
        trimMode: TrimMode.Line,
        trimCollapsedText: 'Show more',
        trimExpandedText: 'Show less',
        colorClickableText: AppColors.primaryColor,
        moreStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryColor,
        ),
      ),
    );
  }
}

String placeholderImage = 'assets/image (6).png';

class BuildAvatar extends StatelessWidget {
  final String profileImageUrl;

  const BuildAvatar({Key? key, required this.profileImageUrl})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String validProfileImageUrl =
        profileImageUrl.isNotEmpty ? profileImageUrl : placeholderImage;
    return CircleAvatar(
      radius: 20.0,
      backgroundImage: NetworkImage(validProfileImageUrl),
      child: ClipOval(
        child: Image.network(
          validProfileImageUrl,
          width: 40.0,
          height: 40.0,
          fit: BoxFit.cover,
          errorBuilder:
              (BuildContext context, Object error, StackTrace? stackTrace) {
            return Image.asset(
              placeholderImage,
              fit: BoxFit.cover,
            );
          },
        ),
      ),
    );
  }
}
