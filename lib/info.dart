

import 'dart:convert';
import 'package:http/http.dart' as http;

class BookInfo {
  String? _title;
  String? _subtitle;
  List<AuthorInfo> _authors = [];
  String _isbn = "";
  Uri? _thumbnail;
  List<Uri> _covers = <Uri>[];

  Uri? get thumbnail {
    return _thumbnail;
  }

  String get isbn {
    return _isbn;
  }

  String? get title {
    return _title;
  }

  String? get subtitle {
    return _subtitle;
  }

  List<AuthorInfo> get authors {
    return _authors;
  }

  List<Uri> get covers {
    return _covers;
  }

  BookInfo(String isbn, { String? title, String? subtitle, List<AuthorInfo> authors = const [], List<Uri> covers = const [] }) {
    _isbn = isbn;
    _title = title;
    _subtitle = subtitle;
    _authors = authors;
    _covers = covers;
  }

  static Future<BookInfo> fetch(String isbn) async {
    var url = Uri.parse(
        'https://openlibrary.org/api/books?bibkeys=ISBN:$isbn&jscmd=details&format=json');
    var resp = await http.get(url);

    if (resp.statusCode != 200) {
      return BookInfo(isbn);
    }

    var json = jsonDecode(resp.body);
    if (!json.containsKey('ISBN:$isbn')) {
      return BookInfo(isbn);
    }

    var bookData = json['ISBN:$isbn'] as Map<String, dynamic>;
    var details = bookData['details'] as Map<String, dynamic>;
    var title = details['title'] as String;
    List<Uri> covers = [];
    for (int id in details['covers'] ?? []) {
      covers.add(Uri.parse("http://covers.openlibrary.org/b/id/$id-L.jpg"));
    }
    var authorFutures = details.containsKey('authors') ? (details['authors'] as List<dynamic>).map((author) {
      return AuthorInfo.fetch(author['key'] as String);
    }) : <Future<AuthorInfo>>[];

    var authors = <AuthorInfo>[];
    for (var author in (await Future.wait(authorFutures))) {
      if (author != null) {
        authors.add(author);
      }
    }

    var book = BookInfo(isbn, title: title, authors: authors, covers: covers);

    if (bookData.containsKey('thumbnail_url')) {
      book._thumbnail = Uri.parse(bookData['thumbnail_url']);
    }

    return book;
  }
}

class AuthorInfo {
  String _name = "";

  String get name {
    return _name;
  }

  AuthorInfo(String name) {
    _name = name;
  }

  static Future<AuthorInfo?> fetch(String key) async {
    var url = Uri.parse('https://openlibrary.org/$key.json');
    var resp = await http.get(url);

    if (resp.statusCode != 200) {
      return null;
    }

    var json = jsonDecode(resp.body);
    var name = json['name'] as String;

    return AuthorInfo(name);
  }
}