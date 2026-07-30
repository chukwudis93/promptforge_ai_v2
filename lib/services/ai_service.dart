import '../models/story_project.dart';
import '../models/scene.dart';

/// Contract every AI backend must implement. Swap [MockAiService] for a
/// real implementation (e.g. one that calls the Anthropic API) without
/// touching any UI code — every screen only ever talks to [AiService].
abstract class AiService {
  /// Takes a raw, possibly messy story and returns a fully processed
  /// [StoryProject]: grammar-corrected, split into <=10s cinematic scenes
  /// (each following the 16-section blueprint), with a full character
  /// database extracted and consistency-locked across scenes.
  Future<StoryProject> processStory({
    required String rawStory,
    String? title,
  });

  /// Regenerates a single scene's prompt (e.g. after the user hits
  /// "Regenerate"), keeping continuity with the rest of the project.
  Future<Scene> regenerateScene({
    required StoryProject project,
    required Scene scene,
  });
}
