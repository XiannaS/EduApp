import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'firebase_options.dart';

import 'providers/theme_provider.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Init Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  // 2. Init Hive (Base de données locale)
  await Hive.initFlutter();
  
  // 3. Ouvrir la boite pour le cache des cours
  await Hive.openBox('courses_cache');

  runApp(
    // On utilise MultiProvider ici pour être prêt à ajouter d'autres choses si besoin
    MultiProvider(
      providers: [
        // SEUL PROVIDER NÉCESSAIRE (Pour l'UI)
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // On récupère le thème ici pour l'appliquer
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'LMS Admin EMSI',
      debugShowCheckedModeBanner: false,
      
      // Gestion du Thème (Clair / Sombre)
      themeMode: themeProvider.themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F7FA), // Gris très clair
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF151B2B), // Bleu nuit foncé
        inputDecorationTheme: InputDecorationTheme(
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: Colors.grey[800],
        ),
      ),

      home: const SplashScreen(),
    );
  }
}