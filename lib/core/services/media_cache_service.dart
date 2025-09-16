import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class MediaCacheService {
  static final MediaCacheService _instance = MediaCacheService._internal();
  factory MediaCacheService() => _instance;
  MediaCacheService._internal();

  final Dio _dio = Dio();
  String? _cacheDir;

  Future<void> initialize() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      _cacheDir = '${directory.path}/media_cache';
      await Directory(_cacheDir!).create(recursive: true);
    } catch (e) {
      print('Error initializing cache directory: $e');
    }
  }

  String _generateCacheKey(String url) {
    final bytes = utf8.encode(url);
    final digest = md5.convert(bytes);
    return digest.toString();
  }

  Future<File?> getCachedFile(String url) async {
    if (_cacheDir == null) await initialize();

    try {
      final cacheKey = _generateCacheKey(url);
      final extension = _getFileExtension(url);
      final file = File('$_cacheDir/$cacheKey$extension');

      if (await file.exists()) {
        // Check if file is not corrupted (has content)
        final stat = await file.stat();
        if (stat.size > 0) {
          return file;
        } else {
          // Delete corrupted file
          await file.delete();
        }
      }
    } catch (e) {
      print('Error getting cached file: $e');
    }

    return null;
  }

  Future<File?> cacheMedia(String url) async {
    if (_cacheDir == null) await initialize();

    try {
      final cacheKey = _generateCacheKey(url);
      final extension = _getFileExtension(url);
      final file = File('$_cacheDir/$cacheKey$extension');

      // Check if already cached
      if (await file.exists()) {
        return file;
      }

      // Download and cache
      final response = await _dio.get(
        url,
        options: Options(responseType: ResponseType.bytes),
      );

      await file.writeAsBytes(response.data);
      return file;
    } catch (e) {
      print('Error caching media: $e');
      return null;
    }
  }

  String _getFileExtension(String url) {
    final uri = Uri.parse(url);
    final path = uri.path;
    final lastDot = path.lastIndexOf('.');

    if (lastDot != -1 && lastDot < path.length - 1) {
      return path.substring(lastDot);
    }

    // Default extensions based on common media types
    if (url.contains('video') || url.contains('.mp4') || url.contains('.mov')) {
      return '.mp4';
    } else if (url.contains('image') || url.contains('.jpg') || url.contains('.png')) {
      return '.jpg';
    }

    return '.cache';
  }

  Future<void> clearCache() async {
    if (_cacheDir == null) await initialize();

    try {
      final dir = Directory(_cacheDir!);
      if (await dir.exists()) {
        await dir.delete(recursive: true);
        await dir.create();
      }
    } catch (e) {
      print('Error clearing cache: $e');
    }
  }

  Future<int> getCacheSize() async {
    if (_cacheDir == null) await initialize();

    try {
      final dir = Directory(_cacheDir!);
      if (!await dir.exists()) return 0;

      int totalSize = 0;
      await for (final entity in dir.list(recursive: true)) {
        if (entity is File) {
          final stat = await entity.stat();
          totalSize += stat.size;
        }
      }
      return totalSize;
    } catch (e) {
      print('Error getting cache size: $e');
      return 0;
    }
  }

  String formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1048576) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1073741824) return '${(bytes / 1048576).toStringAsFixed(1)} MB';
    return '${(bytes / 1073741824).toStringAsFixed(1)} GB';
  }

  Future<void> preloadMedia(List<String> urls) async {
    for (final url in urls) {
      try {
        await cacheMedia(url);
      } catch (e) {
        print('Error preloading media $url: $e');
      }
    }
  }
}