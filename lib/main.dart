import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'dart:convert';

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
        iconTheme: new IconThemeData(color: Colors.grey),
      ),
      drawer: Drawer(
        child: SafeArea(
          right: false,
          child: Center(
            child: Text('Drawer content'),
          ),
        ),
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
                    return Column(children: <Widget>[
                      Padding(
                          padding: EdgeInsets.all(5),
                          child: Container(
                              padding: EdgeInsets.all(46),
                              decoration: new BoxDecoration(
                                  image: new DecorationImage(
                                      image: new NetworkImage(
                                          snapshot.data[index].pictureUrl),
                                      fit: BoxFit.cover)))),
                      SizedBox(
                        width: 100,
                        child: FittedBox(
                          fit: BoxFit.fitWidth,
                          child: Text(snapshot.data[index].title),
                        ),
                      ),
                    ]);
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
    return parseBrandThemeData(response.body);
    //List of images, somehow. loop through and create list of brand themes?
  } else {
    throw Exception('Failed to load content');
  }
}

List<BrandTheme> parseBrandThemeData(String responseBody) {
  // get json array with brand themes
  print('parsing brand theme response c');
  var themes = json.decode(responseBody)['themes'] as List;
  List<BrandTheme> brandThemes =
      themes.map((themeJson) => BrandTheme.fromJson(themeJson)).toList();
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
