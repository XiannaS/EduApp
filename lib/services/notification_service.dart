import 'dart:convert';
import 'package:http/http.dart' as http;

class NotificationService {
  // On utilise une API publique fiable pour simuler le backend
  final String _baseUrl = "https://jsonplaceholder.typicode.com/posts?_limit=6";

  Future<List<Map<String, dynamic>>> fetchNotifications() async {
    try {
      // 1. Appel API REST (GET)  
      final response = await http.get(Uri.parse(_baseUrl));

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);

        // 2. Transformation des données (Mapping) pour faire "Admin Pédagogique"
        // On remplace le latin de l'API par des vrais titres métiers
        List<String> realTitles = [
          "Nouvelle inscription : Yassine B.",
          "Absence Professeur : M. Alami",
          "Retard de paiement : Classe 5IIR",
          "Examen validé : Java/Spring",
          "Maintenance : Salle B22",
          "Message du Directeur"
        ];

        List<String> realSubtitles = [
          "Dossier complet en attente de validation.",
          "Ne pourra pas assurer le cours de 14h.",
          "3 étudiants n'ont pas réglé les frais.",
          "Les notes sont disponibles sur l'intranet.",
          "Projecteur en panne, intervention prévue.",
          "Réunion pédagogique demain 10h."
        ];

        return List.generate(data.length, (index) {
          return {
            "title": realTitles[index % realTitles.length],
            "body": realSubtitles[index % realSubtitles.length],
            "time": "${index + 2} min ago", //   timestamp
            "isUrgent": index % 2 == 0, // Une sur deux est "urgente"
          };
        });
      } else {
        throw Exception("Erreur serveur");
      }
    } catch (e) {
      // En cas d'erreur réseau, on retourne une liste vide ou une erreur
      return [
        {"title": "Erreur Réseau", "body": "Impossible de charger les alertes", "time": "Maintenant", "isUrgent": true}
      ];
    }
  }
}