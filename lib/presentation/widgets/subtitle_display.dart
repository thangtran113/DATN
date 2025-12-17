import 'package:flutter/material.dart';
import '../../domain/entities/subtitle.dart';

class SubtitleDisplay extends StatefulWidget {
  final Subtitle? currentSubtitle;
  final VoidCallback? onTap;
  final bool showVietnamese;
  final double fontSize;
  final Function(String)? onWordTap; // Callback when word is clicked

  const SubtitleDisplay({
    Key? key,
    required this.currentSubtitle,
    this.onTap,
    this.showVietnamese = true,
    this.fontSize = 36.0,
    this.onWordTap,
  }) : super(key: key);

  @override
  State<SubtitleDisplay> createState() => _SubtitleDisplayState();
}

class _SubtitleDisplayState extends State<SubtitleDisplay> {
  String? _highlightedWord;

  void _onWordTap(String word) {
    setState(() {
      _highlightedWord = word.toLowerCase();
    });
    widget.onWordTap?.call(word);

    // Reset highlight sau 2 giây
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _highlightedWord = null;
        });
      }
    });
  }

  @override
  void didUpdateWidget(SubtitleDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reset highlight khi phụ đề thay đổi
    if (oldWidget.currentSubtitle?.textEn != widget.currentSubtitle?.textEn) {
      _highlightedWord = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.currentSubtitle == null) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Phụ đề tiếng Anh (có thể click từ)
            widget.onWordTap != null
                ? _buildClickableText(
                    widget.currentSubtitle!.textEn,
                    TextStyle(
                      color: Colors.white,
                      fontSize: widget.fontSize + 2,
                      fontWeight: FontWeight.w700,
                      height: 1.5,
                      shadows: [
                        // Viền đen đậm xung quanh (4 hướng)
                        Shadow(
                          offset: const Offset(-1.5, -1.5),
                          blurRadius: 0,
                          color: Colors.black,
                        ),
                        Shadow(
                          offset: const Offset(1.5, -1.5),
                          blurRadius: 0,
                          color: Colors.black,
                        ),
                        Shadow(
                          offset: const Offset(1.5, 1.5),
                          blurRadius: 0,
                          color: Colors.black,
                        ),
                        Shadow(
                          offset: const Offset(-1.5, 1.5),
                          blurRadius: 0,
                          color: Colors.black,
                        ),
                        // Shadow mềm thêm độ sâu
                        Shadow(
                          offset: const Offset(0, 2),
                          blurRadius: 4,
                          color: Colors.black.withValues(alpha: 0.8),
                        ),
                      ],
                    ),
                  )
                : Text(
                    widget.currentSubtitle!.textEn,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: widget.fontSize + 2,
                      fontWeight: FontWeight.w700,
                      height: 1.5,
                      shadows: [
                        // Viền đen đậm xung quanh (4 hướng)
                        Shadow(
                          offset: const Offset(-1.5, -1.5),
                          blurRadius: 0,
                          color: Colors.black,
                        ),
                        Shadow(
                          offset: const Offset(1.5, -1.5),
                          blurRadius: 0,
                          color: Colors.black,
                        ),
                        Shadow(
                          offset: const Offset(1.5, 1.5),
                          blurRadius: 0,
                          color: Colors.black,
                        ),
                        Shadow(
                          offset: const Offset(-1.5, 1.5),
                          blurRadius: 0,
                          color: Colors.black,
                        ),
                        // Shadow mềm thêm độ sâu
                        Shadow(
                          offset: const Offset(0, 2),
                          blurRadius: 4,
                          color: Colors.black.withValues(alpha: 0.8),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),

            // Phụ đề tiếng Việt
            if (widget.showVietnamese) ...[
              const SizedBox(height: 6),
              Text(
                widget.currentSubtitle!.textVi,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: widget.fontSize,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                  shadows: [
                    // Viền đen đậm xung quanh (4 hướng)
                    Shadow(
                      offset: const Offset(-1.5, -1.5),
                      blurRadius: 0,
                      color: Colors.black,
                    ),
                    Shadow(
                      offset: const Offset(1.5, -1.5),
                      blurRadius: 0,
                      color: Colors.black,
                    ),
                    Shadow(
                      offset: const Offset(1.5, 1.5),
                      blurRadius: 0,
                      color: Colors.black,
                    ),
                    Shadow(
                      offset: const Offset(-1.5, 1.5),
                      blurRadius: 0,
                      color: Colors.black,
                    ),
                    // Shadow mềm thêm độ sâu
                    Shadow(
                      offset: const Offset(0, 2),
                      blurRadius: 4,
                      color: Colors.black.withValues(alpha: 0.8),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Build clickable text where each word is tappable
  Widget _buildClickableText(String text, TextStyle style) {
    // Tách văn bản thành các từ
    final words = text.split(RegExp(r'\s+'));

    return Wrap(
      alignment: WrapAlignment.center,
      children: words.map((word) {
        // Trích xuất từ thuần (xóa dấu câu để tra từ nhưng giữ lại để hiển thị)
        final cleanWord = word.replaceAll(RegExp(r'[^\w\s-]'), '');
        final isHighlighted =
            _highlightedWord != null &&
            cleanWord.toLowerCase() == _highlightedWord;

        return GestureDetector(
          onTap: () {
            if (cleanWord.isNotEmpty) {
              _onWordTap(cleanWord);
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 2),
            decoration: isHighlighted
                ? BoxDecoration(
                    color: const Color(0xFF0EA5E9).withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(4),
                  )
                : null,
            child: Text(
              word,
              style: style.copyWith(
                color: isHighlighted
                    ? const Color(0xFFFFD700) // Vàng khi highlight
                    : Colors.white,
                decoration: null, // Bỏ underline để giống Netflix
                fontWeight: isHighlighted ? FontWeight.w800 : FontWeight.w700,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
