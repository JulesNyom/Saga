// lib/models/audio_book.dart
class AudioChapter {
  final int number;
  final String title;
  final String duration;
  final String audioUrl;
  final double startTime;

  AudioChapter({
    required this.number,
    required this.title,
    required this.duration,
    required this.audioUrl,
    required this.startTime,
  });

  factory AudioChapter.fromJson(Map<String, dynamic> json) {
    return AudioChapter(
      number: json['number'],
      title: json['title'],
      duration: json['duration'],
      audioUrl: json['audio_url'],
      startTime: json['start_time'].toDouble(),
    );
  }
}

class AudioBook {
  final String id;
  final String title;
  final String author;
  final String imageUrl;
  final String duration;
  final String views;
  final String url;
  final String? narrator;
  final String? date;
  final String? description;
  final List<AudioChapter> chapters;

  AudioBook({
    required this.id,
    required this.title,
    required this.author,
    required this.imageUrl,
    required this.duration,
    required this.views,
    required this.url,
    this.narrator,
    this.date,
    this.description,
    required this.chapters,
  });

  factory AudioBook.fromJson(Map<String, dynamic> json) {
    return AudioBook(
      id: json['id'],
      title: json['title'],
      author: json['author'],
      imageUrl: json['imageUrl'],
      duration: json['duration'],
      views: json['views'],
      url: json['url'],
      narrator: json['narrator'],
      date: json['date'],
      description: json['description'],
      chapters: (json['chapters'] as List)
          .map((chapter) => AudioChapter.fromJson(chapter))
          .toList(),
    );
  }
}