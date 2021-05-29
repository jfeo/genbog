import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'api.dart';
import 'bookcard.dart';
import 'info.dart';
import 'qrpage.dart';

class ListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = new GlobalKey<RefreshIndicatorState>();
  List<BookInfo> remoteBooks = [];

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance!.addPostFrameCallback((_){  _refreshIndicatorKey.currentState?.show(); } );
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
        appBar: AppBar(
          title: Text("GenBog"),
          backgroundColor: Colors.deepPurple,
        ),
        floatingActionButton:
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          Container(
            margin: EdgeInsets.all(8),
            child: FloatingActionButton(
              onPressed: () async {
                List<BookInfo>? result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QRMultiPage(),
                  ),
                );

                if (result == null) {
                  return;
                }

                var apiResult = await API.postBooks(result);
                if (apiResult.error != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text("En fejl opstod. Kunne ikke indsende bøgerne."),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Bøgerne blev gemt!"),
                    ),
                  );
                  _refreshIndicatorKey.currentState?.show(atTop: true);
                }
              },
              child: Icon(Icons.library_add),
            ),
          ),
        ]),
        body: Column(
          children: [
            Expanded(
              flex: 2,
              child: RefreshIndicator(
                key: _refreshIndicatorKey,
                child: ListView(
                  children: remoteBooks
                      .map((remoteBook) => BookCard(remoteBook, _deleteBook))
                      .toList(),
                ),
                onRefresh: _refreshBooks,
              ),
            )
          ],
        ));
  }

  Future<void> _refreshBooks() async {
    var result = await API.getBooks();
    if (result.value == null) {
      return;
    }

    var futures = result.value!.map((isbn) => BookInfo.fetch(isbn.isbn));
    var bookInfos = await Future.wait(futures);
    setState(() {
      remoteBooks = bookInfos;
    });
  }

  void _deleteBook(BookInfo book) async {
    await API.deleteBook(book);
    setState(() {
      remoteBooks.remove(book);
    });
  }
}