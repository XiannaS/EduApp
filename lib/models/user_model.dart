import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String? name; //  (Prénom + Nom)
  final String role;          // 'student' ou 'admin'
  final String? matricule;      // ex: 2024-ADO-015
  final String? profile;        // ENF (Enfant), ADO (Ado), ADU (Adulte)
  final String? status;         // Active, Pending
  final DateTime? dateOfBirth;  // Pour calculer l'âge
  final String? phone;
  final String? gender;

  UserModel({
    required this.uid,
    required this.email,
    this.name,
    required this.role,
    this.matricule,
    this.profile,
    this.status,
    this.dateOfBirth,
    this.phone,
    this.gender,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      uid: id,
      email: map['email'] ?? '',
      name: map['name'] ?? 'Sans nom',
      role: map['role'] ?? 'student',
      matricule: map['matricule'],
      profile: map['profile'],
      status: map['status'] ?? 'Active',
      dateOfBirth: map['dateOfBirth'] != null ? (map['dateOfBirth'] as Timestamp).toDate() : null,
      phone: map['phone'],
      gender: map['gender'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'role': role,
      'matricule': matricule,
      'profile': profile,
      'status': status,
      'dateOfBirth': dateOfBirth,
      'phone': phone,
      'gender': gender,
    };
  }
 
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is UserModel && other.uid == uid;
  }

  @override
  int get hashCode => uid.hashCode;
}  