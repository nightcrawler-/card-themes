import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'The Brand',
      home: NavigationHomeScreen(),
    );
  }
}

class NavigationHomeScreen extends StatefulWidget {
  @override
  _NavigationHomeScreenState createState() => _NavigationHomeScreenState();
}

class _NavigationHomeScreenState extends State<NavigationHomeScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('The Brand'),
        backgroundColor: Colors.white,
      ),
      body: Center(
        child: FutureBuilder<List<BrandTheme>>(
          future: fetchImages(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return GridView.builder(
                  itemCount: snapshot.data.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3),
                  itemBuilder: (context, index) {
                    return Padding(
                        padding: EdgeInsets.all(5),
                        child: Container(
                            decoration: new BoxDecoration(
                                image: new DecorationImage(
                                    image: new NetworkImage(
                                        snapshot.data[index].pictureUrl),
                                    fit: BoxFit.cover))));
                  });
            }
            return Center(child: CircularProgressIndicator());
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.videogame_asset),
            title: Text('Marketplace'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            title: Text('My Designs'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_movies),
            title: Text('Category 3'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            title: Text('Category 4'),
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}

class ImageGrid extends StatefulWidget {
  @override
  _ImageGridState createState() => _ImageGridState();
}

class _ImageGridState extends State<ImageGrid> {
  @override
  Widget build(BuildContext context) {
    return GridView.count(
        // Create a grid with 2 columns. If you change the scrollDirection to
        // horizontal, this produces 2 rows.
        crossAxisCount: 3,
        // Generate 100 widgets that display their index in the List.
        children: List.generate(100, (index) {
          return Center(
            child: Text(
              'Item $index',
              style: Theme.of(context).textTheme.headline5,
            ),
          );
        }));
  }
}

Future<List<BrandTheme>> fetchImages() async {
  final response = await http.get(
      'http://itsthebrand.com/brandAPI/mode.php?mode=getThemes&userid=22&page=1');

  log('xxres: ' + response.statusCode.toString());
  if (response.statusCode == 200) {
    log('response: ' + response.body);
    return compute(
        parseGalleryData,
        response
            .body); //List of images, somehow. loop through and create list of brand theme?
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load content');
  }
}

List<BrandTheme> parseGalleryData(String responseBody) {
  final parsed = List<BrandTheme>.from(json.decode(responseBody)['themes']);
  return parsed;
}

class BrandTheme {
  final String title;
  final String pictureUrl;

  BrandTheme({this.title, this.pictureUrl});

  factory BrandTheme.fromJson(Map<String, dynamic> json) {
    return BrandTheme(
      title: json['title'],
      pictureUrl: BASE_URL + json['picture'],
    );
  }
}

const String BASE_URL =
    "https://itsthebrand.com/taswira.php?width=500&height=500&quality=100&cropratio=1:1&image=/v/uploads/gallery/";
