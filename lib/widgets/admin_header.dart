import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:test/screens/auth/login_screen.dart';
import '../../providers/theme_provider.dart';
import '../../services/notification_service.dart';

const Color kAccentBlue = Color(0xFF2D62ED);

class AdminHeader extends StatelessWidget {
  const AdminHeader({super.key});

  // Fonction pour afficher les notifications
  void _showNotifications(BuildContext context, ThemeProvider theme) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
         
        title: Row(
          children: [
            const Icon(Icons.notifications_active, color: kAccentBlue),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                "Alertes Pédagogiques",
                style: TextStyle(fontSize: 18, color: theme.textColor),  
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: NotificationService().fetchNotifications(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) return const Text("Erreur de chargement"); // Gestion simple des erreurs des notifs

              final notifs = snapshot.data ?? [];
              return ListView.separated(
                itemCount: notifs.length,
                separatorBuilder: (ctx, i) => const Divider(),
                itemBuilder: (ctx, i) {
                  final n = notifs[i];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: (n['isUrgent'] as bool) ? Colors.red.withOpacity(0.1) : Colors.blue.withOpacity(0.1), 
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        (n['isUrgent'] as bool) ? Icons.warning : Icons.info,
                        color: (n['isUrgent'] as bool) ? Colors.red : Colors.blue,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      n['title'],
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      n['body'],
                      style: const TextStyle(fontSize: 12),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Text(
                      n['time'],
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
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
// -- FIN FONCTION NOTIFS --

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context); // C'est ici que 'theme' est créé
    final isMobile = MediaQuery.of(context).size.width < 600;
// On détermine si on est sur mobile pour ajuster l'affichage
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.1))),
      ),
      // Le contenu de l'en-tête
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.menu, color: theme.textColor), 
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
// Partie droite de l'en-tête
          Row(
            children: [
              IconButton(
                icon: Icon(theme.isDarkMode ? Icons.light_mode : Icons.dark_mode, color: theme.textColor), // Icône dynamique du changement de theme
                onPressed: () => theme.toggleTheme(),
              ),
              const SizedBox(width: 10),
              
              // --- APPEL DE LA FONCTION AVEC LE THEME ---
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
                onPressed: () => _showNotifications(context, theme), // <--- On passe 'theme' ici !
              ),
              // ------------------------------------------

              const SizedBox(width: 15),
              if (!isMobile) ...[
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text("Admin Principal", style: TextStyle(color: theme.textColor, fontWeight: FontWeight.bold, fontSize: 14)), //
                    Text("admin@emsi.ma", style: TextStyle(color: theme.subTextColor, fontSize: 11)),  
                  ],
                ),
                const SizedBox(width: 10),
              ],
              CircleAvatar(backgroundColor: kAccentBlue.withOpacity(0.2), radius: 18, child: const Text("A", style: TextStyle(color: kAccentBlue, fontWeight: FontWeight.bold))),
              const SizedBox(width: 10),
              IconButton( // Bouton de déconnexion
                icon: Icon(Icons.logout, color: theme.subTextColor),
                onPressed: () async {
                   await FirebaseAuth.instance.signOut();
                   if(context.mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen())); // Redirection vers l'écran de login
                },
              )
            ],
          )
        ],
      ),
    );
  }
}