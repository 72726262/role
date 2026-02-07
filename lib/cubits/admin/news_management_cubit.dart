import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/database_service.dart';
import '../../models/news_model.dart';
import 'news_management_state.dart';

/// News Management Cubit
/// Manages news CRUD operations for admin

class NewsManagementCubit extends Cubit<NewsManagementState> {
  final DatabaseService _databaseService;

  NewsManagementCubit({DatabaseService? databaseService})
      : _databaseService = databaseService ?? DatabaseService(),
        super(NewsManagementInitial());

  /// Load all news
  Future<void> loadNews() async {
    emit(NewsManagementLoading());
    
    try {
      final news = await _databaseService.getNews();
      emit(NewsManagementLoaded(news));
    } catch (e) {
      emit(NewsManagementError(e.toString()));
    }
  }

  /// Refresh news
  Future<void> refreshNews() async {
    await loadNews();
  }

  /// Delete news
  Future<void> deleteNews(String newsId) async {
    try {
      await _databaseService.delete('news', newsId);
      await loadNews(); // Reload after delete
    } catch (e) {
      emit(NewsManagementError(e.toString()));
    }
  }

  /// Toggle publish status
  Future<void> togglePublishStatus(String newsId, bool isPublished) async {
    try {
      await _databaseService.update('news', newsId, {
        'is_published': !isPublished,
      });
      await loadNews();
    } catch (e) {
      emit(NewsManagementError(e.toString()));
    }
  }

  /// Search news
  Future<void> searchNews(String query) async {
    if (query.isEmpty) {
      await loadNews();
      return;
    }

    emit(NewsManagementLoading());
    
    try {
      // For now, load all and filter locally
      // TODO: Implement server-side search
      final allNews = await _databaseService.getNews();
      final filtered = allNews.where((n) =>
        n.title.toLowerCase().contains(query.toLowerCase()) ||
        n.content.toLowerCase().contains(query.toLowerCase())
      ).toList();
      
      emit(NewsManagementLoaded(filtered));
    } catch (e) {
      emit(NewsManagementError(e.toString()));
    }
  }
}
