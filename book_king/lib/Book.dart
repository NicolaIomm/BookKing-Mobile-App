import 'dart:convert';

Book bookFromJson(String str) => Book.fromJson(json.decode(str));
String bookToJson(Book data) => json.encode(data.toJson());

class Book {
  String id;
  String userid;
  String title;
  String author;
  String genre;
  String year;
  String isbn;
  String lat;
  String lon;
  int distance;

  Book({
    this.id,
    this.userid,
    this.title,
    this.author,
    this.genre,
    this.year,
    this.isbn,
    this.lat,
    this.lon,
    this.distance,
  });

  factory Book.fromJson(Map<String, dynamic> json) => Book(
    id: json["id"],
    userid: json["userid"],
    title: json["title"],
    author: json["author"],
    genre: json["genere"],
    year: json["year"],
    isbn: json["ISBN"],
    lat: json["lat"],
    lon: json["lon"],
    distance: json["distance"]
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "userid": userid,
    "title": title,
    "author": author,
    "genere": genre,
    "year": year,
    "isbn": isbn,
    "lat": lat,
    "lon": lon,
    "distance": distance
  };
}