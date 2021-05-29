import 'package:flutter/material.dart';

import 'listpage.dart';

void main() => runApp(GenBogApp());

class GenBogApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: ListPage());
  }
}