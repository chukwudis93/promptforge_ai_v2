import 'package:flutter/material.dart';
import '../models/scene.dart';

class SceneEditScreen extends StatefulWidget {
  final Scene scene;
  const SceneEditScreen({super.key, required this.scene});

  @override
  State<SceneEditScreen> createState() => _SceneEditScreenState();
}

class _SceneEditScreenState extends State<SceneEditScreen> {
  late TextEditingController _summary;
  late TextEditingController _subject;
  late TextEditingController _setting;
  late TextEditingController _motion;
  late TextEditingController _soundDesign;
  late TextEditingController _continuity;
  late TextEditingController _negativePrompt;
  late TextEditingController _lightingNote;

  static const cameraAngles = [
    'Eye Level', 'Low Angle', 'High Angle', "Bird's Eye", 'Dutch Angle',
    'Over-the-Shoulder', 'Close Up', 'Medium Shot', 'Wide Shot',
    'Extreme Close Up',
  ];
  static const cameraMovements = [
    'Static', 'Pan Left', 'Pan Right', 'Tilt Up', 'Tilt Down', 'Push In',
    'Pull Out', 'Dolly', 'Crane', 'Tracking', 'Handheld', 'Steadicam',
    'Orbit', 'Drone', 'Slow Zoom', 'Fast Zoom', 'Slider',
  ];
  static const lightingOptions = [
    'Golden Hour', 'Sunset', 'Soft Morning', 'Moonlight', 'Torch Light',
    'Firelight', 'Studio', 'Cloudy', 'Backlit', 'High Contrast', 'Low Key',
  ];
  static const colorPalettes = [
    'Earth Tone', 'Warm', 'Cool', 'Cinematic', 'Muted', 'Vibrant',
    'Dark Fantasy', 'Biblical', 'Natural',
  ];
  static const styles = [
    'Hyperrealistic', 'Hollywood', 'Biblical Epic', 'Ultra Cinematic',
    'Documentary', 'Photorealistic', 'Anime', 'Pixar', 'Oil Painting',
    'Vintage Film',
  ];
  static const intonations = [
    'Bold', 'Calm', 'Urgent', 'Whisper', 'Prophetic', 'Joyful', 'Fearful',
    'Sad', 'Authoritative',
  ];
  static const atmospheres = [
    'Peaceful', 'Dark', 'Hopeful', 'Tense', 'Joyful', 'Fearful', 'Lonely',
    'Epic', 'Sacred',
  ];

  @override
  void initState() {
    super.initState();
    final s = widget.scene;
    _summary = TextEditingController(text: s.sceneSummary);
    _subject = TextEditingController(text: s.subject);
    _setting = TextEditingController(text: s.setting);
    _motion = TextEditingController(text: s.motionAction);
    _soundDesign = TextEditingController(text: s.soundDesign);
    _continuity = TextEditingController(text: s.continuity);
    _negativePrompt = TextEditingController(text: s.negativePrompt);
    _lightingNote = TextEditingController(text: s.lightingNote);
  }

  String _ensureOption(String value, List<String> options) =>
      options.contains(value) ? value : options.first;

  void _save() {
    final s = widget.scene;
    s.sceneSummary = _summary.text;
    s.subject = _subject.text;
    s.setting = _setting.text;
    s.motionAction = _motion.text;
    s.soundDesign = _soundDesign.text;
    s.continuity = _continuity.text;
    s.negativePrompt = _negativePrompt.text;
    s.lightingNote = _lightingNote.text;
    Navigator.of(context).pop(s);
  }

  Widget _dropdown(String label, String value, List<String> options,
      ValueChanged<String> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: _ensureOption(value, options),
        decoration: InputDecoration(labelText: label),
        items: options
            .map((o) => DropdownMenuItem(value: o, child: Text(o)))
            .toList(),
        onChanged: (v) => onChanged(v ?? options.first),
      ),
    );
  }

  Widget _textField(String label, TextEditingController controller,
      {int minLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        minLines: minLines,
        maxLines: minLines + 6,
        decoration: InputDecoration(labelText: label, alignLabelWithHint: true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.scene;
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Scene ${s.sceneNumber}'),
        actions: [
          TextButton(onPressed: _save, child: const Text('Save')),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _textField('1. Scene Summary', _summary),
            _textField('2. Subject', _subject, minLines: 3),
            _textField('3. Setting', _setting, minLines: 3),
            _dropdown('4. Camera Angle', s.cameraAngle, cameraAngles,
                (v) => setState(() => s.cameraAngle = v)),
            _dropdown('5. Camera Movement', s.cameraMovement, cameraMovements,
                (v) => setState(() => s.cameraMovement = v)),
            _textField('6. Motion / Action', _motion, minLines: 4),
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                '7. Duration / Pacing: ${s.estimatedDurationSeconds.toStringAsFixed(1)}s '
                '(auto-estimated)',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            _dropdown('8. Lighting', s.lighting, lightingOptions,
                (v) => setState(() => s.lighting = v)),
            _textField('Lighting note (optional)', _lightingNote),
            _dropdown('9. Color Palette', s.colorPalette, colorPalettes,
                (v) => setState(() => s.colorPalette = v)),
            _dropdown('10. Style', s.style, styles,
                (v) => setState(() => s.style = v)),
            _dropdown('12. Intonation', s.intonation, intonations,
                (v) => setState(() => s.intonation = v)),
            _textField('13. Sound Design', _soundDesign, minLines: 2),
            _dropdown('14. Atmosphere', s.atmosphere, atmospheres,
                (v) => setState(() => s.atmosphere = v)),
            _textField('15. Continuity', _continuity, minLines: 2),
            _textField('16. Negative Prompt', _negativePrompt, minLines: 2),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                child: const Text('Save Changes'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _summary.dispose();
    _subject.dispose();
    _setting.dispose();
    _motion.dispose();
    _soundDesign.dispose();
    _continuity.dispose();
    _negativePrompt.dispose();
    _lightingNote.dispose();
    super.dispose();
  }
}
