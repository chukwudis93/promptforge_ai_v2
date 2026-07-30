import 'package:uuid/uuid.dart';

/// Auto-generated character profile used to guarantee visual and
/// personality consistency for a recurring character across every scene.
class StoryCharacter {
  final String id;
  String name;
  String age;
  String gender;
  String ethnicity;
  String height;
  String bodyBuild;
  String skinTone;
  String faceShape;
  String eyes;
  String hairStyle;
  String hairColor;
  String facialHair;
  String clothing;
  String accessories;
  String voiceDescription;
  String walkingStyle;
  String personality;
  String facialExpressions;
  String speakingStyle;
  String lockedAppearanceNotes;
  String continuityNotes;

  StoryCharacter({
    String? id,
    this.name = '',
    this.age = '',
    this.gender = '',
    this.ethnicity = '',
    this.height = '',
    this.bodyBuild = '',
    this.skinTone = '',
    this.faceShape = '',
    this.eyes = '',
    this.hairStyle = '',
    this.hairColor = '',
    this.facialHair = '',
    this.clothing = '',
    this.accessories = '',
    this.voiceDescription = '',
    this.walkingStyle = '',
    this.personality = '',
    this.facialExpressions = '',
    this.speakingStyle = '',
    this.lockedAppearanceNotes = '',
    this.continuityNotes = '',
  }) : id = id ?? const Uuid().v4();

  /// A compact block that can be copied and pasted at the top of any
  /// scene prompt to lock this character's appearance.
  String buildProfileText() {
    final b = StringBuffer();
    b.writeln('CHARACTER: $name');
    b.writeln('Age: $age   Gender: $gender   Ethnicity: $ethnicity');
    b.writeln('Height: $height   Build: $bodyBuild   Skin Tone: $skinTone');
    b.writeln('Face Shape: $faceShape   Eyes: $eyes');
    b.writeln(
        'Hair: $hairStyle, $hairColor   Facial Hair: $facialHair');
    b.writeln('Clothing: $clothing');
    b.writeln('Accessories: $accessories');
    b.writeln('Voice: $voiceDescription   Speaking Style: $speakingStyle');
    b.writeln('Walking Style: $walkingStyle');
    b.writeln('Personality: $personality');
    b.writeln('Typical Expressions: $facialExpressions');
    b.writeln('LOCKED APPEARANCE (must not change): $lockedAppearanceNotes');
    b.writeln('Continuity Notes: $continuityNotes');
    return b.toString();
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'age': age,
        'gender': gender,
        'ethnicity': ethnicity,
        'height': height,
        'bodyBuild': bodyBuild,
        'skinTone': skinTone,
        'faceShape': faceShape,
        'eyes': eyes,
        'hairStyle': hairStyle,
        'hairColor': hairColor,
        'facialHair': facialHair,
        'clothing': clothing,
        'accessories': accessories,
        'voiceDescription': voiceDescription,
        'walkingStyle': walkingStyle,
        'personality': personality,
        'facialExpressions': facialExpressions,
        'speakingStyle': speakingStyle,
        'lockedAppearanceNotes': lockedAppearanceNotes,
        'continuityNotes': continuityNotes,
      };

  factory StoryCharacter.fromJson(Map<String, dynamic> json) =>
      StoryCharacter(
        id: json['id'],
        name: json['name'] ?? '',
        age: json['age'] ?? '',
        gender: json['gender'] ?? '',
        ethnicity: json['ethnicity'] ?? '',
        height: json['height'] ?? '',
        bodyBuild: json['bodyBuild'] ?? '',
        skinTone: json['skinTone'] ?? '',
        faceShape: json['faceShape'] ?? '',
        eyes: json['eyes'] ?? '',
        hairStyle: json['hairStyle'] ?? '',
        hairColor: json['hairColor'] ?? '',
        facialHair: json['facialHair'] ?? '',
        clothing: json['clothing'] ?? '',
        accessories: json['accessories'] ?? '',
        voiceDescription: json['voiceDescription'] ?? '',
        walkingStyle: json['walkingStyle'] ?? '',
        personality: json['personality'] ?? '',
        facialExpressions: json['facialExpressions'] ?? '',
        speakingStyle: json['speakingStyle'] ?? '',
        lockedAppearanceNotes: json['lockedAppearanceNotes'] ?? '',
        continuityNotes: json['continuityNotes'] ?? '',
      );
}
