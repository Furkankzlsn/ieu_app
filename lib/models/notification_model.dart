class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String? link;
  final int timestamp;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    this.link,
    required this.timestamp,
  });

  factory NotificationModel.fromMap(String id, Map<String, dynamic> map) {
    return NotificationModel(
      id: id,
      title: map['title']?.toString() ?? '',
      body: map['body']?.toString() ?? '',
      link: map['link']?.toString(),
      timestamp: map['timestamp']?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'body': body,
      'link': link,
      'timestamp': timestamp,
    };
  }

  // Convenience getters
  DateTime get dateTime => DateTime.fromMillisecondsSinceEpoch(timestamp);
  bool get hasLink => link != null && link!.isNotEmpty;
  
  // Tarihi formatla
  String get formattedDate {
    final date = dateTime;
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Bugün';
    } else if (difference.inDays == 1) {
      return 'Dün';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} gün önce';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
