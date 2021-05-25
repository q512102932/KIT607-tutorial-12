import 'package:flutter/material.dart';
import 'package:flutter_tutorial_3/movie_details.kt.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'movie.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final Future<FirebaseApp> _initialisation = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _initialisation,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return FullScreenText(text: "Something went wrong");
          }

          if (snapshot.connectionState == ConnectionState.done) {
            return ChangeNotifierProvider(
                create: (context) => MovieModel(),
                child: MaterialApp(
                    title: 'Database Tutorial',
                    theme: ThemeData(
                      primarySwatch: Colors.blue,
                    ),
                    home: MyHomePage(title: 'Database Tutorial')));
          }
          return FullScreenText(text: "Loading...");
        });
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<MovieModel>(builder: buildScaffold);
  }

  Scaffold buildScaffold(BuildContext context, MovieModel movieModel, _) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) {
                return MovieDetails();
              });
        },
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            //YOUR UI HERE
            if (movieModel.loading)
              CircularProgressIndicator()
            else
              Expanded(
                child: ListView.builder(
                    itemBuilder: (_, index) {
                      var movie = movieModel.items[index];
                      return Dismissible(
                        child: ListTile(
                          title: Text(movie.title),
                          subtitle: Text(movie.year.toString() +
                              " - " +
                              movie.duration.toString() +
                              " Minutes"),
                          leading: movie.image != null
                              ? Image.network(movie.image)
                              : null,
                          onTap: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return MovieDetails(id: movie.id);
                            }));
                          },
                        ),
                        background: Container(color: Colors.red),
                        key:ValueKey<int>(index),
                        onDismissed: (DismissDirection direction){
                          setState(() {
                            movieModel.delete(movie.id);
                          });
                        },
                      );
                    },
                    itemCount: movieModel.items.length),
              )
          ],
        ),
      ),
    );
  }
}

//A little helper widget to avoid runtime errors -- we can't just display a Text() by itself if not inside a MaterialApp, so this workaround does the job
class FullScreenText extends StatelessWidget {
  final String text;

  const FullScreenText({Key key, this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Directionality(
        textDirection: TextDirection.ltr,
        child: Column(children: [Expanded(child: Center(child: Text(text)))]));
  }
}
