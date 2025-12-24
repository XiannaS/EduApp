import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/enrollment_model.dart';

class EnrollmentService {
  final CollectionReference _enrollments = 
      FirebaseFirestore.instance.collection('enrollments');

  // 1. Inscrire un étudiant (avec vérification de doublon)
  Future<void> enrollStudent(EnrollmentModel enrollment) async {
    // Vérifier si l'inscription existe déjà
    final query = await _enrollments
        .where('studentId', isEqualTo: enrollment.studentId)
        .where('courseId', isEqualTo: enrollment.courseId)
        .get();

    if (query.docs.isNotEmpty) {
      throw Exception("Cet étudiant est déjà inscrit à ce cours !");
    }

    // Sinon, on ajoute
    await _enrollments.add(enrollment.toMap());
  }

  // 2. Récupérer toutes les inscriptions (Pour l'historique global)
  Stream<List<EnrollmentModel>> getAllEnrollments() {
    return _enrollments.orderBy('enrollmentDate', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return EnrollmentModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // 3. Récupérer les étudiants d'un cours spécifique (Pour CourseDetails)
  Stream<List<EnrollmentModel>> getStudentsForCourse(String courseId) {
    return _enrollments.where('courseId', isEqualTo: courseId).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return EnrollmentModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }
}