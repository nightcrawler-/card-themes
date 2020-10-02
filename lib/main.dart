import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: NavigationHomeScreen(),
    );
  }
}

Future<List<String>> fetchGalleryData() async {
  try {
    final response = await http
        .get(
            'https://kaleidosblog.s3-eu-west-1.amazonaws.com/flutter_gallery/data.json')
        .timeout(Duration(seconds: 5));

    if (response.statusCode == 200) {
      return compute(parseGalleryData, response.body);
    } else {
      throw Exception('Failed to load');
    }
  } on SocketException catch (e) {
    throw Exception('Failed to load');
  }
}

List<String> parseGalleryData(String responseBody) {
  final parsed = List<String>.from(json.decode(responseBody));
  return parsed;
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

Future<List<BrandTheme>> fetchImages() async {
  final response = await http.get(
      'http://itsthebrand.com/brandAPI/mode.php?mode=getThemes&userid=22&page=1');

  if (response.statusCode == 200) {
    print('xxres: ' + response.statusCode.toString());

    return parseBrandThemeData(response.body);
    //List of images, somehow. loop through and create list of brand theme?
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load content');
  }
}

List<BrandTheme> parseBrandThemeData(String responseBody) {
  // get json array with brand themes
  print('parsing brand theme response c');
  var themes = json.decode(responseBody)['themes'] as List;
  //print(themes);
  List<BrandTheme> brandThemes =
      themes.map((themeJson) => BrandTheme.fromJson(themeJson)).toList();
  print(brandThemes);
  return brandThemes;
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
