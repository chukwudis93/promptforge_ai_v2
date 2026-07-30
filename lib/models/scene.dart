import 'package:uuid/uuid.dart';

/// Duration status used to color-code pacing warnings in the UI.
enum DurationStatus { green, yellow, red }

DurationStatus statusForDuration(double seconds) {
  if (seconds <= 8) return DurationStatus.green;
  if (seconds <= 10) return DurationStatus.yellow;
  return DurationStatus.red;
}

/// A single line of dialogue inside a scene's dialogue editor.
class DialogueLine {
  String characterName;
  String dialogue;
  String delivery; // e.g. "Whispered, trembling"
  String timing; // e.g. "0:02 - 0:05"
  String pause; // e.g. "1.5s pause after"

  DialogueLine({
    this.characterName = '',
    this.dialogue = '',
    this.delivery = '',
    this.timing = '',
    this.pause = '',
  });

  Map<String, dynamic> toJson() => {
        'characterName': characterName,
        'dialogue': dialogue,
        'delivery': delivery,
        'timing': timing,
        'pause': pause,
      };

  factory DialogueLine.fromJson(Map<String, dynamic> json) => DialogueLine(
        characterName: json['characterName'] ?? '',
        dialogue: json['dialogue'] ?? '',
        delivery: json['delivery'] ?? '',
        timing: json['timing'] ?? '',
        pause: json['pause'] ?? '',
      );
}

/// One scene of the generated movie, following the full 16-section
/// cinematic blueprint used across PromptForge AI.
class Scene {
  final String id;
  int sceneNumber;

  // 1. Scene Summary
  String sceneSummary;
  // 2. Subject
  String subject;
  // 3. Setting
  String setting;
  // 4. Camera Angle
  String cameraAngle;
  // 5. Camera Movement
  String cameraMovement;
  // 6. Motion / Action
  String motionAction;
  // 7. Duration / Pacing (estimated automatically)
  double estimatedDurationSeconds;
  // 8. Lighting
  String lighting;
  String lightingNote;
  // 9. Color Palette
  String colorPalette;
  // 10. Style
  String style;
  // 11. Dialogue
  List<DialogueLine> dialogue;
  // 12. Intonation
  String intonation;
  // 13. Sound Design
  String soundDesign;
  // 14. Atmosphere
  String atmosphere;
  // 15. Continuity
  String continuity;
  // 16. Negative Prompt
  String negativePrompt;

  Scene({
    String? id,
    required this.sceneNumber,
    this.sceneSummary = '',
    this.subject = '',
    this.setting = '',
    this.cameraAngle = 'Eye Level',
    this.cameraMovement = 'Static',
    this.motionAction = '',
    this.estimatedDurationSeconds = 0,
    this.lighting = 'Golden Hour',
    this.lightingNote = '',
    this.colorPalette = 'Cinematic',
    this.style = 'Ultra Cinematic',
    List<DialogueLine>? dialogue,
    this.intonation = 'Calm',
    this.soundDesign = '',
    this.atmosphere = 'Epic',
    this.continuity = '',
    this.negativePrompt =
        'No blur, no watermark, no extra limbs, no duplicate people, '
            'no text, no logo, no modern objects, no deformed hands.',
  })  : id = id ?? const Uuid().v4(),
        dialogue = dialogue ?? [];

  DurationStatus get durationStatus =>
      statusForDuration(estimatedDurationSeconds);

  /// Builds the full, human-readable cinematic prompt for this scene,
  /// suitable for pasting into Google Flow, Veo, Kling, Runway, Pika, or Sora.
  String buildPrompt() {
    final buffer = StringBuffer();
    buffer.writeln('SCENE $sceneNumber');
    buffer.writeln('Scene Summary: $sceneSummary');
    buffer.writeln();
    buffer.writeln('Subject: $subject');
    buffer.writeln('Setting: $setting');
    buffer.writeln('Camera Angle: $cameraAngle');
    buffer.writeln('Camera Movement: $cameraMovement');
    buffer.writeln('Motion / Action: $motionAction');
    buffer.writeln(
        'Duration: ${estimatedDurationSeconds.toStringAsFixed(1)}s');
    buffer.writeln(
        'Lighting: $lighting${lightingNote.isNotEmpty ? ' ($lightingNote)' : ''}');
    buffer.writeln('Color Palette: $colorPalette');
    buffer.writeln('Style: $style');
    if (dialogue.isNotEmpty) {
      buffer.writeln('Dialogue:');
      for (final d in dialogue) {
        buffer.writeln(
            '  ${d.characterName}: "${d.dialogue}" [${d.delivery}${d.timing.isNotEmpty ? ', ${d.timing}' : ''}]');
      }
    }
    buffer.writeln('Intonation: $intonation');
    buffer.writeln('Sound Design: $soundDesign');
    buffer.writeln('Atmosphere: $atmosphere');
    buffer.writeln('Continuity: $continuity');
    buffer.writeln('Negative Prompt: $negativePrompt');
    return buffer.toString();
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'sceneNumber': sceneNumber,
        'sceneSummary': sceneSummary,
        'subject': subject,
        'setting': setting,
        'cameraAngle': cameraAngle,
        'cameraMovement': cameraMovement,
        'motionAction': motionAction,
        'estimatedDurationSeconds': estimatedDurationSeconds,
        'lighting': lighting,
        'lightingNote': lightingNote,
        'colorPalette': colorPalette,
        'style': style,
        'dialogue': dialogue.map((d) => d.toJson()).toList(),
        'intonation': intonation,
        'soundDesign': soundDesign,
        'atmosphere': atmosphere,
        'continuity': continuity,
        'negativePrompt': negativePrompt,
      };

  factory Scene.fromJson(Map<String, dynamic> json) => Scene(
        id: json['id'],
        sceneNumber: json['sceneNumber'] ?? 1,
        sceneSummary: json['sceneSummary'] ?? '',
        subject: json['subject'] ?? '',
        setting: json['setting'] ?? '',
        cameraAngle: json['cameraAngle'] ?? 'Eye Level',
        cameraMovement: json['cameraMovement'] ?? 'Static',
        motionAction: json['motionAction'] ?? '',
        estimatedDurationSeconds:
            (json['estimatedDurationSeconds'] ?? 0).toDouble(),
        lighting: json['lighting'] ?? 'Golden Hour',
        lightingNote: json['lightingNote'] ?? '',
        colorPalette: json['colorPalette'] ?? 'Cinematic',
        style: json['style'] ?? 'Ultra Cinematic',
        dialogue: (json['dialogue'] as List? ?? [])
            .map((d) => DialogueLine.fromJson(d))
            .toList(),
        intonation: json['intonation'] ?? 'Calm',
        soundDesign: json['soundDesign'] ?? '',
        atmosphere: json['atmosphere'] ?? 'Epic',
        continuity: json['continuity'] ?? '',
        negativePrompt: json['negativePrompt'] ?? '',
      );
}
