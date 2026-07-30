import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/scene.dart';
import 'duration_badge.dart';

class SceneCard extends StatefulWidget {
  final Scene scene;
  final VoidCallback onEdit;
  final Future<void> Function() onRegenerate;

  const SceneCard({
    super.key,
    required this.scene,
    required this.onEdit,
    required this.onRegenerate,
  });

  @override
  State<SceneCard> createState() => _SceneCardState();
}

class _SceneCardState extends State<SceneCard> {
  bool _expanded = false;
  bool _regenerating = false;

  Future<void> _handleRegenerate() async {
    setState(() => _regenerating = true);
    await widget.onRegenerate();
    if (mounted) setState(() => _regenerating = false);
  }

  void _handleCopy() {
    Clipboard.setData(ClipboardData(text: widget.scene.buildPrompt()));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Scene ${widget.scene.sceneNumber} copied')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scene = widget.scene;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    child: Text('${scene.sceneNumber}',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      scene.sceneSummary.isNotEmpty
                          ? scene.sceneSummary
                          : 'Scene ${scene.sceneNumber}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(width: 8),
                  DurationBadge(seconds: scene.estimatedDurationSeconds),
                  const SizedBox(width: 4),
                  Icon(_expanded ? Icons.expand_less : Icons.expand_more),
                ],
              ),
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox(width: double.infinity),
              secondChild: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: SelectableText(
                        scene.buildPrompt(),
                        style: const TextStyle(
                            fontFamily: 'monospace', fontSize: 12.5, height: 1.5),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        OutlinedButton.icon(
                          onPressed: _handleCopy,
                          icon: const Icon(Icons.copy, size: 16),
                          label: const Text('Copy'),
                        ),
                        OutlinedButton.icon(
                          onPressed: widget.onEdit,
                          icon: const Icon(Icons.edit, size: 16),
                          label: const Text('Edit'),
                        ),
                        OutlinedButton.icon(
                          onPressed: _regenerating ? null : _handleRegenerate,
                          icon: _regenerating
                              ? const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.refresh, size: 16),
                          label: Text(
                              _regenerating ? 'Regenerating...' : 'Regenerate'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              crossFadeState: _expanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 200),
            ),
          ],
        ),
      ),
    );
  }
}
