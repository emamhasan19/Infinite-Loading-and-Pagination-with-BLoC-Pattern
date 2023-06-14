// ignore_for_file: library_private_types_in_public_api

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// const String apiUrl = 'https://jsonplaceholder.typicode.com/posts';

class PostScreen extends StatefulWidget {
  const PostScreen({super.key});

  @override
  _PostScreenState createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  String apiUrl = 'https://jsonplaceholder.typicode.com/posts';
  late List<dynamic> posts;
  late int currentPage;
  bool isLoading = false;
  bool hasReachedMax = false;
  late ScrollController scrollController;

  @override
  void initState() {
    super.initState();
    posts = [];
    currentPage = 1;
    scrollController = ScrollController();
    scrollController.addListener(_scrollListener);
    fetchData();
  }

  void _scrollListener() {
    if (scrollController.offset >= scrollController.position.maxScrollExtent &&
        !scrollController.position.outOfRange) {
      fetchData();
    }
  }

  Future<void> fetchData() async {
    if (!isLoading && !hasReachedMax) {
      setState(() {
        isLoading = true;
      });

      final response =
          await http.get(Uri.parse('$apiUrl?_page=$currentPage&_limit=10'));

      if (response.statusCode == 200) {
        final List<dynamic> fetchedPosts = jsonDecode(response.body);

        setState(() {
          posts.addAll(fetchedPosts);
          currentPage++;
          isLoading = false;
          hasReachedMax =
              fetchedPosts.length < 10; // Assuming 10 items per page
        });
      } else {
        throw Exception('Failed to fetch data');
      }
    }
  }

  @override
  void dispose() {
    scrollController.removeListener(_scrollListener);
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Posts'),
      ),
      body: ListView.builder(
        controller: scrollController,
        itemCount: posts.length + 1,
        itemBuilder: (context, index) {
          if (index < posts.length) {
            final post = posts[index];
            return ListTile(
              leading: Text('${post['id']}'),
              title: Text(post['title']),
              subtitle: Text(post['body']),
            );
          } else if (isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return Container(); // Reached the end
          }
        },
      ),
    );
  }
}
