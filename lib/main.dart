import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart'; // Import url_launcher
import 'dictionary_service.dart';
import 'models.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => DictionaryProvider(),
      child: MaterialApp(
        title: 'Dictionary by nehalmr',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: DictionaryHome(),
      ),
    );
  }
}

class DictionaryHome extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DictionaryProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Dictionary by nehalmr'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Text(
                'Dictionary by nehalmr',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
            ),
            ListTile(
              title: Text('Home'),
              onTap: () {
                Navigator.of(context).pop(); // Close the drawer
              },
            ),
            ListTile(
              title: Text('About Us'),
              onTap: () {
                Navigator.of(context).pop();
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('About Us'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Created by Mr. Nehal Mahendra Rane'),
                        SizedBox(height: 10),
                        Text('Connect with me:'),
                        TextButton(
                          onPressed: () => _launchURL('https://github.com/nehalmr'),
                          child: Text('GitHub'),
                        ),
                        TextButton(
                          onPressed: () => _launchURL('https://www.linkedin.com/in/nehalmr/'),
                          child: Text('LinkedIn'),
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text('Close'),
                      ),
                    ],
                  ),
                );
              },
            ),
            ListTile(
              title: Text('Feedback'),
              onTap: () {
                Navigator.of(context).pop();
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Feedback'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('We appreciate your feedback!'),
                        SizedBox(height: 10),
                        Text('Please let us know how we can improve on:'),
                        TextButton(
                          onPressed: () => _launchURL('https://www.linkedin.com/in/nehalmr/'),
                          child: Text('https://www.linkedin.com/in/nehalmr/'),
                        ),
                        TextButton(
                          onPressed: () => _launchURL('https://github.com/nehalmr/dictionary_by_nehalmr'),
                          child: Text('https://github.com/nehalmr/dictionary_by_nehalmr'),
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text('Close'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Enter a word',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    provider.fetchWordData(_controller.text);
                  },
                ),
              ),
            ),
            SizedBox(height: 20),
            if (provider.isLoading) CircularProgressIndicator(),
            if (provider.errorMessage.isNotEmpty)
              Text(provider.errorMessage, style: TextStyle(color: Colors.red)),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    if (provider.wordData != null) WordDataDisplay(wordData: provider.wordData!),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Function to launch URL
  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}

class WordDataDisplay extends StatelessWidget {
  final WordData wordData;

  WordDataDisplay({required this.wordData});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Word: ${wordData.word}', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        Text('Phonetic: ${wordData.phonetic}', style: TextStyle(fontSize: 18)),
        if (wordData.phonetics.isNotEmpty)
          Text('Phonetics: ${wordData.phonetics.map((p) => p.text).join(', ')}'),
        Text('Origin: ${wordData.origin}', style: TextStyle(fontStyle: FontStyle.italic)),
        SizedBox(height: 10),
        for (var meaning in wordData.meanings)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Part of Speech: ${meaning.partOfSpeech}', style: TextStyle(fontWeight: FontWeight.bold)),
                for (var definition in meaning.definitions)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Definition: ${definition.definition}'),
                      if (definition.example.isNotEmpty) Text('Example: ${definition.example}', style: TextStyle(fontStyle: FontStyle.italic)),
                      Text('Synonyms: ${definition.synonyms.isNotEmpty ? definition.synonyms.join(', ') : 'None'}'),
                      Text('Antonyms: ${definition.antonyms.isNotEmpty ? definition.antonyms.join(', ') : 'None'}'),
                      SizedBox(height: 5),
                    ],
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class DictionaryProvider extends ChangeNotifier {
  bool isLoading = false;
  String errorMessage = '';
  WordData? wordData;

  Future<void> fetchWordData(String word) async {
    isLoading = true;
    errorMessage = '';
    notifyListeners();

    try {
      wordData = await DictionaryService.fetchWord(word);
    } catch (e) {
      errorMessage = 'Error fetching data: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}