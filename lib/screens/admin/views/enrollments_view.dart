import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../models/enrollment_model.dart';
import '../../../../services/enrollment_service.dart';
import '../../../../providers/theme_provider.dart';
import '../add_enrollment_screen.dart';

class EnrollmentsView extends StatelessWidget {
  const EnrollmentsView({super.key});
// Construction de la vue des inscriptions
  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    final EnrollmentService enrollmentService = EnrollmentService();
// Scaffold principal
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF2D62ED),
        icon: const Icon(Icons.add_link, color: Colors.white),
        label: const Text("Inscrire", style: TextStyle(color: Colors.white)),
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddEnrollmentScreen())),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Historique des Inscriptions", style: TextStyle(color: theme.textColor, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            // LISTE DES INSCRIPTIONS
            Expanded(
              child: StreamBuilder<List<EnrollmentModel>>(
                stream: enrollmentService.getAllEnrollments(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text("Aucune inscription pour le moment.", style: TextStyle(color: theme.subTextColor)));
                  }

                  final enrollments = snapshot.data!;
                  // Liste des inscriptions
                  return ListView.builder(
                    itemCount: enrollments.length,
                    itemBuilder: (context, index) {
                      final e = enrollments[index];
                      return Card(
                        color: theme.cardColor,
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.green.withOpacity(0.1),
                            child: const Icon(Icons.check, color: Colors.green, size: 20),
                          ),
                          title: Text("${e.studentName} ➔ ${e.courseTitle}", style: TextStyle(color: theme.textColor, fontWeight: FontWeight.bold, fontSize: 14)),
                          subtitle: Text("Inscrit le ${DateFormat('dd/MM/yyyy').format(e.enrollmentDate)}", style: TextStyle(color: theme.subTextColor, fontSize: 12)),
                          trailing: Text("${e.priceAtEnrollment} MAD", style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}