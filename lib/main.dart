import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_genbog/api.dart';
import 'package:flutter_genbog/info.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

import 'list_book.dart';

void main() => runApp(GenBogApp());

class GenBogApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: ListPage());
  }
}

class ListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  List<BookInfo> remoteBooks = [];

  @override
  Widget build(BuildContext context) {
    final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = new GlobalKey<RefreshIndicatorState>();
    _refreshIndicatorKey.currentState?.show();

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
                List<BookInfo> result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QRMultiPage(),
                  ),
                );

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
                      .map((remoteBook) => ListBook(remoteBook, _deleteBook))
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

class QRPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: Text("Not yet implemented"),
    );
  }
}

class QRMultiPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _QRMultiPageState();
}

class _QRMultiPageState extends State<QRMultiPage> {
  List<BookInfo> scannedBooks = [];
  DateTime lastScan = DateTime.now().subtract(Duration(seconds: 1));
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  String _status = "Skan stregkoden på en bog...";
  Color _statusColor = Colors.black;

  void setStatus(String text, {Color color = Colors.black}) {
    setState(() {
      _status = text;
      _statusColor = color;
    });
  }

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Skan flere bøger"),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
              Navigator.pop(context, scannedBooks);
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 3,
            child: Scaffold(
              body: _buildQrView(context),
              floatingActionButton:
                  Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                Container(
                  margin: EdgeInsets.all(8),
                  child: FloatingActionButton(
                    onPressed: () async {
                      await controller?.toggleFlash();
                      setState(() {});
                    },
                    child: FutureBuilder(
                      future: controller?.getFlashStatus(),
                      builder: (context, snapshot) {
                        return Icon(snapshot.data == true
                            ? Icons.flash_on_rounded
                            : Icons.flash_off_rounded);
                      },
                    ),
                  ),
                ),
                FloatingActionButton(
                  onPressed: () async {
                    await controller?.flipCamera();
                    setState(() {});
                  },
                  child: FutureBuilder(
                    future: controller?.getCameraInfo(),
                    builder: (context, snapshot) {
                      return Icon(snapshot.data == null
                          ? Icons.hourglass_full_rounded
                          : Icons.flip_camera_android_rounded);
                    },
                  ),
                ),
              ]),
            ),
          ),
          Container(
            margin: EdgeInsets.all(8),
            child: Text(_status, style: TextStyle(color: _statusColor)),
          ),
          Expanded(
            flex: 2,
            child: ListView(
              children: scannedBooks
                  .map((scannedBook) => ListBook(scannedBook, _deleteBook))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  void _deleteBook(BookInfo book) {
    setState(() {
      scannedBooks.remove(book);
    });
  }

  Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 300.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      formatsAllowed: [BarcodeFormat.ean13],
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: Colors.red,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) async {
      if (DateTime.now().difference(lastScan).inSeconds < 2) {
        return;
      }
      lastScan = DateTime.now();

      setStatus("Læser stregkode '${scanData.code}'...");

      var bookInfo = await BookInfo.fetch(scanData.code);
      if (bookInfo.title == null) {
        setStatus("Kunne ikke indhente boginformation for '${scanData.code}'",
            color: Colors.red);
      } else {
        setStatus("Boginformationer fundet for '${scanData.code}'");
      }
      setState(() {
        scannedBooks.add(bookInfo);
      });
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
