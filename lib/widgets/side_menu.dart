import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';

const Color kAccentBlue = Color(0xFF2D62ED);
// Menu latéral pour l'admin
class SideMenu extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onIndexChanged;
// Constructor
  const SideMenu({
    super.key,
    required this.selectedIndex,
    required this.onIndexChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
// Structure du menu
    return Container(
      width: 260,
      color: theme.menuColor,
      child: Column(
        children: [
          Container(
            height: 70,
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.school, color: kAccentBlue, size: 30),
                const SizedBox(width: 10),
                Text("EduERP", style: TextStyle(color: theme.textColor, fontSize: 22, fontWeight: FontWeight.bold)), // Titre du menu
              ],
            ),
          ),
          Divider(color: Colors.grey.withOpacity(0.1)),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 20),
              children: [
                _MenuSectionTitle(title: "GÉNÉRAL"),
                DrawerListTile(
                  title: "Tableau de bord", // Dashboard
                  icon: Icons.dashboard,
                  isSelected: selectedIndex == 0,
                  onTap: () => onIndexChanged(0),
                ),
                const SizedBox(height: 20),
                _MenuSectionTitle(title: "ACADÉMIQUE"), // Section académique
                DrawerListTile(
                  title: "Étudiants", // Students
                  icon: Icons.people_outline,
                  isSelected: selectedIndex == 1,
                  onTap: () => onIndexChanged(1),
                ),
                DrawerListTile(
                  title: "Catalogue Cours", // Course Catalog
                  icon: Icons.library_books,
                  isSelected: selectedIndex == 2,
                  onTap: () => onIndexChanged(2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
// Titre de section dans le menu
class _MenuSectionTitle extends StatelessWidget {
  final String title;
  const _MenuSectionTitle({required this.title});
  @override 
  Widget build(BuildContext context) { 
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Text(title, style: TextStyle(color: Colors.grey.withOpacity(0.6), fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }
}
// Élément de la liste du menu
class DrawerListTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const DrawerListTile({super.key, required this.title, required this.icon, required this.onTap, this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? kAccentBlue.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(icon, color: isSelected ? kAccentBlue : theme.subTextColor, size: 22),
        title: Text(title, style: TextStyle(color: isSelected ? kAccentBlue : theme.subTextColor, fontSize: 14, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal)),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}