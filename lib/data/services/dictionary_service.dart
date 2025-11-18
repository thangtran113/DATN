import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/entities/word_definition.dart';

/// Service tra cứu từ điển
/// Lấy định nghĩa từ từ Free Dictionary API
class DictionaryService {
  static const String _baseUrl =
      'https://api.dictionaryapi.dev/api/v2/entries/en';

  /// Tra cứu từ và lấy định nghĩa
  ///
  /// Trả về null nếu không tìm thấy hoặc có lỗi
  Future<WordDefinition?> lookupWord(String word) async {
    try {
      // Làm sạch từ (lowercase, trim, xóa dấu câu)
      final cleanWord = _cleanWord(word);

      if (cleanWord.isEmpty) {
        print('⚠️ Từ rỗng sau khi làm sạch');
        return null;
      }

      print('📖 Đang tra cứu từ: $cleanWord');

      final url = Uri.parse('$_baseUrl/$cleanWord');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);

        if (jsonList.isEmpty) {
          print('⚠️ Không tìm thấy định nghĩa cho: $cleanWord');
          return null;
        }

        // Lấy kết quả đầu tiên (thường là phổ biến nhất)
        final wordData = jsonList[0] as Map<String, dynamic>;
        final definition = WordDefinition.fromJson(wordData);

        print('✅ Tìm thấy ${definition.meanings.length} nghĩa cho: $cleanWord');
        return definition;
      } else if (response.statusCode == 404) {
        print('❌ Không tìm thấy từ: $cleanWord');
        return null;
      } else {
        print('❌ Lỗi API từ điển: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ Lỗi tra cứu từ: $e');
      return null;
    }
  }

  /// Làm sạch từ trước khi tra API
  /// - Chuyển thành chữ thường
  /// - Xóa khoảng trắng thừa
  /// - Xóa dấu câu (giữ dấu gạch ngang trong từ ghép)
  String _cleanWord(String word) {
    return word
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s-]'), '') // Xóa dấu câu trừ gạch ngang
        .replaceAll(RegExp(r'\s+'), '-'); // Thay khoảng trắng bằng gạch ngang
  }

  /// Tra cứu nhiều từ cùng lúc (dùng cho tương lai)
  Future<Map<String, WordDefinition?>> lookupWords(List<String> words) async {
    final results = <String, WordDefinition?>{};

    for (final word in words) {
      results[word] = await lookupWord(word);
    }

    return results;
  }
}
