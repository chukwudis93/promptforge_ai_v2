import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/character.dart';

class CharacterCard extends StatefulWidget {
  final StoryCharacter character;
  const CharacterCard({super.key, required this.character});

  @override
  State<CharacterCard> createState() => _CharacterCardState();
}

class _CharacterCardState extends State<CharacterCard> {
  bool _expanded = false;

  void _copy(BuildContext context) {
    Clipboard.setData(
        ClipboardData(text: widget.character.buildProfileText()));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${widget.character.name} profile copied')),
    );
  }

  Widget _field(String label, String value) {
    if (value.trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: RichText(
        text: TextSpan(
          style: DefaultTextStyle.of(context).style.copyWith(fontSize: 13),
          children: [
            TextSpan(
                text: '$label: ',
                style: const TextStyle(fontWeight: FontWeight.w700)),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.character;
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
                    radius: 18,
                    child: Text(
                      c.name.isNotEmpty ? c.name[0].toUpperCase() : '?',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      c.name.isNotEmpty ? c.name : 'Unnamed Character',
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 16),
                    ),
                  ),
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
                    _field('Age', c.age),
                    _field('Gender', c.gender),
                    _field('Ethnicity', c.ethnicity),
                    _field('Height', c.height),
                    _field('Body Build', c.bodyBuild),
                    _field('Skin Tone', c.skinTone),
                    _field('Face Shape', c.faceShape),
                    _field('Eyes', c.eyes),
                    _field('Hair Style', c.hairStyle),
                    _field('Hair Color', c.hairColor),
                    _field('Facial Hair', c.facialHair),
                    _field('Clothing', c.clothing),
                    _field('Accessories', c.accessories),
                    _field('Voice', c.voiceDescription),
                    _field('Walking Style', c.walkingStyle),
                    _field('Personality', c.personality),
                    _field('Facial Expressions', c.facialExpressions),
                    _field('Speaking Style', c.speakingStyle),
                    _field('Locked Appearance', c.lockedAppearanceNotes),
                    _field('Continuity Notes', c.continuityNotes),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: () => _copy(context),
                      icon: const Icon(Icons.copy, size: 16),
                      label: const Text('Copy Character'),
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
