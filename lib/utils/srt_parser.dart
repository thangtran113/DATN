/// Trình phân tích file phụ đề SRT
///
/// Hỗ trợ định dạng SRT chuẩn:
/// ```
/// 1
/// 00:00:01,000 --> 00:00:04,000
/// Hello world
///
/// 2
/// 00:00:05,000 --> 00:00:08,000
/// Second subtitle
/// ```
library;

import '../domain/entities/subtitle.dart';

class SrtParser {
  /// Phân tích nội dung file SRT thành List<Subtitle>
  ///
  /// Với phụ đề song ngữ (Tiếng Anh + Tiếng Việt):
  /// - Dòng 1: Text tiếng Anh
  /// - Dòng 2: Text tiếng Việt
  static List<Subtitle> parse(String srtContent) {
    final subtitles = <Subtitle>[];

    // Tách bằng ký tự xuống dòng kép (các khối phụ đề)
    final blocks = srtContent.split(RegExp(r'\n\s*\n'));

    for (final block in blocks) {
      if (block.trim().isEmpty) continue;

      try {
        final subtitle = _parseBlock(block);
        if (subtitle != null) {
          subtitles.add(subtitle);
        }
      } catch (e) {
        print('⚠️ Lỗi phân tích khối phụ đề: $e');
        // Bỏ qua các khối không hợp lệ
      }
    }

    return subtitles;
  }

  /// Phân tích một khối phụ đề
  static Subtitle? _parseBlock(String block) {
    final lines = block.split('\n').where((l) => l.trim().isNotEmpty).toList();

    if (lines.length < 2) return null;

    // Thử phân tích số thứ tự từ dòng đầu
    int? index = int.tryParse(lines[0].trim());
    int timestampLineIndex = 1;
    int textStartIndex = 2;

    // Nếu dòng đầu không phải số, có thể là timestamp
    if (index == null) {
      timestampLineIndex = 0;
      textStartIndex = 1;
      index = 0;
    }

    if (lines.length < textStartIndex + 1) return null;

    // Phân tích dòng timestamp (VD: "00:00:01,000 --> 00:00:04,000")
    final timestampMatch = RegExp(
      r'(\d{2}):(\d{2}):(\d{2}),(\d{3})\s*-->\s*(\d{2}):(\d{2}):(\d{2}),(\d{3})',
    ).firstMatch(lines[timestampLineIndex]);

    if (timestampMatch == null) return null;

    final startTime = _parseDuration(
      int.parse(timestampMatch.group(1)!), // giờ
      int.parse(timestampMatch.group(2)!), // phút
      int.parse(timestampMatch.group(3)!), // giây
      int.parse(timestampMatch.group(4)!), // mili giây
    );

    final endTime = _parseDuration(
      int.parse(timestampMatch.group(5)!), // giờ
      int.parse(timestampMatch.group(6)!), // phút
      int.parse(timestampMatch.group(7)!), // giây
      int.parse(timestampMatch.group(8)!), // mili giây
    );

    // Các dòng text bắt đầu sau timestamp
    String textEn = '';
    String textVi = '';

    if (lines.length > textStartIndex) {
      textEn = lines[textStartIndex].trim();
    }

    if (lines.length > textStartIndex + 1) {
      textVi = lines[textStartIndex + 1].trim();
    }

    // Nếu chỉ có 1 dòng text, dùng cho cả 2 ngôn ngữ
    if (textVi.isEmpty && textEn.isNotEmpty) {
      textVi = textEn;
    }

    return Subtitle(
      index: index,
      startTime: startTime,
      endTime: endTime,
      textEn: textEn,
      textVi: textVi,
    );
  }

  /// Phân tích duration từ giờ, phút, giây, mili giây
  static Duration _parseDuration(
    int hours,
    int minutes,
    int seconds,
    int milliseconds,
  ) {
    return Duration(
      hours: hours,
      minutes: minutes,
      seconds: seconds,
      milliseconds: milliseconds,
    );
  }

  /// Phân tích file SRT đơn ngữ
  /// Trả về list với cùng text cho cả Anh và Việt
  static List<Subtitle> parseMonolingual(String srtContent) {
    final subtitles = parse(srtContent);

    // Đảm bảo cả textEn và textVi đều có giá trị
    return subtitles.map((sub) {
      if (sub.textVi.isEmpty && sub.textEn.isNotEmpty) {
        return Subtitle(
          index: sub.index,
          startTime: sub.startTime,
          endTime: sub.endTime,
          textEn: sub.textEn,
          textVi: sub.textEn, // Dùng tiếng Anh cho cả 2
        );
      }
      return sub;
    }).toList();
  }

  /// Gộp 2 file SRT (Tiếng Anh + Tiếng Việt)
  /// Cả 2 file phải có cùng số lượng phụ đề và timestamp
  static List<Subtitle> mergeBilingual(
    String srtEnglish,
    String srtVietnamese,
  ) {
    final subsEn = parse(srtEnglish);
    final subsVi = parse(srtVietnamese);

    print(
      '🔀 Merging: EN=${subsEn.length} subtitles, VI=${subsVi.length} subtitles',
    );

    if (subsEn.length != subsVi.length) {
      print(
        '⚠️ Warning: English (${subsEn.length}) and Vietnamese (${subsVi.length}) subtitle counts differ',
      );
    }

    final merged = <Subtitle>[];

    for (int i = 0; i < subsEn.length; i++) {
      final en = subsEn[i];
      final vi = i < subsVi.length ? subsVi[i] : null;

      if (i < 3) {
        print(
          '🔀 Subtitle $i: EN="${en.textEn}" | VI="${vi?.textEn ?? 'missing'}"',
        );
      }

      merged.add(
        Subtitle(
          index: en.index,
          startTime: en.startTime,
          endTime: en.endTime,
          textEn: en.textEn,
          textVi: vi?.textEn ?? '', // Dùng text tiếng Việt
        ),
      );
    }

    return merged;
  }
}
