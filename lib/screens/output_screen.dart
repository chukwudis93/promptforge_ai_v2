import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:provider/provider.dart';
import '../models/story_project.dart';
import '../models/scene.dart';
import '../services/ai_service.dart';
import '../services/storage_service.dart';
import '../services/export_service.dart';
import '../widgets/scene_card.dart';
import '../widgets/character_card.dart';
import 'scene_edit_screen.dart';

enum _OutputTab { output, characters }

class OutputScreen extends StatefulWidget {
  final StoryProject project;
  const OutputScreen({super.key, required this.project});

  @override
  State<OutputScreen> createState() => _OutputScreenState();
}

class _OutputScreenState extends State<OutputScreen> {
  _OutputTab _tab = _OutputTab.output;
  bool _exporting = false;

  Future<void> _persist() async {
    await context.read<StorageService>().upsertProject(widget.project);
  }

  Future<void> _regenerateScene(Scene scene) async {
    final ai = context.read<AiService>();
    final updated =
        await ai.regenerateScene(project: widget.project, scene: scene);
    final index =
        widget.project.scenes.indexWhere((s) => s.id == scene.id);
    if (index >= 0) {
      setState(() {
        widget.project.scenes[index] = updated..sceneNumber = scene.sceneNumber;
      });
      await _persist();
    }
  }

  void _editScene(Scene scene) async {
    final result = await Navigator.of(context).push<Scene>(
      MaterialPageRoute(builder: (_) => SceneEditScreen(scene: scene)),
    );
    if (result != null) {
      setState(() {}); // scene is mutated in place by the edit screen
      await _persist();
    }
  }

  void _copyEntireMovie() {
    final export = ExportService();
    final text = export.buildPlainText(widget.project);
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Entire movie copied to clipboard')),
    );
  }

  Future<void> _handleExport(ExportFormat format) async {
    setState(() => _exporting = true);
    try {
      await ExportService().export(widget.project, format);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final project = widget.project;
    return Scaffold(
      appBar: AppBar(
        title: Text(project.title, overflow: TextOverflow.ellipsis),
        actions: [
          _exporting
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : PopupMenuButton<Object>(
                  icon: const Icon(Icons.ios_share),
                  onSelected: (value) {
                    if (value == 'copy') {
                      _copyEntireMovie();
                    } else if (value is ExportFormat) {
                      _handleExport(value);
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: 'copy', child: Text('Copy Entire Movie')),
                    PopupMenuDivider(),
                    PopupMenuItem(
                        value: ExportFormat.txt, child: Text('Export TXT')),
                    PopupMenuItem(
                        value: ExportFormat.markdown,
                        child: Text('Export Markdown')),
                    PopupMenuItem(
                        value: ExportFormat.json, child: Text('Export JSON')),
                    PopupMenuItem(
                        value: ExportFormat.pdf, child: Text('Export PDF')),
                  ],
                ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Column(
              children: [
                Row(
                  children: [
                    _StatChip(
                        label: 'Scenes', value: '${project.sceneCount}'),
                    const SizedBox(width: 8),
                    _StatChip(
                        label: 'Total',
                        value:
                            '${project.totalDurationSeconds.toStringAsFixed(1)}s'),
                    const SizedBox(width: 8),
                    _StatChip(
                        label: 'Est. Gen Time',
                        value: project.estimatedGenerationTimeRange),
                  ],
                ),
                const SizedBox(height: 12),
                SegmentedButton<_OutputTab>(
                  segments: const [
                    ButtonSegment(
                        value: _OutputTab.output,
                        label: Text('Output'),
                        icon: Icon(Icons.movie_filter_outlined)),
                    ButtonSegment(
                        value: _OutputTab.characters,
                        label: Text('Characters'),
                        icon: Icon(Icons.people_outline)),
                  ],
                  selected: {_tab},
                  onSelectionChanged: (s) => setState(() => _tab = s.first),
                ),
              ],
            ),
          ),
          Expanded(
            child: _tab == _OutputTab.output
                ? _buildOutputTab(project)
                : _buildCharactersTab(project),
          ),
        ],
      ),
    );
  }

  Widget _buildOutputTab(StoryProject project) {
    if (project.scenes.isEmpty) {
      return const Center(child: Text('No scenes generated yet.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: project.scenes.length,
      itemBuilder: (context, index) {
        final scene = project.scenes[index];
        return SceneCard(
          scene: scene,
          onEdit: () => _editScene(scene),
          onRegenerate: () => _regenerateScene(scene),
        );
      },
    );
  }

  Widget _buildCharactersTab(StoryProject project) {
    if (project.characters.isEmpty) {
      return const Center(
          child: Text('No recurring characters were detected.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: project.characters.length,
      itemBuilder: (context, index) =>
          CharacterCard(character: project.characters[index]),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  const _StatChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(value,
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
            Text(label,
                style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}
