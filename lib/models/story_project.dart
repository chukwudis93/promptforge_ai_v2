import 'package:uuid/uuid.dart';
import 'scene.dart';
import 'character.dart';

/// A full story that has been (or is being) processed by the AI Director
/// into a list of scenes and a character database.
class StoryProject {
  final String id;
  String title;
  String rawStory;
  DateTime createdAt;
  DateTime updatedAt;
  List<Scene> scenes;
  List<StoryCharacter> characters;

  StoryProject({
    String? id,
    this.title = 'Untitled Story',
    this.rawStory = '',
    DateTime? createdAt,
    DateTime? updatedAt,
    List<Scene>? scenes,
    List<StoryCharacter>? characters,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now(),
        scenes = scenes ?? [],
        characters = characters ?? [];

  double get totalDurationSeconds =>
      scenes.fold(0.0, (sum, s) => sum + s.estimatedDurationSeconds);

  int get sceneCount => scenes.length;

  /// Rough heuristic estimate of AI video-generation time: most tools take
  /// roughly 25-40x the clip length to render. We show a range.
  String get estimatedGenerationTimeRange {
    final low = (totalDurationSeconds * 20 / 60).ceil();
    final high = (totalDurationSeconds * 45 / 60).ceil();
    return '$low-$high min';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'rawStory': rawStory,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'scenes': scenes.map((s) => s.toJson()).toList(),
        'characters': characters.map((c) => c.toJson()).toList(),
      };

  factory StoryProject.fromJson(Map<String, dynamic> json) => StoryProject(
        id: json['id'],
        title: json['title'] ?? 'Untitled Story',
        rawStory: json['rawStory'] ?? '',
        createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
        updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
        scenes: (json['scenes'] as List? ?? [])
            .map((s) => Scene.fromJson(s))
            .toList(),
        characters: (json['characters'] as List? ?? [])
            .map((c) => StoryCharacter.fromJson(c))
            .toList(),
      );
}
