import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import '../models/story_project.dart';

enum ExportFormat { txt, markdown, json, pdf }

/// Builds and shares export files for a finished [StoryProject].
class ExportService {
  Future<void> export(StoryProject project, ExportFormat format) async {
    switch (format) {
      case ExportFormat.txt:
        await _exportText(project, isMarkdown: false);
        break;
      case ExportFormat.markdown:
        await _exportText(project, isMarkdown: true);
        break;
      case ExportFormat.json:
        await _exportJson(project);
        break;
      case ExportFormat.pdf:
        await _exportPdf(project);
        break;
    }
  }

  String buildPlainText(StoryProject project, {bool isMarkdown = false}) {
    final b = StringBuffer();
    if (isMarkdown) {
      b.writeln('# ${project.title}');
    } else {
      b.writeln(project.title);
      b.writeln('=' * project.title.length);
    }
    b.writeln();
    b.writeln(
        'Scenes: ${project.sceneCount}  |  Total Duration: ${project.totalDurationSeconds.toStringAsFixed(1)}s  |  Est. Generation Time: ${project.estimatedGenerationTimeRange}');
    b.writeln();

    for (final scene in project.scenes) {
      if (isMarkdown) {
        b.writeln('## Scene ${scene.sceneNumber}');
        b.writeln('*Estimated duration: ${scene.estimatedDurationSeconds}s*');
        b.writeln();
        b.writeln('```');
        b.writeln(scene.buildPrompt());
        b.writeln('```');
      } else {
        b.writeln('--- SCENE ${scene.sceneNumber} '
            '(${scene.estimatedDurationSeconds}s) ---');
        b.writeln(scene.buildPrompt());
      }
      b.writeln();
    }

    if (project.characters.isNotEmpty) {
      b.writeln(isMarkdown ? '## Character Sheets' : '--- CHARACTER SHEETS ---');
      b.writeln();
      for (final c in project.characters) {
        b.writeln(c.buildProfileText());
        b.writeln();
      }
    }
    return b.toString();
  }

  Future<void> _exportText(StoryProject project, {required bool isMarkdown}) async {
    final content = buildPlainText(project, isMarkdown: isMarkdown);
    final ext = isMarkdown ? 'md' : 'txt';
    final file = await _writeToFile(project, content, ext);
    await Share.shareXFiles([XFile(file.path)], text: project.title);
  }

  Future<void> _exportJson(StoryProject project) async {
    final content = const JsonEncoder.withIndent('  ').convert(project.toJson());
    final file = await _writeToFile(project, content, 'json');
    await Share.shareXFiles([XFile(file.path)], text: project.title);
  }

  Future<void> _exportPdf(StoryProject project) async {
    final doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Header(level: 0, text: project.title),
          pw.Paragraph(
            text:
                'Scenes: ${project.sceneCount}  |  Total Duration: ${project.totalDurationSeconds.toStringAsFixed(1)}s',
          ),
          pw.SizedBox(height: 12),
          ...project.scenes.expand((scene) => [
                pw.Header(level: 1, text: 'Scene ${scene.sceneNumber}'),
                pw.Paragraph(
                    text: 'Estimated duration: ${scene.estimatedDurationSeconds}s'),
                pw.Paragraph(text: scene.buildPrompt()),
                pw.SizedBox(height: 8),
              ]),
          if (project.characters.isNotEmpty) ...[
            pw.Header(level: 0, text: 'Character Sheets'),
            ...project.characters.expand((c) => [
                  pw.Header(level: 1, text: c.name),
                  pw.Paragraph(text: c.buildProfileText()),
                  pw.SizedBox(height: 8),
                ]),
          ],
        ],
      ),
    );

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/${_safeFileName(project.title)}.pdf');
    await file.writeAsBytes(await doc.save());
    await Share.shareXFiles([XFile(file.path)], text: project.title);
  }

  Future<File> _writeToFile(
      StoryProject project, String content, String extension) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/${_safeFileName(project.title)}.$extension');
    return file.writeAsString(content);
  }

  String _safeFileName(String title) {
    final safe = title.replaceAll(RegExp(r'[^A-Za-z0-9_\- ]'), '').trim();
    return safe.isEmpty ? 'promptforge_story' : safe.replaceAll(' ', '_');
  }
}
