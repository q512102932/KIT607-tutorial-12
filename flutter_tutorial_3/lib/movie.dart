import 'dart:collection';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Movie {
  String id;
  String title;
  int year;
  num duration;
  String image;

  Movie({this.title, this.year, this.duration, this.image});

  Movie.fromJson(Map<String, dynamic> json)
      : title = json['title'],
        year = json['year'],
        duration = json['duration'];

  Map<String, dynamic> toJson() =>
      {'title': title, 'year': year, 'duration': duration};
}

class MovieModel extends ChangeNotifier {
  /// Internal, private state of the list.
  final List<Movie> items = [];

  CollectionReference moviesCollection =
      FirebaseFirestore.instance.collection('movies');

  bool loading = false;

  //Normally a model would get from a database here, we are just hardcoding some data for this week
  MovieModel() {
    fetch();
  }

  void fetch() async {
    items.clear();

    loading = true;
    notifyListeners();

    var querySnapshot = await moviesCollection.orderBy("title").get();

    querySnapshot.docs.forEach((doc) {
      var movie = Movie.fromJson(doc.data());
      movie.id = doc.id;
      items.add(movie);
    });

    await Future.delayed(Duration(seconds: 2));

    loading = false;
    notifyListeners();
  }

  void add(Movie item) async {
    loading = true;
    notifyListeners();

    await moviesCollection.add(item.toJson());

    await fetch();
  }

  void update(String id, Movie item) async{
    loading = true;
    notifyListeners();

    await moviesCollection.doc(id).set(item.toJson());

    await fetch();
  }

  void delete(String id) async
  {
    loading = true;
    notifyListeners();

    await moviesCollection.doc(id).delete();

    //refresh the db
    await fetch();
  }

  Movie get(String id) {
    if (id == null) return null;
    return items.firstWhere((movie) => movie.id == id);
  }
}
