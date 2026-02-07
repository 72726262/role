import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/config/supabase_config.dart';

/// Storage Service - handles file uploads and downloads
class StorageService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ============================================
  // DOCUMENTS BUCKET (PDF files)
  // ============================================

  /// Upload PDF file to documents bucket
  Future<String> uploadPDF(File file, String fileName) async {
    try {
      final path = 'pdfs/$fileName';

      await _supabase.storage
          .from(SupabaseConfig.documentsBucket)
          .upload(path, file);

      final url = _supabase.storage
          .from(SupabaseConfig.documentsBucket)
          .getPublicUrl(path);

      return url;
    } catch (e) {
      rethrow;
    }
  }

  /// Delete PDF file
  Future<void> deletePDF(String path) async {
    try {
      await _supabase.storage
          .from(SupabaseConfig.documentsBucket)
          .remove([path]);
    } catch (e) {
      rethrow;
    }
  }

  /// Get PDF URL
  String getPDFUrl(String path) {
    return _supabase.storage
        .from(SupabaseConfig.documentsBucket)
        .getPublicUrl(path);
  }

  // ============================================
  // GENERIC FILE UPLOAD
  // ============================================

  /// Upload file to specified bucket
  Future<String> uploadFile(File file, String bucket, String path) async {
    try {
      await _supabase.storage
          .from(bucket)
          .upload(path, file);

      final url = _supabase.storage
          .from(bucket)
          .getPublicUrl(path);

      return url;
    } catch (e) {
      rethrow;
    }
  }

  // ============================================
  // IMAGES BUCKET
  // ============================================

  /// Upload image file to images bucket
  Future<String> uploadImage(File file, String fileName) async {
    try {
      final path = 'images/$fileName';

      await _supabase.storage
          .from(SupabaseConfig.imagesBucket)
          .upload(path, file);

      final url = _supabase.storage
          .from(SupabaseConfig.imagesBucket)
          .getPublicUrl(path);

      return url;
    } catch (e) {
      rethrow;
    }
  }

  /// Upload profile photo
  Future<String> uploadProfilePhoto(File file, String userId) async {
    try {
      final fileName = 'profile_$userId.${file.path.split('.').last}';
      final path = 'profiles/$fileName';

      // Delete old photo if exists
      try {
        await _supabase.storage
            .from(SupabaseConfig.imagesBucket)
            .remove([path]);
      } catch (e) {
        // Ignore if file doesn't exist
      }

      await _supabase.storage
          .from(SupabaseConfig.imagesBucket)
          .upload(path, file);

      final url = _supabase.storage
          .from(SupabaseConfig.imagesBucket)
          .getPublicUrl(path);

      return url;
    } catch (e) {
      rethrow;
    }
  }

  /// Delete image file
  Future<void> deleteImage(String path) async {
    try {
      await _supabase.storage
          .from(SupabaseConfig.imagesBucket)
          .remove([path]);
    } catch (e) {
      rethrow;
    }
  }

  /// Get image URL
  String getImageUrl(String path) {
    return _supabase.storage
        .from(SupabaseConfig.imagesBucket)
        .getPublicUrl(path);
  }

  // ============================================
  // HELPER METHODS
  // ============================================

  /// Get file path from URL
  String getPathFromUrl(String url) {
    final uri = Uri.parse(url);
    final pathSegments = uri.pathSegments;
    // Remove bucket name and get the actual file path
    return pathSegments.sublist(2).join('/');
  }

  /// Check if URL is from Supabase storage
  bool isSupabaseStorageUrl(String url) {
    return url.contains(SupabaseConfig.supabaseUrl) && url.contains('/storage/v1/object/public/');
  }
}
