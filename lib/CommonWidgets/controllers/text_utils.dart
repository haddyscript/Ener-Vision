String toTitleCase(String str) {
  return str.split(' ').map((word) {
    if (word.length > 1) {
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    } else {
      return word.toUpperCase();
    }
  }).join(' ');
}

String toSentenceCase(String str) {
  return str[0].toUpperCase() + str.substring(1).toLowerCase();
}

String capitalizeFirstLetter(String str) {
  if (str.isEmpty) return str;
  return str[0].toUpperCase() + str.substring(1);
}

String capitalizeSentences(String str) {
  if (str.isEmpty) return str;
  List<String> sentences = str.split(RegExp(r'(?<=[.!?])\s*'));
  for (int i = 0; i < sentences.length; i++) {
    String sentence = sentences[i];
    if (sentence.isNotEmpty) {
      sentences[i] = sentence[0].toUpperCase() + sentence.substring(1);
    }
  }
  return sentences.join(' ');
}

String capitalizeWords(String str) {
  return str.replaceAllMapped(RegExp(r'\b\w'), (match) {
    return match.group(0)!.toUpperCase();
  });
}
