import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../models/user_model.dart';
import '../../../../services/student_service.dart';
import '../../../../providers/theme_provider.dart';
import '../add_student_screen.dart';
import '../student_details_screen.dart'; // <--- NOUVEL IMPORT

class StudentsView extends StatefulWidget {
  const StudentsView({super.key});

  @override
  State<StudentsView> createState() => _StudentsViewState();
}

class _StudentsViewState extends State<StudentsView> {
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    final StudentService studentService = StudentService();

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF2D62ED),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Ajouter", style: TextStyle(color: Colors.white)),
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddStudentScreen())),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Gestion Étudiants", style: TextStyle(color: theme.textColor, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),

            // BARRE DE RECHERCHE
            TextField(
              decoration: InputDecoration(
                hintText: "Rechercher par nom ou matricule...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: theme.cardColor,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
              onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
            ),
            const SizedBox(height: 20),
            
            Expanded(
              child: StreamBuilder<List<UserModel>>(
                stream: studentService.getStudentsStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                  if (!snapshot.hasData || snapshot.data!.isEmpty) return Center(child: Text("Aucun étudiant.", style: TextStyle(color: theme.subTextColor)));

                  // FILTRAGE LOCAL
                  final allStudents = snapshot.data!;
                  final filteredStudents = allStudents.where((student) {
                    final name = student.name?.toLowerCase() ?? "";
                    final matricule = student.matricule?.toLowerCase() ?? "";
                    return name.contains(_searchQuery) || matricule.contains(_searchQuery);
                  }).toList();

                  if (filteredStudents.isEmpty) return const Center(child: Text("Aucun résultat trouvé."));

                  return ListView.builder(
                    itemCount: filteredStudents.length,
                    itemBuilder: (context, index) {
                      final student = filteredStudents[index];

                      return Card(
                        color: theme.cardColor,
                        margin: const EdgeInsets.only(bottom: 10),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: Colors.grey.withValues(alpha: 0.1))),
                        child: InkWell( // REND LA CARTE CLIQUABLE
                          onTap: () {
                             Navigator.push(context, MaterialPageRoute(builder: (_) => StudentDetailsScreen(student: student)));
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.blue.withValues(alpha: 0.1),
                                  child: Text(student.name != null && student.name!.isNotEmpty ? student.name![0].toUpperCase() : "S", style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                                ),
                                const SizedBox(width: 15),
                                
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(student.name ?? "Inconnu", style: TextStyle(color: theme.textColor, fontWeight: FontWeight.bold, fontSize: 14)),
                                      // AFFICHAGE DU MATRICULE ICI
                                      Text(student.matricule ?? "Pas de matricule", style: TextStyle(color: theme.subTextColor, fontSize: 12)),
                                    ],
                                  ),
                                ),
                                
                                // Badge Profil
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.purple.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(student.profile ?? "UNK", style: const TextStyle(color: Colors.purple, fontSize: 10, fontWeight: FontWeight.bold)),
                                ),
                                
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                                  onPressed: () => studentService.deleteStudent(student.uid),
                                ),
                              ],
                            ),
                          ),
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