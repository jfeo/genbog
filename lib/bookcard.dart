import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'bookpage.dart';
import 'info.dart';

class BookCard extends StatefulWidget {
  late final BookInfo _bookInfo;
  late final void Function(BookInfo) _deleteCallback;

  BookCard(BookInfo bookInfo, void Function(BookInfo) deleteCallback) {
    _bookInfo = bookInfo;
    _deleteCallback = deleteCallback;
  }

  @override
  _BookCardState createState() => _BookCardState();
}

class _BookCardState extends State<BookCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(4),
      child: InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return BookPage(widget._bookInfo);
          }));
        },
        child: Row(children: [
          Container(
            child: widget._bookInfo.thumbnail != null
                ? Image.network(widget._bookInfo.thumbnail.toString())
                : Icon(Icons.book),
            width: 25,
            margin: EdgeInsets.all(8)
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget._bookInfo.title ?? widget._bookInfo.isbn,
                    style: TextStyle(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.fade, softWrap: false, maxLines: 2),
                Row(
                    children: widget._bookInfo.authors
                        .map(
                          (author) => Container(
                            margin: EdgeInsets.fromLTRB(0, 0, 2, 0),
                            child: Text(
                              author.name,
                              style: Theme.of(context).textTheme.bodyText2,
                            ),
                          ),
                        )
                        .toList())
              ],
            ),
          ),
          IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  widget._deleteCallback(widget._bookInfo);
                },
          )
        ]),
      ),
    );
  }
}
