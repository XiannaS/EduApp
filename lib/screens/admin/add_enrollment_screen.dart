import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../models/course_model.dart';
import '../../models/enrollment_model.dart';
import '../../services/student_service.dart';
import '../../services/course_service.dart';
import '../../services/enrollment_service.dart';

class AddEnrollmentScreen extends StatefulWidget {
  //  Si on vient depuis un cours, on pré-remplit le cours
  final CourseModel? preselectedCourse; 

  const AddEnrollmentScreen({super.key, this.preselectedCourse});

  @override
  State<AddEnrollmentScreen> createState() => _AddEnrollmentScreenState();
}

class _AddEnrollmentScreenState extends State<AddEnrollmentScreen> {
  final _formKey = GlobalKey<FormState>();
  
  UserModel? _selectedStudent;
  CourseModel? _selectedCourse;
  
  bool _isSaving = false;
  final EnrollmentService _enrollmentService = EnrollmentService();

  @override
  void initState() {
    super.initState();
    if (widget.preselectedCourse != null) {
      _selectedCourse = widget.preselectedCourse;
    }
  }

  void _saveEnrollment() async {
    if (_selectedStudent == null || _selectedCourse == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Veuillez sélectionner un étudiant ET un cours")));
      return;
    }

    setState(() => _isSaving = true);

    try {
      final enrollment = EnrollmentModel(
        id: '',
        studentId: _selectedStudent!.uid,
        courseId: _selectedCourse!.id,
        studentName: _selectedStudent!.name ?? "Inconnu",
        courseTitle: _selectedCourse!.title,
        priceAtEnrollment: _selectedCourse!.price,
        enrollmentDate: DateTime.now(),
      );

      await _enrollmentService.enrollStudent(enrollment);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Inscription validée !"), backgroundColor: Colors.green));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        // Affiche l'erreur (ex: Déjà inscrit)
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceAll("Exception: ", "")), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Nouvelle Inscription")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // 1. DROPDOWN ÉTUDIANTS
            StreamBuilder<List<UserModel>>(
              stream: StudentService().getStudentsStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const LinearProgressIndicator();
                final students = snapshot.data!;
                
                return DropdownButtonFormField<UserModel>(
                  isExpanded: true,  
                  decoration: const InputDecoration(labelText: "Sélectionner l'étudiant", border: OutlineInputBorder(), prefixIcon: Icon(Icons.person)),
                  value: _selectedStudent,
                  items: students.map((s) {
                    return DropdownMenuItem(
                      value: s, 
                      child: Text(
                        "${s.name} (${s.matricule ?? 'N/A'})",
                        overflow: TextOverflow.ellipsis,  
                      )
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedStudent = val),
                );
              },
            ),
            const SizedBox(height: 20),

            // 2. DROPDOWN COURS
            StreamBuilder<List<CourseModel>>(
              stream: CourseService().getCoursesStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const LinearProgressIndicator();
                final courses = snapshot.data!;

                return DropdownButtonFormField<CourseModel>(
                  isExpanded: true,  
                  decoration: const InputDecoration(labelText: "Sélectionner le cours", border: OutlineInputBorder(), prefixIcon: Icon(Icons.book)),
                  value: _selectedCourse,
                  // On compare les IDs pour que le pré-remplissage fonctionne  
                  items: courses.map((c) {
                    return DropdownMenuItem(
                      value: c, 
                      child: Text(
                        "${c.title} (${c.price} MAD)",
                        overflow: TextOverflow.ellipsis, 
                      )
                    );
                  }).toList(),
                  onChanged: widget.preselectedCourse != null 
                    ? null // Si pré-rempli, on bloque le changement 
                    : (val) => setState(() => _selectedCourse = val), 
                );
              },
            ),

            const Spacer(),

            // 3. BOUTON
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveEnrollment,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2D62ED), foregroundColor: Colors.white),
                child: _isSaving ? const CircularProgressIndicator(color: Colors.white) : const Text("VALIDER L'INSCRIPTION"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}