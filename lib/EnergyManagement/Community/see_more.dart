import 'package:flutter/material.dart';

class CustomReadMoreText extends StatefulWidget {
  final String text;
  final int trimLines;
  final String trimCollapsedText;
  final String trimExpandedText;
  final TextStyle moreStyle;
  final Color colorClickableText;

  const CustomReadMoreText({
    Key? key,
    required this.text,
    this.trimLines = 2,
    this.trimCollapsedText = 'Show more',
    this.trimExpandedText = 'Show less',
    this.moreStyle = const TextStyle(color: Colors.blue),
    this.colorClickableText = Colors.redAccent,
  }) : super(key: key);

  @override
  _CustomReadMoreTextState createState() => _CustomReadMoreTextState();
}

class _CustomReadMoreTextState extends State<CustomReadMoreText> {
  late bool _isExpanded;
  late bool isShowMoreDisplayed;

  @override
  void initState() {
    super.initState();
    _isExpanded = false;
    isShowMoreDisplayed = _checkIfShowMoreNeeded();
  }

  bool _checkIfShowMoreNeeded() {
    final textPainter = TextPainter(
      text: TextSpan(text: widget.text, style: TextStyle()),
      maxLines: widget.trimLines,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout(maxWidth: double.infinity);
    return textPainter.didExceedMaxLines;
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final textWidget = Text(
      widget.text,
      maxLines: _isExpanded ? null : widget.trimLines,
      overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        textWidget,
        if (isShowMoreDisplayed)
          GestureDetector(
            onTap: _toggleExpanded,
            child: Text(
              _isExpanded ? widget.trimExpandedText : widget.trimCollapsedText,
              style: widget.moreStyle,
            ),
          ),
      ],
    );
  }
}
