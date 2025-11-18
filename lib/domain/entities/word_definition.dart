/// Entity định nghĩa từ
/// Biểu diễn một từ với nghĩa, phát âm, ví dụ, v.v.
class WordDefinition {
  final String word;
  final String? phonetic;
  final List<Meaning> meanings;
  final List<String>? sourceUrls;

  WordDefinition({
    required this.word,
    this.phonetic,
    required this.meanings,
    this.sourceUrls,
  });

  factory WordDefinition.fromJson(Map<String, dynamic> json) {
    return WordDefinition(
      word: json['word'] ?? '',
      phonetic: json['phonetic'] as String?,
      meanings:
          (json['meanings'] as List<dynamic>?)
              ?.map((m) => Meaning.fromJson(m as Map<String, dynamic>))
              .toList() ??
          [],
      sourceUrls: (json['sourceUrls'] as List<dynamic>?)
          ?.map((url) => url.toString())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'word': word,
      'phonetic': phonetic,
      'meanings': meanings.map((m) => m.toJson()).toList(),
      'sourceUrls': sourceUrls,
    };
  }
}

/// Nghĩa của từ (loại từ + định nghĩa)
class Meaning {
  final String partOfSpeech; // danh từ, động từ, tính từ, v.v.
  final List<Definition> definitions;
  final List<String>? synonyms;
  final List<String>? antonyms;

  Meaning({
    required this.partOfSpeech,
    required this.definitions,
    this.synonyms,
    this.antonyms,
  });

  factory Meaning.fromJson(Map<String, dynamic> json) {
    return Meaning(
      partOfSpeech: json['partOfSpeech'] ?? '',
      definitions:
          (json['definitions'] as List<dynamic>?)
              ?.map((d) => Definition.fromJson(d as Map<String, dynamic>))
              .toList() ??
          [],
      synonyms: (json['synonyms'] as List<dynamic>?)
          ?.map((s) => s.toString())
          .toList(),
      antonyms: (json['antonyms'] as List<dynamic>?)
          ?.map((a) => a.toString())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'partOfSpeech': partOfSpeech,
      'definitions': definitions.map((d) => d.toJson()).toList(),
      'synonyms': synonyms,
      'antonyms': antonyms,
    };
  }
}

/// Định nghĩa riêng lẻ với ví dụ
class Definition {
  final String definition;
  final String? example;

  Definition({required this.definition, this.example});

  factory Definition.fromJson(Map<String, dynamic> json) {
    return Definition(
      definition: json['definition'] ?? '',
      example: json['example'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'definition': definition, 'example': example};
  }
}
