import 'package:cloud_firestore/cloud_firestore.dart';

class EnrollmentModel {
  final String id;
  final String studentId;
  final String courseId;
  final String studentName;
  final String courseTitle;
  final double priceAtEnrollment;  
  final DateTime enrollmentDate;

  EnrollmentModel({
    required this.id,
    required this.studentId,
    required this.courseId,
    required this.studentName,
    required this.courseTitle,
    required this.priceAtEnrollment,
    required this.enrollmentDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'courseId': courseId,
      'studentName': studentName,
      'courseTitle': courseTitle,
      'priceAtEnrollment': priceAtEnrollment,
      'enrollmentDate': enrollmentDate,
    };
  }

  factory EnrollmentModel.fromMap(Map<String, dynamic> map, String id) {
    return EnrollmentModel(
      id: id,
      studentId: map['studentId'] ?? '',
      courseId: map['courseId'] ?? '',
      studentName: map['studentName'] ?? 'Inconnu',
      courseTitle: map['courseTitle'] ?? 'Cours Inconnu',
      priceAtEnrollment: (map['priceAtEnrollment'] ?? 0.0).toDouble(),
      enrollmentDate: (map['enrollmentDate'] as Timestamp).toDate(),
    );
  }
}