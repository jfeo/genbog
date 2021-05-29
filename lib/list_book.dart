import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'info.dart';

class ListBook extends StatefulWidget {
  late final BookInfo _bookInfo;
  late final void Function(BookInfo) _deleteCallback;

  ListBook(BookInfo bookInfo, void Function(BookInfo) deleteCallback) {
    _bookInfo = bookInfo;
    _deleteCallback = deleteCallback;
  }

  @override
  _ListBookState createState() => _ListBookState();
}

class _ListBookState extends State<ListBook> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(4),
      child: Container(
        child: Row(children: [
          Container(
            child: widget._bookInfo.thumbnailData != null
                ? Image.memory(widget._bookInfo.thumbnailData!)
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
    return ListTile(
      leading: widget._bookInfo.thumbnailData != null
          ? Image.memory(widget._bookInfo.thumbnailData!)
          : Icon(Icons.book),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(children: [
            Row(
              children: [
                Column(
                  children: [
                    Text(widget._bookInfo.title ?? widget._bookInfo.isbn,
                        style: Theme.of(context).textTheme.headline2,
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                        maxLines: 1),
                  ],
                ),
              ],
            ),
            Row(
                children: widget._bookInfo.authors
                    .map(
                      (author) => Text(
                        author.name,
                        style: Theme.of(context).textTheme.bodyText2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    )
                    .toList())
          ]),
          Column(
            children: [
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  widget._deleteCallback(widget._bookInfo);
                },
              )
            ],
          )
        ],
      ),
    );
  }
}
