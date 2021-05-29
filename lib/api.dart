import 'dart:convert';

import 'package:flutter_genbog/info.dart';
import 'package:http/http.dart' as http;

class APIResult<T> {
  T? _value;
  String? _error;

  APIResult.success(T value) {
    _value = value;
  }

  APIResult.failure(String error) {
    _error = error;
  }

  String? get error {
    return _error;
  }

  T? get value {
    return _value;
  }
}

class ISBNResult {
  late String _isbn;
  late int _count;

  ISBNResult(String isbn, int count) {
    _isbn = isbn;
    _count = count;
  }

  String get isbn {
    return _isbn;
  }

  int get count {
    return _count;
  }
}

class API {
  static String authority = "api.feodor.dk";

  static Future<APIResult<Iterable<ISBNResult>>> getBooks() async {
    var response = await http.get(Uri.https(authority, "/books"));
    var isbns = jsonDecode(response.body) as List<dynamic>;
    var results = isbns.map((isbn) => ISBNResult(isbn['isbn'], isbn['count']));
    return APIResult<Iterable<ISBNResult>>.success(results);
  }

  static Future<APIResult<Iterable<ISBNResult>>> postBooks(Iterable<BookInfo> bookInfos) async {
    var headers = Map<String, String>();
    headers['Content-Type'] = 'application/json';
    var response = await http.post(Uri.https(authority, "/books"),
        headers: headers, body: jsonEncode(bookInfos.map((b) => b.isbn).toList()));
    
    if (response.statusCode == 200) {
      var isbns = jsonDecode(response.body) as List<dynamic>;
      var results = isbns.map((isbn) => ISBNResult(isbn['isbn'], isbn['count']));
      return APIResult.success(results);
    } else {
      return APIResult.failure("POST failed");
    }
  }

  static Future<APIResult<ISBNResult>> deleteBook(BookInfo bookInfo) async {
    var response = await http.delete(Uri.https(authority, "/books/${bookInfo.isbn}"));
    
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body) as Map<String, dynamic>;
      var result = ISBNResult(data['isbn'], data['count']);
      return APIResult.success(result);
    } else {
      return APIResult.failure("DELETE failed");
    }
  }
}
