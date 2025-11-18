import 'package:flutter/material.dart';
import 'package:translator/translator.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../domain/entities/word_definition.dart';

/// Widget popup từ điển
/// Hiển thị định nghĩa từ trong bottom sheet
class DictionaryPopup extends StatefulWidget {
  final WordDefinition wordDefinition;
  final VoidCallback? onSaveWord;

  const DictionaryPopup({
    Key? key,
    required this.wordDefinition,
    this.onSaveWord,
  }) : super(key: key);

  @override
  State<DictionaryPopup> createState() => _DictionaryPopupState();
}

class _DictionaryPopupState extends State<DictionaryPopup> {
  final _translator = GoogleTranslator();
  final _flutterTts = FlutterTts();
  final Map<String, String> _translationCache = {};
  bool _isSpeaking = false;

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  /// Khởi tạo Text-to-Speech
  Future<void> _initTts() async {
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setSpeechRate(0.5); // Tốc độ chậm để học
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);

    _flutterTts.setCompletionHandler(() {
      setState(() => _isSpeaking = false);
    });

    _flutterTts.setErrorHandler((msg) {
      print('❌ TTS Error: $msg');
      setState(() => _isSpeaking = false);
    });
  }

  /// Phát âm từ
  Future<void> _speakWord() async {
    if (_isSpeaking) {
      await _flutterTts.stop();
      setState(() => _isSpeaking = false);
      return;
    }

    setState(() => _isSpeaking = true);
    await _flutterTts.speak(widget.wordDefinition.word);
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  Future<String> _translateText(String text) async {
    if (_translationCache.containsKey(text)) {
      return _translationCache[text]!;
    }

    try {
      final translation = await _translator.translate(
        text,
        from: 'en',
        to: 'vi',
      );
      _translationCache[text] = translation.text;
      return translation.text;
    } catch (e) {
      print('Translation error: $e');
      return text; // Trả về text gốc nếu dịch lỗi
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Thanh kéo
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            decoration: BoxDecoration(
              color: Colors.grey[600],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Tiêu đề
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            widget.wordDefinition.word,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Nút phát âm
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: _speakWord,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: _isSpeaking
                                      ? const Color(0xFF0EA5E9)
                                      : Colors.grey[800],
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Icon(
                                  _isSpeaking ? Icons.stop : Icons.volume_up,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (widget.wordDefinition.phonetic != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          widget.wordDefinition.phonetic!,
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // Nút lưu
                IconButton(
                  icon: const Icon(Icons.bookmark_border, color: Colors.white),
                  onPressed: () {
                    widget.onSaveWord?.call();
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Đã lưu "${widget.wordDefinition.word}" vào từ vựng',
                        ),
                        duration: const Duration(seconds: 2),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  tooltip: 'Lưu vào từ vựng',
                ),
                // Nút đóng
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          const Divider(color: Colors.grey, height: 1),

          // Nội dung
          Flexible(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              shrinkWrap: true,
              itemCount: widget.wordDefinition.meanings.length,
              itemBuilder: (context, index) {
                final meaning = widget.wordDefinition.meanings[index];
                return _buildMeaningSection(meaning);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeaningSection(Meaning meaning) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Loại từ
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF0EA5E9),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              meaning.partOfSpeech,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Định nghĩa (chỉ hiển thị definition đầu tiên, dịch sang tiếng Việt)
          if (meaning.definitions.isNotEmpty) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nghĩa: ',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Expanded(
                  child: FutureBuilder<String>(
                    future: _translateText(
                      meaning.definitions.first.definition,
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Row(
                          children: [
                            SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.grey[500],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Đang dịch...',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 14,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        );
                      }
                      return Text(
                        snapshot.data ?? meaning.definitions.first.definition,
                        style: TextStyle(
                          color: Colors.grey[200],
                          fontSize: 16,
                          height: 1.5,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],

          // Từ đồng nghĩa
          if (meaning.synonyms != null && meaning.synonyms!.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildTagsList('Đồng nghĩa', meaning.synonyms!, Colors.green[700]!),
          ],

          // Từ trái nghĩa
          if (meaning.antonyms != null && meaning.antonyms!.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildTagsList('Trái nghĩa', meaning.antonyms!, Colors.red[700]!),
          ],
        ],
      ),
    );
  }

  Widget _buildTagsList(String title, List<String> tags, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 3,
              height: 14,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: tags.take(4).map((tag) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withValues(alpha: 0.3)),
              ),
              child: Text(
                tag,
                style: TextStyle(color: Colors.grey[300], fontSize: 12),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
