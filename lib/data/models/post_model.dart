import 'package:equatable/equatable.dart';

final class Post extends Equatable {
  const Post({required this.id, required this.title, required this.body});

  final int id;
  final String title;
  final String body;

  @override
  List<Object> get props => [id, title, body];
}

// import 'package:equatable/equatable.dart';
//
// class Post extends Equatable {
//   final int id;
//   final String title;
//   final String body;
//
//   const Post({
//     required this.id,
//     required this.title,
//     required this.body,
//   });
//
//   @override
//   List<Object?> get props => [id, title, body];
//
//   @override
//   bool get stringify => true;
// }
