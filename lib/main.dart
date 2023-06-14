import 'package:flutter/material.dart';
import 'package:infinite_loading/presentation/pages/post_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Post Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const PostsPage(),
      // home: const PostScreen(),
      // home: const InfiniteLoadingScreen(),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:infinite_loading/presentation/pages/post_page.dart';
//
// void main() {
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Post Page',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: const PostPage(),
//     );
//   }
// }
