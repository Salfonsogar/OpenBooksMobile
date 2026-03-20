import 'package:equatable/equatable.dart';

import '../../data/models/bookmark.dart';

abstract class BookmarkState extends Equatable {
  const BookmarkState();

  @override
  List<Object?> get props => [];
}

class BookmarkInitial extends BookmarkState {}

class BookmarkLoading extends BookmarkState {}

class BookmarkLoaded extends BookmarkState {
  final List<Bookmark> bookmarks;
  final int bookId;

  const BookmarkLoaded({
    required this.bookmarks,
    required this.bookId,
  });

  @override
  List<Object?> get props => [bookmarks, bookId];
}

class BookmarkError extends BookmarkState {
  final String message;

  const BookmarkError(this.message);

  @override
  List<Object?> get props => [message];
}
