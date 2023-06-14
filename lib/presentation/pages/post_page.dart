import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:infinite_loading/presentation/bloc/post_bloc.dart';
import 'package:infinite_loading/presentation/widgets/post_list.dart';

class PostsPage extends StatelessWidget {
  const PostsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Posts'),
        centerTitle: true,
      ),
      body: BlocProvider(
        create: (_) => PostBloc(httpClient: http.Client())..add(PostFetched()),
        child: const PostsList(),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:infinite_loading/presentation/bloc/post_bloc.dart';
// import 'package:infinite_loading/presentation/bloc/post_event.dart';
// import 'package:infinite_loading/presentation/bloc/post_state.dart';
//
// class PostPage extends StatefulWidget {
//   @override
//   _PostPageState createState() => _PostPageState();
// }
//
// class _PostPageState extends State<PostPage> {
//   final ScrollController _scrollController = ScrollController();
//
//   @override
//   void initState() {
//     super.initState();
//     context.read<PostBloc>().add(FetchPosts());
//     _scrollController.addListener(_scrollListener);
//   }
//
//   @override
//   void dispose() {
//     _scrollController.dispose();
//     super.dispose();
//   }
//
//   void _scrollListener() {
//     if (_scrollController.offset >=
//             _scrollController.position.maxScrollExtent &&
//         !_scrollController.position.outOfRange) {
//       context.read<PostBloc>().add(FetchPosts());
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Posts'),
//       ),
//       body: BlocBuilder<PostBloc, PostState>(
//         builder: (context, state) {
//           if (state.status == PostStatus.loading && state.posts.isEmpty) {
//             return const Center(child: CircularProgressIndicator());
//           } else if (state.status == PostStatus.failure) {
//             return const Center(child: Text('Failed to fetch posts'));
//           } else {
//             return ListView.builder(
//               controller: _scrollController,
//               itemCount: state.hasReachedMax
//                   ? state.posts.length
//                   : state.posts.length + 1,
//               itemBuilder: (context, index) {
//                 if (index == state.posts.length) {
//                   if (state.status == PostStatus.loading) {
//                     return const Center(child: CircularProgressIndicator());
//                   } else {
//                     return Container(); // Empty container when not loading
//                   }
//                 } else {
//                   return ListTile(
//                     title: Text(state.posts[index].title),
//                     subtitle: Text(state.posts[index].body),
//                     trailing: const Icon(Icons.arrow_forward),
//                     onTap: () {
//                       // Handle post tap
//                     },
//                   );
//                 }
//               },
//             );
//           }
//         },
//       ),
//     );
//   }
// }
//
// // class _PostPageState extends State<PostPage> {
// //   final ScrollController _scrollController = ScrollController();
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     context.read<PostBloc>().add(FetchPosts());
// //     _scrollController.addListener(_scrollListener);
// //   }
// //
// //   @override
// //   void dispose() {
// //     _scrollController.dispose();
// //     super.dispose();
// //   }
// //
// //   void _scrollListener() {
// //     if (_scrollController.offset >=
// //             _scrollController.position.maxScrollExtent &&
// //         !_scrollController.position.outOfRange) {
// //       context.read<PostBloc>().add(FetchPosts());
// //     }
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: const Text('Posts'),
// //       ),
// //       body: BlocBuilder<PostBloc, PostState>(
// //         builder: (context, state) {
// //           if (state.status == PostStatus.loading && state.posts.isEmpty) {
// //             return const Center(child: CircularProgressIndicator());
// //           } else if (state.status == PostStatus.failure) {
// //             return const Center(child: Text('Failed to fetch posts'));
// //           } else {
// //             return ListView.builder(
// //               controller: _scrollController,
// //               itemCount: state.hasReachedMax
// //                   ? state.posts.length
// //                   : state.posts.length + 1,
// //               itemBuilder: (context, index) {
// //                 if (index == state.posts.length) {
// //                   return const Center(child: CircularProgressIndicator());
// //                 } else {
// //                   return ListTile(
// //                     title: Text(state.posts[index].title),
// //                     subtitle: Text(state.posts[index].body),
// //                     trailing: const Icon(Icons.arrow_forward),
// //                     onTap: () {
// //                       // Handle post tap
// //                     },
// //                   );
// //                 }
// //               },
// //             );
// //           }
// //         },
// //       ),
// //     );
// //   }
// // }
//
// // import 'package:flutter/material.dart';
// // import 'package:flutter_bloc/flutter_bloc.dart';
// // import 'package:infinite_loading/presentation/bloc/post_bloc.dart';
// // import 'package:infinite_loading/presentation/bloc/post_event.dart';
// // import 'package:infinite_loading/presentation/bloc/post_state.dart';
// //
// // class PostPage extends StatefulWidget {
// //   @override
// //   _PostPageState createState() => _PostPageState();
// // }
// //
// // class _PostPageState extends State<PostPage> {
// //   final ScrollController _scrollController = ScrollController();
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     context.read<PostBloc>().add(FetchPosts());
// //     _scrollController.addListener(_scrollListener);
// //   }
// //
// //   @override
// //   void dispose() {
// //     _scrollController.dispose();
// //     super.dispose();
// //   }
// //
// //   void _scrollListener() {
// //     if (_scrollController.offset >=
// //             _scrollController.position.maxScrollExtent &&
// //         !_scrollController.position.outOfRange) {
// //       context.read<PostBloc>().add(FetchPosts());
// //     }
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: const Text('Posts'),
// //       ),
// //       body: BlocBuilder<PostBloc, PostState>(
// //         builder: (context, state) {
// //           if (state.status == PostStatus.loading && state.posts.isEmpty) {
// //             return const Center(child: CircularProgressIndicator());
// //           } else if (state.status == PostStatus.failure) {
// //             return const Center(child: Text('Failed to fetch posts'));
// //           } else {
// //             return ListView.builder(
// //               controller: _scrollController,
// //               itemCount: state.posts.length,
// //               itemBuilder: (context, index) {
// //                 if (index == state.posts.length - 1 && state.hasReachedMax) {
// //                   return ListTile(
// //                     title: Text(state.posts[index].title),
// //                     subtitle: Text(state.posts[index].body),
// //                   );
// //                 } else {
// //                   return ListTile(
// //                     title: Text(state.posts[index].title),
// //                     subtitle: Text(state.posts[index].body),
// //                     trailing: const Icon(Icons.arrow_forward),
// //                     onTap: () {
// //                       // Handle post tap
// //                     },
// //                   );
// //                 }
// //               },
// //             );
// //           }
// //         },
// //       ),
// //     );
// //   }
// // }
//
