import 'dart:async';
import 'dart:convert';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:infinite_loading/data/models/post_model.dart';
import 'package:stream_transform/stream_transform.dart';

part 'post_event.dart';
part 'post_state.dart';

const _postLimit = 10;
const throttleDuration = Duration(milliseconds: 500);

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) {
    return droppable<E>().call(events.throttle(duration), mapper);
  };
}

class PostBloc extends Bloc<PostEvent, PostState> {
  PostBloc({required this.httpClient}) : super(const PostState()) {
    on<PostFetched>(
      _onPostFetched,
      transformer: throttleDroppable(throttleDuration),
    );
  }

  final http.Client httpClient;

  Future<void> _onPostFetched(
    PostFetched event,
    Emitter<PostState> emit,
  ) async {
    if (state.hasReachedMax) return;
    try {
      if (state.status == PostStatus.initial) {
        final posts = await _fetchPosts();
        return emit(
          state.copyWith(
            status: PostStatus.success,
            posts: posts,
            hasReachedMax: false,
          ),
        );
      }
      final posts = await _fetchPosts(state.posts.length);
      posts.isEmpty
          ? emit(state.copyWith(hasReachedMax: true))
          : emit(
              state.copyWith(
                status: PostStatus.success,
                posts: List.of(state.posts)..addAll(posts),
                hasReachedMax: false,
              ),
            );
    } catch (_) {
      emit(state.copyWith(status: PostStatus.failure));
    }
  }

  Future<List<Post>> _fetchPosts([int startIndex = 0]) async {
    final response = await httpClient.get(
      Uri.https(
        'jsonplaceholder.typicode.com',
        '/posts',
        <String, String>{'_start': '$startIndex', '_limit': '$_postLimit'},
      ),
    );
    if (response.statusCode == 200) {
      final body = json.decode(response.body) as List;
      return body
          .map<Post>((json) => Post(
                id: json['id'] as int,
                title: json['title'] as String,
                body: json['body'] as String,
              ))
          .toList();

      // return body.map((dynamic json) {
      //   final map = json as Map<String, dynamic>;
      //   return Post(
      //     id: map['id'] as int,
      //     title: map['title'] as String,
      //     body: map['body'] as String,
      //   );
      // }).toList();
    }
    throw Exception('error fetching posts');
  }
}

// import 'dart:convert';
//
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:http/http.dart' as http;
// import 'package:infinite_loading/data/models/post_model.dart';
// import 'package:infinite_loading/presentation/bloc/post_event.dart';
// import 'package:infinite_loading/presentation/bloc/post_state.dart';
//
// class PostBloc extends Bloc<PostEvent, PostState> {
//   static const String apiUrl = 'https://jsonplaceholder.typicode.com/posts';
//
//   PostBloc() : super(const PostState()) {
//     on<FetchPosts>(_onPostFetchedEvent);
//   }
//
//   Future<void> _onPostFetchedEvent(
//     FetchPosts event,
//     Emitter<PostState> emit,
//   ) async {
//     emit(state.copyWith(status: PostStatus.loading));
//     try {
//       final List<Post> posts = await _fetchPostsFromApi();
//       final int totalCount =
//           state.totalCount + posts.length; // Update the total count
//       emit(state.copyWith(
//         posts: posts,
//         status: PostStatus.success,
//         totalCount: totalCount, // Update the total count in the state
//         hasReachedMax: posts.length <
//             10, // Check if the fetched posts are less than the page size
//       ));
//     } catch (e) {
//       emit(state.copyWith(
//         status: PostStatus.failure,
//         errorMessage: 'Failed to fetch posts',
//       ));
//     }
//   }
//
//   Future<List<Post>> _fetchPostsFromApi() async {
//     const int pageSize = 10; // Number of posts per page
//
//     final int currentPage = (state.posts.length ~/ pageSize) + 1;
//
//     final response = await http.get(
//       Uri.parse('$apiUrl?_page=$currentPage&_limit=$pageSize'),
//     );
//
//     if (response.statusCode == 200) {
//       final List<dynamic> fetchedPosts = jsonDecode(response.body);
//
//       final List<Post> posts = fetchedPosts
//           .map((postData) => Post(
//                 id: postData['id'],
//                 title: postData['title'],
//                 body: postData['body'],
//               ))
//           .toList();
//
//       return posts;
//     } else {
//       throw Exception('Failed to fetch data');
//     }
//   }
// }
//
// // import 'dart:convert';
// //
// // import 'package:flutter_bloc/flutter_bloc.dart';
// // import 'package:http/http.dart' as http;
// // import 'package:infinite_loading/data/models/post_model.dart';
// // import 'package:infinite_loading/presentation/bloc/post_event.dart';
// // import 'package:infinite_loading/presentation/bloc/post_state.dart';
// //
// // class PostBloc extends Bloc<PostEvent, PostState> {
// //   static const String apiUrl = 'https://jsonplaceholder.typicode.com/posts';
// //
// //   PostBloc() : super(const PostState()) {
// //     on<FetchPosts>(_onPostFetchedEvent);
// //   }
// //
// //   Future<void> _onPostFetchedEvent(
// //     FetchPosts event,
// //     Emitter<PostState> emit,
// //   ) async {
// //     emit(state.copyWith(status: PostStatus.loading));
// //     try {
// //       final List<Post> posts = await _fetchPostsFromApi();
// //       // print(state.totalCount);
// //       emit(state.copyWith(
// //         posts: posts,
// //         status: PostStatus.success,
// //         hasReachedMax: state.posts.length >= state.totalCount,
// //       ));
// //     } catch (e) {
// //       emit(state.copyWith(
// //         status: PostStatus.failure,
// //         errorMessage: 'Failed to fetch posts',
// //       ));
// //     }
// //   }
// //
// //   Future<List<Post>> _fetchPostsFromApi() async {
// //     const int pageSize = 10; // Number of posts per page
// //
// //     if (!state.hasReachedMax) {
// //       final int currentPage = state.posts.length ~/ pageSize + 1;
// //
// //       final response = await http
// //           .get(Uri.parse('$apiUrl?_page=$currentPage&_limit=$pageSize'));
// //
// //       if (response.statusCode == 200) {
// //         final List<dynamic> fetchedPosts = jsonDecode(response.body);
// //         final totalCountHeader = response.headers['x-total-count'];
// //         final int totalCount =
// //             totalCountHeader != null ? int.parse(totalCountHeader) : 0;
// //         // print(totalCount);
// //
// //         final List<Post> posts = fetchedPosts
// //             .map((postData) => Post(
// //                   id: postData['id'],
// //                   title: postData['title'],
// //                   body: postData['body'],
// //                 ))
// //             .toList();
// //
// //         final allPosts = List<Post>.from(state.posts)..addAll(posts);
// //         bool hasReachedMax = allPosts.length >= totalCount;
// //         print(posts.length);
// //         print(allPosts.length);
// //
// //         return hasReachedMax ? allPosts : allPosts.sublist(0, posts.length);
// //       } else {
// //         throw Exception('Failed to fetch data');
// //       }
// //     }
// //
// //     return state.posts;
// //   }
// // }
//
// // import 'dart:convert';
// //
// // import 'package:flutter_bloc/flutter_bloc.dart';
// // import 'package:http/http.dart' as http;
// // import 'package:infinite_loading/data/models/post_model.dart';
// // import 'package:infinite_loading/presentation/bloc/post_event.dart';
// // import 'package:infinite_loading/presentation/bloc/post_state.dart';
// //
// // const String apiUrl = 'https://jsonplaceholder.typicode.com/posts';
// //
// // class PostBloc extends Bloc<PostEvent, PostState> {
// //   PostBloc() : super(const PostState()) {
// //     on<FetchPosts>(_onPostFetchedEvent);
// //   }
// //   Future<void> _onPostFetchedEvent(
// //     FetchPosts event,
// //     Emitter<PostState> emit,
// //   ) async {
// //     emit(state.copyWith(status: PostStatus.loading));
// //     try {
// //       final List<Post> posts = await _fetchPostsFromApi();
// //       print(state.totalCount);
// //       emit(state.copyWith(
// //           posts: posts,
// //           status: PostStatus.success,
// //           hasReachedMax: state.posts.length >= state.totalCount));
// //     } catch (e) {
// //       emit(state.copyWith(
// //           status: PostStatus.failure, errorMessage: 'Failed to fetch posts'));
// //     }
// //   }
// //
// //   Future<List<Post>> _fetchPostsFromApi() async {
// //     final int pageSize = 10; // Number of posts per page
// //
// //     if (!state.hasReachedMax) {
// //       final int currentPage = state.posts.length ~/ pageSize + 1;
// //
// //       final response = await http
// //           .get(Uri.parse('$apiUrl?_page=$currentPage&_limit=$pageSize'));
// //
// //       if (response.statusCode == 200) {
// //         final List<dynamic> fetchedPosts = jsonDecode(response.body);
// //
// //         final List<Post> posts = fetchedPosts
// //             .map((postData) => Post(
// //                   id: postData['id'],
// //                   title: postData['title'],
// //                   body: postData['body'],
// //                 ))
// //             .toList();
// //
// //         final allPosts = List<Post>.from(state.posts)..addAll(posts);
// //         bool hasReachedMax = allPosts.length >= state.totalCount;
// //
// //         return hasReachedMax
// //             ? allPosts
// //             : allPosts.sublist(0, allPosts.length - 1);
// //       } else {
// //         throw Exception('Failed to fetch data');
// //       }
// //     }
// //
// //     return state.posts;
// //   }
//
// // Future<List<Post>> _fetchPostsFromApi() async {
// //   final int pageSize = 10; // Number of posts per page
// //
// //   if (!state.hasReachedMax) {
// //     final int currentPage = state.posts.length ~/ pageSize + 1;
// //
// //     final response = await http
// //         .get(Uri.parse('$apiUrl?_page=$currentPage&_limit=$pageSize'));
// //
// //     if (response.statusCode == 200) {
// //       final List<dynamic> fetchedPosts = jsonDecode(response.body);
// //
// //       final List<Post> posts = fetchedPosts
// //           .map((postData) => Post(
// //                 id: postData['id'],
// //                 title: postData['title'],
// //                 body: postData['body'],
// //               ))
// //           .toList();
// //
// //       bool hasReachedMax = fetchedPosts.length < pageSize;
// //
// //       return List<Post>.from(state.posts)..addAll(posts);
// //     } else {
// //       throw Exception('Failed to fetch data');
// //     }
// //   }
// //
// //   return state.posts;
// // }
//
// // Future<List<Post>> _fetchPostsFromApi() async {
// //   final int pageSize = 10; // Number of posts per page
// //
// //   if (!state.hasReachedMax) {
// //     final int currentPage = state.posts.length ~/ pageSize + 1;
// //
// //     final response = await http
// //         .get(Uri.parse('$apiUrl?_page=$currentPage&_limit=$pageSize'));
// //
// //     if (response.statusCode == 200) {
// //       final List<dynamic> fetchedPosts = jsonDecode(response.body);
// //
// //       final List<Post> posts = fetchedPosts
// //           .map((postData) => Post(
// //                 id: postData['id'],
// //                 title: postData['title'],
// //                 body: postData['body'],
// //               ))
// //           .toList();
// //
// //       bool hasReachedMax = posts.length < pageSize;
// //
// //       return List<Post>.from(state.posts)..addAll(posts);
// //     } else {
// //       throw Exception('Failed to fetch data');
// //     }
// //   }
// //
// //   return state.posts;
// // }
//
// // Future<List<Post>> _fetchPostsFromApi() async {
// //   final int pageSize = 10; // Number of posts per page
// //
// //   if (!state.hasReachedMax) {
// //     final int currentPage = state.posts.length ~/ pageSize + 1;
// //
// //     final response = await http
// //         .get(Uri.parse('$apiUrl?_page=$currentPage&_limit=$pageSize'));
// //
// //     if (response.statusCode == 200) {
// //       final List<dynamic> fetchedPosts = jsonDecode(response.body);
// //       final totalCountHeader = response.headers['x-total-count'];
// //       final int totalCount =
// //           totalCountHeader != null ? int.parse(totalCountHeader) : 0;
// //
// //       final List<Post> posts = fetchedPosts
// //           .map((postData) => Post(
// //                 id: postData['id'],
// //                 title: postData['title'],
// //                 body: postData['body'],
// //               ))
// //           .toList();
// //
// //       final allPosts = List<Post>.from(state.posts)..addAll(posts);
// //
// //       bool hasReachedMax = allPosts.length >= totalCount;
// //       return hasReachedMax ? allPosts : allPosts.sublist(0, allPosts.length);
// //     } else {
// //       throw Exception('Failed to fetch data');
// //     }
// //   }
// //
// //   return state.posts;
// // }
//
// // Future<List<Post>> _fetchPostsFromApi() async {
// //   final int pageSize = 10; // Number of posts per page
// //
// //   if (!state.hasReachedMax) {
// //     final int currentPage = state.posts.length ~/ pageSize + 1;
// //
// //     final response = await http
// //         .get(Uri.parse('$apiUrl?_page=$currentPage&_limit=$pageSize'));
// //
// //     if (response.statusCode == 200) {
// //       final List<dynamic> fetchedPosts = jsonDecode(response.body);
// //       final totalCountHeader = response.headers['x-total-count'];
// //       final int totalCount =
// //           totalCountHeader != null ? int.parse(totalCountHeader) : 0;
// //
// //       final List<Post> posts = fetchedPosts
// //           .map((postData) => Post(
// //                 id: postData['id'],
// //                 title: postData['title'],
// //                 body: postData['body'],
// //               ))
// //           .toList();
// //
// //       final allPosts = List<Post>.from(state.posts)..addAll(posts);
// //
// //       bool hasReachedMax = allPosts.length >= totalCount;
// //       return hasReachedMax
// //           ? allPosts
// //           : allPosts.sublist(0, allPosts.length - 1);
// //     } else {
// //       throw Exception('Failed to fetch data');
// //     }
// //   }
// //
// //   return state.posts;
// // }
//
// // Future<List<Post>> _fetchPostsFromApi() async {
// //   final int pageSize = 10; // Number of posts per page
// //
// //   if (!state.hasReachedMax) {
// //     // Simulate API call with pagination
// //     final int currentPage = state.posts.length ~/ pageSize + 1;
// //
// //     final response = await http
// //         .get(Uri.parse('$apiUrl?_page=$currentPage&_limit=$pageSize'));
// //
// //     if (response.statusCode == 200) {
// //       final List<dynamic> fetchedPosts = jsonDecode(response.body);
// //
// //       return fetchedPosts
// //           .map((postData) => Post(
// //                 id: postData['id'],
// //                 title: postData['title'],
// //                 body: postData['body'],
// //               ))
// //           .toList();
// //     } else {
// //       throw Exception('Failed to fetch data');
// //     }
// //   }
// //
// //   if (state.posts.isEmpty) {
// //     return []; // Empty list for the first page
// //   }
// //
// //   return state.posts; // Return the existing posts if no more posts to load
// // }
//
// // Future<List<Post>> _fetchPostsFromApi() async {
// //   const int pageSize = 10; // Number of posts per page
// //
// //   if (!state.hasReachedMax) {
// //     // Simulate API call with pagination
// //     final response = await http.get(Uri.parse(
// //         '$apiUrl?_page=${state.posts.length ~/ pageSize + 1}&_limit=$pageSize'));
// //
// //     if (response.statusCode == 200) {
// //       final List<dynamic> fetchedPosts = jsonDecode(response.body);
// //
// //       return fetchedPosts
// //           .map((postData) => Post(
// //                 id: postData['id'],
// //                 title: postData['title'],
// //                 body: postData['body'],
// //               ))
// //           .toList();
// //     } else {
// //       throw Exception('Failed to fetch data');
// //     }
// //   }
// //
// //   return []; // Empty list if reached the maximum number of posts
// // }
//
// // Future<List<Post>> _fetchPostsFromApi() async {
// //   // Simulate fetching posts from an API
// //   await Future.delayed(const Duration(seconds: 2));
// //
// //   // Mock data
// //   return List.generate(
// //     10,
// //     (index) => Post(
// //       id: index + 1,
// //       title: 'Post ${index + 1}',
// //       body: 'This is the body of Post ${index + 1}',
// //     ),
// //   );
