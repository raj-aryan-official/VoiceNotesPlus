import 'package:hive/hive.dart';

part 'note.g.dart';

@HiveType(typeId: 0)
class Note extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  String audioPath;

  @HiveField(2)
  String transcript;

  @HiveField(3)
  bool isLiked;

  @HiveField(4)
  int createdAtMillis;

  Note({
    required this.id,
    required this.audioPath,
    required this.transcript,
    this.isLiked = false,
    DateTime? createdAt,
    int? createdAtMillis,
  }) : createdAtMillis =
           createdAtMillis ??
           (createdAt?.millisecondsSinceEpoch ??
               DateTime.now().millisecondsSinceEpoch);

  DateTime get createdAt =>
      DateTime.fromMillisecondsSinceEpoch(createdAtMillis);

  Note copyWith({
    int? id,
    String? audioPath,
    String? transcript,
    bool? isLiked,
    DateTime? createdAt,
    int? createdAtMillis,
  }) {
    return Note(
      id: id ?? this.id,
      audioPath: audioPath ?? this.audioPath,
      transcript: transcript ?? this.transcript,
      isLiked: isLiked ?? this.isLiked,
      createdAtMillis:
          createdAtMillis ??
          (createdAt?.millisecondsSinceEpoch ?? this.createdAtMillis),
    );
  }
}
