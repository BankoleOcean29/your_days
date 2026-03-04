class JournalEntry {
  final int? id;
  final String date; // 'YYYY-MM-DD' — unique per day
  final String body; // decrypted body text (in memory); encrypted in DB
  final DateTime createdAt;
  final DateTime updatedAt;

  const JournalEntry({
    this.id,
    required this.date,
    required this.body,
    required this.createdAt,
    required this.updatedAt,
  });

  JournalEntry copyWith({String? body, DateTime? updatedAt}) {
    return JournalEntry(
      id: id,
      date: date,
      body: body ?? this.body,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Build from a DB row. [body] here is still encrypted — caller decrypts.
  factory JournalEntry.fromMap(Map<String, dynamic> map, {required String body}) {
    return JournalEntry(
      id: map['id'] as int?,
      date: map['date'] as String,
      body: body,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  /// Produces a map suitable for DB insertion. [encryptedBody] is pre-encrypted.
  Map<String, dynamic> toMap(String encryptedBody) {
    final map = <String, dynamic>{
      'date': date,
      'body': encryptedBody,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
    if (id != null) map['id'] = id;
    return map;
  }

  int get wordCount {
    final trimmed = body.trim();
    if (trimmed.isEmpty) return 0;
    return trimmed.split(RegExp(r'\s+')).length;
  }
}
