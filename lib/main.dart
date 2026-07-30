import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/ai_service.dart';
import 'services/mock_ai_service.dart';
import 'services/storage_service.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const PromptForgeApp());
}

class PromptForgeApp extends StatelessWidget {
  const PromptForgeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Swap MockAiService() for a real implementation (e.g. one that
        // calls the Anthropic API) when you're ready — nothing else in
        // the app needs to change since every screen depends only on
        // the AiService interface.
        Provider<AiService>(create: (_) => MockAiService()),
        Provider<StorageService>(create: (_) => StorageService()),
      ],
      child: MaterialApp(
        title: 'PromptForge AI',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
        home: const HomeScreen(),
      ),
    );
  }
}
