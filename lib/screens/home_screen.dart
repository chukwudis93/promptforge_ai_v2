import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/ai_service.dart';
import '../services/storage_service.dart';
import '../models/story_project.dart';
import 'output_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _storyController = TextEditingController();
  final _titleController = TextEditingController();
  bool _processing = false;
  List<StoryProject> _recentDrafts = [];

  @override
  void initState() {
    super.initState();
    _loadDrafts();
  }

  Future<void> _loadDrafts() async {
    final storage = context.read<StorageService>();
    final drafts = await storage.loadAllProjects();
    drafts.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    if (mounted) setState(() => _recentDrafts = drafts);
  }

  Future<void> _generate() async {
    if (_storyController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Paste a story first.')),
      );
      return;
    }

    setState(() => _processing = true);
    try {
      final ai = context.read<AiService>();
      final project = await ai.processStory(
        rawStory: _storyController.text,
        title: _titleController.text,
      );
      await context.read<StorageService>().upsertProject(project);
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => OutputScreen(project: project)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Something went wrong: $e')),
      );
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  void _openDraft(StoryProject project) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => OutputScreen(project: project)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PromptForge AI'),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6_outlined),
            tooltip: 'Toggle theme',
            onPressed: () {
              // Hook up to a ThemeProvider if you add one; left as a
              // placeholder action matching the spec's Dark/Light mode.
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Transform Any Story Into\nPerfect AI Video Prompts.',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'AI Story Director — paste your story below. It will be '
                    'grammar-corrected, split into cinematic scenes under 10 '
                    'seconds each, and given a full character database.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      hintText: 'Story title (optional)',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _storyController,
                    minLines: 10,
                    maxLines: 20,
                    decoration: const InputDecoration(
                      hintText: 'Paste your story here — structured, '
                          'partially structured, or completely raw.',
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _processing ? null : _generate,
                      icon: _processing
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.auto_awesome),
                      label: Text(_processing
                          ? 'Directing your story...'
                          : 'Generate Prompt'),
                    ),
                  ),
                  if (_recentDrafts.isNotEmpty) ...[
                    const SizedBox(height: 32),
                    Text('Recent Drafts',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    ..._recentDrafts.map((p) => Card(
                          child: ListTile(
                            title: Text(p.title),
                            subtitle: Text(
                                '${p.sceneCount} scenes · ${p.totalDurationSeconds.toStringAsFixed(1)}s'),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => _openDraft(p),
                          ),
                        )),
                  ],
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _storyController.dispose();
    _titleController.dispose();
    super.dispose();
  }
}
