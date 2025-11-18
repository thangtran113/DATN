class Subtitle {
  final int index;
  final Duration startTime;
  final Duration endTime;
  final String textEn;
  final String textVi;

  Subtitle({
    required this.index,
    required this.startTime,
    required this.endTime,
    required this.textEn,
    required this.textVi,
  });

  bool isActiveAt(Duration position) {
    return position >= startTime && position < endTime;
  }

  factory Subtitle.fromJson(Map<String, dynamic> json) {
    return Subtitle(
      index: json['index'] as int,
      startTime: Duration(milliseconds: json['startTime'] as int),
      endTime: Duration(milliseconds: json['endTime'] as int),
      textEn: json['textEn'] as String,
      textVi: json['textVi'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'index': index,
      'startTime': startTime.inMilliseconds,
      'endTime': endTime.inMilliseconds,
      'textEn': textEn,
      'textVi': textVi,
    };
  }

  @override
  String toString() {
    return 'Subtitle(index: $index, time: ${_formatTime(startTime)} --> ${_formatTime(endTime)}, en: $textEn, vi: $textVi)';
  }

  String _formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    final milliseconds = duration.inMilliseconds.remainder(1000);
    return '${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(seconds)},${milliseconds.toString().padLeft(3, '0')}';
  }
}
