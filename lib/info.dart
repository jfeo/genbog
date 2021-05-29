

import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class BookInfo {
  String? _title;
  List<AuthorInfo> _authors = [];
  String _isbn = "";
  Uint8List? _thumbnailData;

  Uint8List? get thumbnailData {
    return _thumbnailData;
  }

  String get isbn {
    return _isbn;
  }

  String? get title {
    return _title;
  }

  List<AuthorInfo> get authors {
    return _authors;
  }


  BookInfo(String isbn, { String? title, List<AuthorInfo> authors = const [] }) {
    _isbn = isbn;
    _title = title;
    _authors = authors;
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
    var authorFutures = details.containsKey('authors') ? (details['authors'] as List<dynamic>).map((author) {
      return AuthorInfo.fetch(author['key'] as String);
    }) : <Future<AuthorInfo>>[];

    var authors = <AuthorInfo>[];
    for (var author in (await Future.wait(authorFutures))) {
      if (author != null) {
        authors.add(author);
      }
    }

    var book = BookInfo(isbn, title: title, authors: authors);

    if (bookData.containsKey('thumbnail_url')) {
      var thumbnailData =
          await http.readBytes(Uri.parse(bookData['thumbnail_url']));
      book._thumbnailData = thumbnailData;
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