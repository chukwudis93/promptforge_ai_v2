import 'dart:math';
import '../models/scene.dart';
import '../models/character.dart';
import '../models/story_project.dart';
import 'ai_service.dart';

/// A local, offline stand-in for the real AI Director.
///
/// It uses simple heuristics (sentence/paragraph splitting, capitalized
/// word detection for character names, keyword matching for lighting /
/// atmosphere / camera choices) so the full app flow — paste story ->
/// scenes -> characters -> export — works before a real model is wired
/// into [AiService.processStory].
///
/// Swap this out for e.g. `ClaudeAiService` once you're ready to call a
/// real model; nothing else in the app needs to change.
class MockAiService implements AiService {
  final Random _rand = Random();

  @override
  Future<StoryProject> processStory({
    required String rawStory,
    String? title,
  }) async {
    // Simulate processing latency so the UI can show a progress state.
    await Future.delayed(const Duration(milliseconds: 900));

    final cleaned = _cleanText(rawStory);
    final paragraphs = _splitIntoBeats(cleaned);
    final characterNames = _detectCharacterNames(cleaned);

    final scenes = <Scene>[];
    int sceneNumber = 1;
    for (final beat in paragraphs) {
      // Long paragraphs get split further so no scene exceeds ~10s.
      for (final chunk in _capTo10Seconds(beat)) {
        scenes.add(_buildScene(chunk, sceneNumber, characterNames));
        sceneNumber++;
      }
    }

    final characters = characterNames
        .map((name) => _buildCharacterProfile(name, cleaned))
        .toList();

    return StoryProject(
      title: title?.trim().isNotEmpty == true ? title!.trim() : _deriveTitle(cleaned),
      rawStory: rawStory,
      scenes: scenes,
      characters: characters,
    );
  }

  @override
  Future<Scene> regenerateScene({
    required StoryProject project,
    required Scene scene,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final names = project.characters.map((c) => c.name).toList();
    final regenerated = _buildScene(scene.sceneSummary.isNotEmpty
        ? scene.sceneSummary
        : scene.motionAction, scene.sceneNumber, names);
    // Preserve continuity/negative prompt notes the user may have edited.
    regenerated.continuity = scene.continuity;
    regenerated.negativePrompt = scene.negativePrompt;
    return regenerated;
  }

  // ---------------------------------------------------------------------
  // Heuristic pipeline (stand-ins for real NLP/LLM steps)
  // ---------------------------------------------------------------------

  String _cleanText(String input) {
    // Basic grammar/formatting repair: collapse whitespace, fix spacing
    // around punctuation. A real backend would do far more here.
    var text = input.trim();
    text = text.replaceAll(RegExp(r'\s+'), ' ');
    text = text.replaceAll(RegExp(r'\s+([.,!?;:])'), r'$1');
    return text;
  }

  String _deriveTitle(String cleaned) {
    final firstSentence = cleaned.split(RegExp(r'(?<=[.!?])\s')).first;
    final words = firstSentence.split(' ').take(6).join(' ');
    return words.isEmpty ? 'Untitled Story' : words;
  }

  /// Splits the story into narrative "beats" (roughly: sentences grouped
  /// by scene-level shifts such as new paragraphs or strong transition
  /// words like "Later", "Meanwhile", "Suddenly").
  List<String> _splitIntoBeats(String cleaned) {
    final sentences = cleaned
        .split(RegExp(r'(?<=[.!?])\s+'))
        .where((s) => s.trim().isNotEmpty)
        .toList();

    final beats = <String>[];
    final buffer = StringBuffer();
    int wordCount = 0;

    for (final sentence in sentences) {
      final isTransition = RegExp(
              r'^(Later|Meanwhile|Suddenly|The next day|Afterward|Then|Elsewhere)',
              caseSensitive: false)
          .hasMatch(sentence.trim());

      if (isTransition && buffer.isNotEmpty) {
        beats.add(buffer.toString().trim());
        buffer.clear();
        wordCount = 0;
      }

      buffer.write('${sentence.trim()} ');
      wordCount += sentence.split(' ').length;

      // Roughly ~2 short sentences (~20-25 words) is about as much action
      // as fits in a single sub-10-second cinematic shot.
      if (wordCount >= 22) {
        beats.add(buffer.toString().trim());
        buffer.clear();
        wordCount = 0;
      }
    }
    if (buffer.isNotEmpty) beats.add(buffer.toString().trim());
    return beats.isEmpty ? [cleaned] : beats;
  }

  /// Further splits an already-short beat if its estimated duration would
  /// still exceed 10 seconds, guaranteeing the hard cap from the spec.
  List<String> _capTo10Seconds(String beat) {
    final estimate = _estimateDuration(beat);
    if (estimate <= 10) return [beat];

    final sentences = beat.split(RegExp(r'(?<=[.!?])\s+'));
    if (sentences.length <= 1) return [beat]; // can't split further safely
    final mid = (sentences.length / 2).ceil();
    final first = sentences.sublist(0, mid).join(' ');
    final second = sentences.sublist(mid).join(' ');
    return [..._capTo10Seconds(first), ..._capTo10Seconds(second)];
  }

  /// Rough words-per-second estimate for narration + action pacing.
  double _estimateDuration(String text) {
    final words = text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
    // ~2.3 words/sec is a natural narration+action pace; add a small
    // per-scene base for camera settle time.
    final estimate = 1.2 + (words / 2.3);
    return double.parse(estimate.toStringAsFixed(1));
  }

  /// Naive proper-noun detector: capitalized words that aren't sentence-
  /// initial and aren't common stopwords. Good enough for a mock; a real
  /// model would use proper NER.
  List<String> _detectCharacterNames(String cleaned) {
    final stopwords = {
      'The', 'A', 'An', 'He', 'She', 'They', 'It', 'I', 'We', 'You',
      'Later', 'Meanwhile', 'Suddenly', 'Then', 'Afterward', 'Elsewhere',
    };
    final sentences = cleaned.split(RegExp(r'(?<=[.!?])\s+'));
    final counts = <String, int>{};

    for (final sentence in sentences) {
      final words = sentence.split(RegExp(r'\s+'));
      for (int i = 0; i < words.length; i++) {
        final word = words[i].replaceAll(RegExp(r'[^A-Za-z]'), '');
        if (word.isEmpty) continue;
        final isCapitalized = word[0] == word[0].toUpperCase() &&
            RegExp(r'[A-Za-z]').hasMatch(word[0]);
        final isSentenceStart = i == 0;
        if (isCapitalized && !isSentenceStart && !stopwords.contains(word)) {
          counts[word] = (counts[word] ?? 0) + 1;
        }
      }
    }
    // Keep names mentioned more than once — recurring characters only.
    final names = counts.entries
        .where((e) => e.value > 1)
        .map((e) => e.key)
        .toSet()
        .toList();
    if (names.isEmpty && counts.isNotEmpty) {
      names.add(counts.entries.first.key);
    }
    return names;
  }

  Scene _buildScene(String beat, int sceneNumber, List<String> knownNames) {
    final duration = _estimateDuration(beat);
    final mentionedName =
        knownNames.firstWhere((n) => beat.contains(n), orElse: () => '');

    final lightingOptions = [
      'Golden Hour', 'Soft Morning', 'Moonlight', 'Torch Light', 'Overcast'
    ];
    final atmosphereOptions = [
      'Tense', 'Epic', 'Sacred', 'Hopeful', 'Dark', 'Peaceful'
    ];
    final cameraAngles = [
      'Eye Level', 'Low Angle', 'Wide Shot', 'Medium Shot', 'Close Up'
    ];
    final cameraMovements = [
      'Static', 'Push In', 'Slow Zoom', 'Tracking', 'Pan Right'
    ];

    return Scene(
      sceneNumber: sceneNumber,
      sceneSummary: _summarize(beat),
      subject: mentionedName.isNotEmpty
          ? '$mentionedName — see Character Sheet for full locked appearance.'
          : 'See story context; describe the primary figure in this beat.',
      setting: _guessSetting(beat),
      cameraAngle: cameraAngles[_rand.nextInt(cameraAngles.length)],
      cameraMovement: cameraMovements[_rand.nextInt(cameraMovements.length)],
      motionAction: beat.trim(),
      estimatedDurationSeconds: duration,
      lighting: lightingOptions[_rand.nextInt(lightingOptions.length)],
      colorPalette: 'Cinematic',
      style: 'Ultra Cinematic',
      intonation: 'Calm',
      soundDesign: _guessSoundDesign(beat),
      atmosphere: atmosphereOptions[_rand.nextInt(atmosphereOptions.length)],
      continuity: mentionedName.isNotEmpty
          ? 'Keep $mentionedName\'s clothing, hairstyle, and age identical to their character sheet.'
          : 'Maintain consistent setting and lighting with the previous scene.',
    );
  }

  String _summarize(String beat) {
    final firstSentence = beat.split(RegExp(r'(?<=[.!?])\s')).first.trim();
    return firstSentence;
  }

  String _guessSetting(String beat) {
    final lower = beat.toLowerCase();
    if (lower.contains('market')) return 'A crowded marketplace, midday.';
    if (lower.contains('forest') || lower.contains('wood')) {
      return 'A dense forest clearing.';
    }
    if (lower.contains('night')) return 'Outdoors at night.';
    if (lower.contains('house') || lower.contains('home')) {
      return 'Interior of a modest home.';
    }
    if (lower.contains('mountain')) return 'A mountainous, open landscape.';
    if (lower.contains('sea') || lower.contains('ocean') || lower.contains('shore')) {
      return 'A coastal shoreline.';
    }
    return 'Setting inferred from story context — refine as needed.';
  }

  String _guessSoundDesign(String beat) {
    final lower = beat.toLowerCase();
    final layers = <String>['Subtle ambient bed'];
    if (lower.contains('wind')) layers.add('wind gusts');
    if (lower.contains('crowd') || lower.contains('market')) {
      layers.add('distant crowd murmur');
    }
    if (lower.contains('rain')) layers.add('light rain foley');
    if (lower.contains('fire')) layers.add('crackling fire');
    layers.add('light orchestral undertone');
    return layers.join(', ');
  }

  StoryCharacter _buildCharacterProfile(String name, String cleaned) {
    final genderGuess =
        RegExp(r'\bshe\b|\bher\b', caseSensitive: false).hasMatch(cleaned)
            ? 'Female'
            : 'Male';
    return StoryCharacter(
      name: name,
      age: 'Adult (refine from story context)',
      gender: genderGuess,
      ethnicity: 'Inferred from story setting — refine as needed',
      height: 'Average',
      bodyBuild: 'Average build',
      skinTone: 'Refine from story context',
      faceShape: 'Oval',
      eyes: 'Dark brown',
      hairStyle: 'Refine from story context',
      hairColor: 'Dark brown',
      facialHair: 'None specified',
      clothing: 'Refine from story context',
      accessories: 'None specified',
      voiceDescription: 'Warm, grounded tone',
      walkingStyle: 'Purposeful, steady stride',
      personality: 'Inferred from actions in the story',
      facialExpressions: 'Varies with scene emotion',
      speakingStyle: 'Measured and clear',
      lockedAppearanceNotes:
          'Keep all appearance fields identical in every scene featuring $name.',
      continuityNotes:
          'Cross-check clothing, hairstyle, and age against this sheet before finalizing any scene prompt.',
    );
  }
}
