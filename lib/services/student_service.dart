import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class StudentService {
  final CollectionReference _usersCollection = 
      FirebaseFirestore.instance.collection('users');

  // --- LOGIQUE MÉTIER (Helper statique pour l'utiliser dans la vue aussi) ---
  static String calculateProfileCode(DateTime date) {
    final age = DateTime.now().year - date.year;
    if (age < 13) return "ENF"; // Enfant
    if (age < 18) return "ADO"; // Adolescent
    return "ADU"; // Adulte
  }

  // --- MÉTHODE PRINCIPALE : CRÉATION AVEC LOGIQUE AUTOMATIQUE ---
  // On reçoit un étudiant "brouillon" (sans matricule, sans profil) et on le complète.
  Future<String> addStudentWithAutoLogic(UserModel draftStudent) async {
    // 1. Vérification de sécurité
    if (draftStudent.dateOfBirth == null) throw Exception("Date de naissance manquante");
    
    // 2. Calculs Métier (Profil & Matricule)
    DateTime dob = draftStudent.dateOfBirth!;
    String profileCode = calculateProfileCode(dob);
    String fullProfile = "$profileCode (Calculé)";
    
    String randomId = (1000 + Random().nextInt(9000)).toString();
    String generatedMatricule = "${DateTime.now().year}-$profileCode-$randomId";

    // 3. Génération Mot de passe (Simulation)
    const chars = 'abcdefghjkmnpqrstuvwxyz23456789';
    String autoPassword = List.generate(8, (index) => chars[Random().nextInt(chars.length)]).join();

    // 4. Création de l'objet FINAL (On copie le brouillon + les infos calculées)
    final finalStudent = UserModel(
      uid: '', // Firestore générera l'ID
      email: draftStudent.email,
      name: draftStudent.name,
      phone: draftStudent.phone,
      role: 'student',
      dateOfBirth: dob,
      status: 'Active',
      // Ici on injecte ce que le service a calculé :
      profile: fullProfile,
      matricule: generatedMatricule,
    );

    // 5. Sauvegarde en Base
    await _usersCollection.add(finalStudent.toMap());
    
    // On retourne le matricule pour pouvoir l'afficher à l'utilisateur
    return generatedMatricule;
  }

  // --- MÉTHODES CLASSIQUES (Lecture / Suppression) ---
  
  Stream<List<UserModel>> getStudentsStream() {
    return _usersCollection
        .where('role', isEqualTo: 'student')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  Future<void> deleteStudent(String uid) async {
    await _usersCollection.doc(uid).delete();
  }
}