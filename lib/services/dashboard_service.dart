import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Récupère les stats globales
  Future<Map<String, dynamic>> fetchDashboardStats() async {
    try {
      // 1. Compter les étudiants et analyser les profils
      final studentsSnapshot = await _db.collection('users').where('role', isEqualTo: 'student').get();
      int totalStudents = studentsSnapshot.docs.length;
      
      int countADO = 0;
      int countENF = 0;
      int countADU = 0;

      for (var doc in studentsSnapshot.docs) {
        final profile = doc.data()['profile'] as String? ?? '';
        if (profile.contains('ADO')) {
          countADO++;
        } else if (profile.contains('ENF')) countENF++;
        else if (profile.contains('ADU')) countADU++;
      }

      // 2. Compter les cours et calculer la valeur du catalogue
      final coursesSnapshot = await _db.collection('courses').get();
      int totalCourses = coursesSnapshot.docs.length;
      double totalCourseValue = 0;
      
      for (var doc in coursesSnapshot.docs) {
        // On additionne le prix de tous les cours pour donner une "Valeur Catalogue"
        totalCourseValue += (doc.data()['price'] ?? 0).toDouble();
      }

      return {
        "students": totalStudents.toString(),
        "courses": totalCourses.toString(),
        "revenue": "${totalCourseValue.toStringAsFixed(0)} MAD", // Valeur totale du catalogue
        "ado": countADO,
        "enf": countENF,
        "adu": countADU,
      };
    } catch (e) {
      return {
        "students": "0", "courses": "0", "revenue": "0 MAD",
        "ado": 0, "enf": 0, "adu": 0
      };
    }
  }
}