class WordData {
  final String word;
  final String phonetic;
  final List<Phonetic> phonetics;
  final String origin;
  final List<Meaning> meanings;

  WordData({
    required this.word,
    required this.phonetic,
    required this.phonetics,
    required this.origin,
    required this.meanings,
  });
}

class Phonetic {
  final String text;
  final String? audio;

  Phonetic({required this.text, this.audio});
}

class Meaning {
  final String partOfSpeech;
  final List<Definition> definitions;

  Meaning({required this.partOfSpeech, required this.definitions});
}

class Definition {
  final String definition;
  final String example;
  final List<String> synonyms;
  final List<String> antonyms;

  Definition({
    required this.definition,
    required this.example,
    required this.synonyms,
    required this.antonyms,
  });
}