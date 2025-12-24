import 'package:flutter/material.dart';
import '../../models/user_model.dart';

class StudentDetailsScreen extends StatelessWidget {
  final UserModel student;

  const StudentDetailsScreen({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(student.name ?? "Détails")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête avec Avatar
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.blue.withOpacity(0.1),
                    child: Text(
                      student.name?[0].toUpperCase() ?? "E",
                      style: const TextStyle(fontSize: 30, color: Colors.blue, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(student.name ?? "Inconnu", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  Text(student.email, style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 10),
                  Chip(
                    label: Text(student.profile ?? "N/A"),
                    backgroundColor: Colors.purple.withOpacity(0.1),
                    labelStyle: const TextStyle(color: Colors.purple),
                  )
                ],
              ),
            ),
            const Divider(height: 40),
            
            // Infos Détaillées
            _buildDetailRow(Icons.qr_code, "Matricule", student.matricule ?? "Non défini"),
            _buildDetailRow(Icons.cake, "Âge / Naissance", student.dateOfBirth?.toString().split(' ')[0] ?? "Inconnu"),
            _buildDetailRow(Icons.phone, "Téléphone", student.phone ?? "Non renseigné"),
            _buildDetailRow(Icons.verified_user, "Statut", student.status ?? "Actif"),
            
            const SizedBox(height: 30),
            // Bouton Simulation Email
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                   ScaffoldMessenger.of(context).showSnackBar(
                     SnackBar(content: Text("Email de réinitialisation envoyé à ${student.email}"))
                   );
                },
                icon: const Icon(Icons.mail_outline),
                label: const Text("Renvoyer les accès par Email"),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey, size: 20),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            ],
          )
        ],
      ),
    );
  }
}