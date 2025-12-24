import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:test/screens/auth/login_screen.dart';
import '../../providers/theme_provider.dart';
import '../../services/notification_service.dart'; // Import du service
 

const Color kAccentBlue = Color(0xFF2D62ED);

class AdminHeader extends StatelessWidget {
  const AdminHeader({super.key});

  // Fonction pour afficher les notifs
  void _showNotifications(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.notifications_active, color: kAccentBlue),
            SizedBox(width: 10),
            Text("Alertes Pédagogiques"),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 300, // Hauteur max de la boite
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: NotificationService().fetchNotifications(), // Appel API
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) return const Text("Erreur de chargement");

              final notifs = snapshot.data!;
              return ListView.separated(
                itemCount: notifs.length,
                separatorBuilder: (ctx, i) => const Divider(),
                itemBuilder: (ctx, i) {
                  final n = notifs[i];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: n['isUrgent'] ? Colors.red.withOpacity(0.1) : Colors.blue.withOpacity(0.1),
                      child: Icon(
                        n['isUrgent'] ? Icons.warning : Icons.info, 
                        color: n['isUrgent'] ? Colors.red : Colors.blue, 
                        size: 20
                      ),
                    ),
                    title: Text(n['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: Text(n['body'], style: const TextStyle(fontSize: 12)),
                    trailing: Text(n['time'], style: const TextStyle(fontSize: 10, color: Colors.grey)),
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Fermer"))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.1))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Bouton Menu (Ouvre le Drawer)
          IconButton(
            icon: Icon(Icons.menu, color: theme.textColor), 
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),

          Row(
            children: [
              IconButton(
                icon: Icon(theme.isDarkMode ? Icons.light_mode : Icons.dark_mode, color: theme.textColor),
                onPressed: () => theme.toggleTheme(),
              ),
              const SizedBox(width: 10),
              
              // --- BOUTON NOTIFICATION ACTIF ---
              IconButton(
                icon: Stack(
                  children: [
                    const Icon(Icons.notifications_none, color: Colors.grey, size: 28),
                    Positioned(
                      right: 0, top: 0,
                      child: Container(width: 10, height: 10, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle)),
                    )
                  ],
                ),
                onPressed: () => _showNotifications(context), // Clic ici !
              ),
              // ---------------------------------

              const SizedBox(width: 15),
              if (!isMobile) ...[
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text("Admin Principal", style: TextStyle(color: theme.textColor, fontWeight: FontWeight.bold, fontSize: 14)),
                    Text("admin@emsi.ma", style: TextStyle(color: theme.subTextColor, fontSize: 11)),
                  ],
                ),
                const SizedBox(width: 10),
              ],
              CircleAvatar(backgroundColor: kAccentBlue.withOpacity(0.2), radius: 18, child: const Text("A", style: TextStyle(color: kAccentBlue, fontWeight: FontWeight.bold))),
              const SizedBox(width: 10),
              IconButton(
                icon: Icon(Icons.logout, color: theme.subTextColor),
                onPressed: () async {
                   await FirebaseAuth.instance.signOut();
                   if(context.mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                },
              )
            ],
          )
        ],
      ),
    );
  }
}