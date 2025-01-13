import 'dart:convert';
import 'package:http/http.dart' as http;
import 'models.dart';

class DictionaryService {
  static Future<WordData> fetchWord(String word) async {
    final response = await http.get(Uri.parse('https://api.dictionaryapi.dev/api/v2/entries/en/$word'));

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body)[0];

      // Extract phonetics
      List<Phonetic> phonetics = (data['phonetics'] as List)
          .map((phonetic) => Phonetic(
                text: phonetic['text'],
                audio: phonetic['audio'],
              ))
          .toList();

      // Extract meanings
      List<Meaning> meanings = (data['meanings'] as List)
          .map((meaning) => Meaning(
                partOfSpeech: meaning['partOfSpeech'],
                definitions: (meaning['definitions'] as List)
                    .map((def) => Definition(
                          definition: def['definition'],
                          example: def['example'] ?? '', // Handle optional example
                          synonyms: (def['synonyms'] as List).map((syn) => syn.toString()).toList(),
                          antonyms: (def['antonyms'] as List).map((ant) => ant.toString()).toList(),
                        ))
                    .toList(),
              ))
          .toList();

      return WordData(
        word: word,
        phonetic: data['phonetic'] ?? '',
        phonetics: phonetics,
        origin: data['origin'] ?? '',
        meanings: meanings,
      );
    } else {
      throw Exception('Failed to load word data');
    }
  }
}