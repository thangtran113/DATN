import 'dart:convert';
import 'package:http/http.dart' as http;

/// Service dịch từ tiếng Anh sang tiếng Việt
/// Sử dụng MyMemory Translation API (miễn phí, không cần API key)
class TranslationService {
  static const String _baseUrl = 'https://api.mymemory.translated.net/get';

  /// Dịch văn bản từ tiếng Anh sang tiếng Việt
  ///
  /// Returns null nếu có lỗi hoặc không dịch được
  Future<String?> translateToVietnamese(String text) async {
    try {
      if (text.trim().isEmpty) {
        print('⚠️ Văn bản rỗng, không thể dịch');
        return null;
      }

      print('🌐 Đang dịch: $text');

      // MyMemory API miễn phí: 1000 requests/ngày, không cần API key
      final url = Uri.parse(_baseUrl).replace(
        queryParameters: {
          'q': text,
          'langpair': 'en|vi', // English to Vietnamese
        },
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final translatedText = data['responseData']?['translatedText'];

        if (translatedText != null && translatedText.isNotEmpty) {
          print('✅ Dịch thành công: $translatedText');
          return translatedText;
        } else {
          print('⚠️ Không có kết quả dịch');
          return null;
        }
      } else {
        print('❌ Lỗi API dịch: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ Lỗi khi dịch: $e');
      return null;
    }
  }

  /// Dịch định nghĩa từ (có thể dài hơn)
  /// Tự động cắt nếu quá dài để tránh lỗi API
  Future<String?> translateDefinition(String definition) async {
    try {
      // Giới hạn 500 ký tự để tránh lỗi API
      final textToTranslate = definition.length > 500
          ? definition.substring(0, 500)
          : definition;

      return await translateToVietnamese(textToTranslate);
    } catch (e) {
      print('❌ Lỗi khi dịch định nghĩa: $e');
      return null;
    }
  }

  /// Dịch nhiều văn bản cùng lúc
  /// Sử dụng cho tương lai nếu cần
  Future<Map<String, String?>> translateMultiple(List<String> texts) async {
    final results = <String, String?>{};

    for (final text in texts) {
      // Delay 1 giây giữa các request để tránh rate limit
      await Future.delayed(const Duration(seconds: 1));
      results[text] = await translateToVietnamese(text);
    }

    return results;
  }
}
