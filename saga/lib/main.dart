import 'package:flutter/cupertino.dart';
import 'screens/books_grid_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'Book Collection',
      theme: const CupertinoThemeData(
        brightness: Brightness.dark,
        primaryColor: CupertinoColors.systemBlue,
      ),
      home: BooksGridPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}