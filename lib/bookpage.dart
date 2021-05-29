import 'package:flutter/material.dart';

import 'info.dart';

class BookPage extends StatefulWidget {
  late final BookInfo _book;

  BookPage(BookInfo book) {
    _book = book;
  }

  @override
  State<StatefulWidget> createState() {
    return _BookPageState();
  }
}

class _BookPageState extends State<BookPage> {
  @override
  Widget build(BuildContext context) {
    var book = widget._book;

    return Scaffold(
        appBar: AppBar(
            title: Column(children: [
          Row(children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.antiAliasWithSaveLayer,
                child: Text(
                  book.title ?? "Ukendt titel",
                  overflow: TextOverflow.fade,
                ),
              ),
            ),
          ]),
          Row(
            children: book.authors
                .map((a) => Container(
                      margin: EdgeInsets.only(right: 12),
                      child: Text(a.name, style: TextStyle(fontSize: 16)),
                    ))
                .toList(),
          )
        ])),
        body: Column(
          children: book.covers.map((uri) => Image.network(uri.toString())).toList(),
        ));
  }
}
