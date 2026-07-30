import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/story_project.dart';

/// Handles offline draft saving/loading. Swap the backing store for a
/// cloud-synced implementation later without touching call sites.
class StorageService {
  static const _projectsKey = 'promptforge_projects_v2';

  Future<List<StoryProject>> loadAllProjects() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_projectsKey);
    if (raw == null || raw.isEmpty) return [];
    final list = jsonDecode(raw) as List;
    return list
        .map((e) => StoryProject.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveAllProjects(List<StoryProject> projects) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(projects.map((p) => p.toJson()).toList());
    await prefs.setString(_projectsKey, raw);
  }

  Future<void> upsertProject(StoryProject project) async {
    final projects = await loadAllProjects();
    final index = projects.indexWhere((p) => p.id == project.id);
    project.updatedAt = DateTime.now();
    if (index >= 0) {
      projects[index] = project;
    } else {
      projects.add(project);
    }
    await saveAllProjects(projects);
  }

  Future<void> deleteProject(String projectId) async {
    final projects = await loadAllProjects();
    projects.removeWhere((p) => p.id == projectId);
    await saveAllProjects(projects);
  }
}
