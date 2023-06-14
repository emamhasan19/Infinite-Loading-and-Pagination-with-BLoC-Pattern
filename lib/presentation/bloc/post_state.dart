part of 'post_bloc.dart';

enum PostStatus { initial, success, failure }

final class PostState extends Equatable {
  const PostState({
    this.status = PostStatus.initial,
    this.posts = const <Post>[],
    this.hasReachedMax = false,
  });

  final PostStatus status;
  final List<Post> posts;
  final bool hasReachedMax;

  PostState copyWith({
    PostStatus? status,
    List<Post>? posts,
    bool? hasReachedMax,
  }) {
    return PostState(
      status: status ?? this.status,
      posts: posts ?? this.posts,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  String toString() {
    return '''PostState { status: $status, hasReachedMax: $hasReachedMax, posts: ${posts.length} }''';
  }

  @override
  List<Object> get props => [status, posts, hasReachedMax];
}

// import 'package:equatable/equatable.dart';
// import 'package:infinite_loading/data/models/post_model.dart';
//
// enum PostStatus { initial, success, failure, loading }
//
// class PostState extends Equatable {
//   const PostState({
//     this.status = PostStatus.initial,
//     this.posts = const [],
//     this.errorMessage = '',
//     this.hasReachedMax = false,
//     this.totalCount = 0,
//   });
//
//   final PostStatus status;
//   final List<Post> posts;
//   final String errorMessage;
//   final bool hasReachedMax;
//   final int totalCount;
//
//   PostState copyWith({
//     PostStatus? status,
//     List<Post>? posts,
//     String? errorMessage,
//     bool? hasReachedMax,
//     int? totalCount,
//   }) {
//     return PostState(
//       status: status ?? this.status,
//       posts: posts ?? this.posts,
//       errorMessage: errorMessage ?? this.errorMessage,
//       hasReachedMax: hasReachedMax ?? this.hasReachedMax,
//       totalCount: totalCount ?? this.totalCount,
//     );
//   }
//
//   @override
//   List<Object?> get props =>
//       [status, posts, errorMessage, hasReachedMax, totalCount];
// }
