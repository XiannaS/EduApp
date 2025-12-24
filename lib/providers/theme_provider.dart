import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = true; // On commence en mode sombre par défaut 

  bool get isDarkMode => _isDarkMode;
 
  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;
 
  // Couleurs dynamiques selon le mode  
  Color get bgColor => _isDarkMode ? const Color(0xFF15172B) : const Color(0xFFF3F4F6);
  Color get cardColor => _isDarkMode ? const Color(0xFF202336) : const Color(0xFFFFFFFF);
  Color get textColor => _isDarkMode ? Colors.white : const Color(0xFF1F2937);
  Color get subTextColor => _isDarkMode ? Colors.grey : const Color(0xFF6B7280);
  Color get menuColor => _isDarkMode ? const Color(0xFF202336) : const Color(0xFFFFFFFF);

  // Fonction de bascule 
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners(); 
  }
}