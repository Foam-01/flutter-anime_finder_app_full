
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() => runApp(AnimeFinderApp());

class AnimeFinderApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Anime Finder',
      home: SearchPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _searchController = TextEditingController();
  String _selectedGenre = 'Fantasy';

  final List<String> genres = ['Fantasy', 'Drama', 'Action', 'Comedy'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Search Anime')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(children: [
            TextFormField(
              controller: _searchController,
              decoration: InputDecoration(labelText: 'Search Anime'),
              validator: (value) =>
                  value == null || value.isEmpty ? 'Enter a keyword' : null,
            ),
            SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _selectedGenre,
              onChanged: (val) => setState(() => _selectedGenre = val!),
              items: genres
                  .map((g) =>
                      DropdownMenuItem(value: g, child: Text(g)))
                  .toList(),
              decoration: InputDecoration(labelText: 'Select Genre'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => AnimeListPage(
                                searchQuery: _searchController.text,
                                genre: _selectedGenre,
                              )));
                }
              },
              child: Text('Search'),
            ),
          ]),
        ),
      ),
    );
  }
}

class AnimeListPage extends StatelessWidget {
  final String searchQuery;
  final String genre;

  AnimeListPage({required this.searchQuery, required this.genre});

  Future<List<dynamic>> fetchAnime() async {
    final url =
        Uri.https('anime-db.p.rapidapi.com', '/anime', {
          'page': '1',
          'size': '10',
          'search': searchQuery,
          'genres': genre,
          'sortBy': 'ranking',
          'sortOrder': 'asc'
        });

    final response = await http.get(url, headers: {
      'x-rapidapi-key': 'e02856a639msh0b7aaf7fbc23208p1db95ejsnfa807ce59621',
      'x-rapidapi-host': 'anime-db.p.rapidapi.com',
    });

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return jsonData['data'];
    } else {
      throw Exception('Failed to load anime');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Results')),
        body: FutureBuilder<List<dynamic>>(
            future: fetchAnime(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting)
                return Center(child: CircularProgressIndicator());
              if (snapshot.hasError)
                return Center(child: Text('Error: ${snapshot.error}'));

              final data = snapshot.data!;
              return ListView.builder(
                itemCount: data.length,
                itemBuilder: (_, index) {
                  final anime = data[index];
                  return Container(
                    margin: EdgeInsets.all(8.0),
                    child: Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: Image.network(
                          anime['image'],
                          width: 50,
                          fit: BoxFit.cover,
                        ),
                        title: Text(anime['title']),
                        subtitle: Text('Ranking: ${anime['ranking']}'),
                      ),
                    ),
                  );
                },
              );
            }));
  }
}
