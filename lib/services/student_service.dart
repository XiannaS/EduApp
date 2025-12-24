import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class StudentService {
  final CollectionReference _usersCollection = 
      FirebaseFirestore.instance.collection('users');

  // 1. Ajouter un étudiant (Juste les données dans la base pour l'instant)
  Future<void> addStudent(UserModel student, String password) async {
    // Note: Dans une vraie app, on créerait aussi le compte Auth ici.
    // Pour ce projet, on simule l'ajout en base de données.
    await _usersCollection.add(student.toMap());
  }

  // 2. Récupérer uniquement les étudiants (pas les admins)
  Stream<List<UserModel>> getStudentsStream() {
    return _usersCollection
        .where('role', isEqualTo: 'student') // Filtre important !
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return UserModel.fromMap(
          doc.data() as Map<String, dynamic>, 
          doc.id
        );
      }).toList();
    });
  }

  // 3. Supprimer un étudiant
  Future<void> deleteStudent(String uid) async {
    await _usersCollection.doc(uid).delete();
  }
}