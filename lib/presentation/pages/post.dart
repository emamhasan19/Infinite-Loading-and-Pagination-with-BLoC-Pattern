// ignore_for_file: library_private_types_in_public_api

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class InfiniteLoadingScreen extends StatefulWidget {
  const InfiniteLoadingScreen({super.key});

  @override
  _InfiniteLoadingScreenState createState() => _InfiniteLoadingScreenState();
}

class _InfiniteLoadingScreenState extends State<InfiniteLoadingScreen> {
  List<dynamic> items = [];
  int currentPage = 1;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    final url =
        'https://jsonplaceholder.typicode.com/posts?_page=$currentPage&_limit=10';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List<dynamic> fetchedItems = json.decode(response.body);

      setState(() {
        items.addAll(fetchedItems);
        currentPage++;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      throw Exception('Failed to load data');
    }
  }

  bool _isCloseToBottom(ScrollNotification scroll) {
    return scroll.metrics.pixels >= scroll.metrics.maxScrollExtent - 200.0;
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildListItem(dynamic item) {
    return ListTile(
      leading: Text('${item['id']}'),
      title: Text(item['title']),
      subtitle: Text(item['body']),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Infinite Loading'),
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (scroll) {
          if (!_isCloseToBottom(scroll)) return false;

          fetchData();
          return true;
        },
        child: ListView.builder(
          itemCount: items.length + 1,
          itemBuilder: (context, index) {
            if (index < items.length) {
              return _buildListItem(items[index]);
            } else if (isLoading) {
              return _buildLoadingIndicator();
            } else {
              return Container(); // Reached the end of the list
            }
          },
        ),
      ),
    );
  }
}
