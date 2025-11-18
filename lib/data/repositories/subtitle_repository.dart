import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import '../../domain/entities/subtitle.dart';
import '../../utils/srt_parser.dart';

/// Repository để tải phụ đề từ nhiều nguồn khác nhau
class SubtitleRepository {
  /// Tải phụ đề từ thư mục assets
  ///
  /// Ví dụ: assets/subtitles/doraemon.srt
  Future<List<Subtitle>> loadFromAssets(String assetPath) async {
    try {
      final srtContent = await rootBundle.loadString(assetPath);
      return SrtParser.parse(srtContent);
    } catch (e) {
      print('❌ Lỗi tải phụ đề từ assets: $e');
      return [];
    }
  }

  /// Tải phụ đề từ URL (Firebase Storage hoặc nguồn khác)
  ///
  /// Ví dụ: https://firebasestorage.googleapis.com/.../subtitle.srt
  Future<List<Subtitle>> loadFromUrl(String url) async {
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final srtContent = response.body;
        return SrtParser.parse(srtContent);
      } else {
        print('❌ Không thể tải phụ đề: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('❌ Lỗi tải phụ đề từ URL: $e');
      return [];
    }
  }

  /// Tải phụ đề song ngữ (Tiếng Anh + Tiếng Việt)
  /// từ 2 file riêng biệt
  Future<List<Subtitle>> loadBilingualFromUrls({
    required String englishUrl,
    required String vietnameseUrl,
  }) async {
    try {
      print('📥 Fetching EN subtitle from: $englishUrl');
      final enResponse = await http.get(
        Uri.parse(englishUrl),
        headers: {'Accept-Charset': 'utf-8'},
      );
      print(
        '📥 EN Response: ${enResponse.statusCode}, Length: ${enResponse.body.length}',
      );

      print('📥 Fetching VI subtitle from: $vietnameseUrl');
      final viResponse = await http.get(
        Uri.parse(vietnameseUrl),
        headers: {'Accept-Charset': 'utf-8'},
      );
      print(
        '📥 VI Response: ${viResponse.statusCode}, Length: ${viResponse.body.length}',
      );

      if (enResponse.statusCode == 200 && viResponse.statusCode == 200) {
        print('📥 Đã tải cả 2 phụ đề, đang gộp...');

        // Decode với UTF-8
        final enContent = utf8.decode(enResponse.bodyBytes);
        final viContent = utf8.decode(viResponse.bodyBytes);

        print('📥 Xem trước EN: ${enContent.substring(0, 200)}...');
        print('📥 Xem trước VI: ${viContent.substring(0, 200)}...');

        final result = SrtParser.mergeBilingual(enContent, viContent);

        print('📥 Kết quả gộp: ${result.length} phụ đề');
        return result;
      } else {
        print(
          '❌ Không thể tải phụ đề song ngữ: EN=${enResponse.statusCode}, VI=${viResponse.statusCode}',
        );
        return [];
      }
    } catch (e) {
      print('❌ Lỗi tải phụ đề song ngữ: $e');
      return [];
    }
  }

  /// Tải phụ đề từ nội dung string (để test)
  List<Subtitle> loadFromString(String srtContent) {
    return SrtParser.parse(srtContent);
  }
}
