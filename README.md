PromptForge AI — Version 2 (AI Story Director)
Auto-mode-only app: paste a full story, get back a cinematic scene-by-scene prompt blueprint (16 sections each, every scene ≤10s) plus an auto-generated character database for consistency across the whole "movie."
What's included
lib/
main.dart                  — app entry point, providers, theming
models/
scene.dart                — 16-section blueprint + prompt builder
character.dart             — character profile model
story_project.dart         — story + scenes + characters container
services/
ai_service.dart            — abstract interface — the swappable AI layer
mock_ai_service.dart       — offline heuristic implementation (default)
storage_service.dart       — offline draft saving (shared_preferences)
export_service.dart        — TXT / Markdown / JSON / PDF export
screens/
home_screen.dart           — paste-story entry point + recent drafts
output_screen.dart         — Output / Characters tabs, export menu
scene_edit_screen.dart     — manual override of any blueprint field
widgets/
scene_card.dart            — expandable scene card (copy/edit/regen)
character_card.dart        — expandable character profile card
duration_badge.dart        — green/yellow/red pacing warning chip
theme/
app_theme.dart             — Material 3 light/dark theme
Running it
flutter pub get
flutter run
Building release binaries
flutter build apk --release      (Android)
flutter build ios --release      (iOS — requires Xcode + a Mac + signing)
How the AI layer works right now
MockAiService (in lib/services/mock_ai_service.dart) is a local, offline stand-in. It does real work — sentence splitting, transition-word detection, a naive proper-noun character detector, word-count-based duration estimation, and keyword-based lighting/setting/sound guesses — so the whole app (paste story → scenes → characters → export) works end-to-end with zero API calls and zero cost while you build out the UI.
It is not a real language model. It won't understand plot, emotion, or nuance the way an LLM would — it's a heuristic placeholder that fulfills the AiService contract so nothing else in the app has to wait on a real backend.
Wiring in a real model
Every screen depends only on the abstract AiService interface, with two methods: processStory (takes a raw story and title, returns a full StoryProject) and regenerateScene (takes a project and a scene, returns an updated scene).
To go live:
Create lib/services/claude_ai_service.dart implementing AiService.
Inside processStory, call the Anthropic API (or your backend of choice) with a prompt that asks the model to return structured JSON matching StoryProject.toJson() / Scene.toJson() / the character fields in StoryCharacter — then parse the response with StoryProject.fromJson(...).
In lib/main.dart, change the line that creates MockAiService() to instead create your new ClaudeAiService(apiKey: ...).
Nothing in screens/ or widgets/ needs to change — they only ever talk to AiService, never to a concrete backend.
Recommended JSON shape for a real backend
Ask the model to return a JSON object with a "title" string, a "scenes" array (each scene having sceneNumber, sceneSummary, subject, setting, cameraAngle, cameraMovement, motionAction, estimatedDurationSeconds, lighting, colorPalette, style, dialogue array, intonation, soundDesign, atmosphere, continuity, and negativePrompt), and a "characters" array matching the StoryCharacter fields.
Enforce the ≤10s-per-scene rule and character-consistency rules directly in your system prompt, and validate that estimatedDurationSeconds stays under 10 on the response before accepting it.
Notes / things intentionally left for you to finish
Theme toggle button in home_screen.dart is wired to the UI but not yet connected to a persisted ThemeMode — currently the app follows the system setting.
Cloud sync is not implemented — StorageService is local-only (shared_preferences). Swap its internals for e.g. Firebase/Supabase without touching call sites, same pattern as the AI service.
PDF export uses the pdf package with plain-text paragraphs; styling (fonts, cover page, per-scene page breaks) can be extended in export_service.dart.
iOS builds require a Mac with Xcode and an Apple developer signing identity — this can't be produced from source code alone.
