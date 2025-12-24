import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Vérifie bien que ces chemins sont corrects chez toi
import '../../../../models/course_model.dart';
import '../../../../services/course_service.dart';
import '../../../../providers/theme_provider.dart';
import '../add_course_screen.dart';
import '../course_details_screen.dart';

class CoursesView extends StatelessWidget {
  const CoursesView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    final CourseService courseService = CourseService();

    return Scaffold(
      backgroundColor: Colors.transparent,
      
      // LE BOUTON FLOTTANT (Pour ajouter un cours)
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF2D62ED),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Nouveau Cours", style: TextStyle(color: Colors.white)),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AddCourseScreen()));
        },
      ),

      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titre de la page
            Text("Catalogue des Cours", style: TextStyle(color: theme.textColor, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Text("Gérez l'offre de formation (Prix, Places, Statut).", style: TextStyle(color: theme.subTextColor, fontSize: 14)),
            const SizedBox(height: 20),
            
            // LA LISTE (STREAM)
            Expanded(
              child: StreamBuilder<List<CourseModel>>(
                stream: courseService.getCoursesStream(),
                builder: (context, snapshot) {
                  // 1. Chargement
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  // 2. Erreur ou Vide
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.library_books_outlined, size: 60, color: theme.subTextColor),
                          const SizedBox(height: 10),
                          Text("Aucun cours publié.", style: TextStyle(color: theme.subTextColor)),
                        ],
                      ),
                    );
                  }

                  // 3. Affichage des données
                  final courses = snapshot.data!;
                  return ListView.builder(
                    itemCount: courses.length,
                    itemBuilder: (context, index) {
                      final course = courses[index];
                      
                      // CARTE DU COURS (cliquable)
                      return GestureDetector(
  onTap: () {
    Navigator.push(context, MaterialPageRoute(builder: (_) => CourseDetailsScreen(course: course)));
  },
  child: Card( 
                        color: theme.cardColor,
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(color: Colors.grey.withOpacity(0.1)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              // A. Image Miniature
                              Container(
                                width: 70, height: 70,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.grey[200],
                                  image: DecorationImage(
                                    image: NetworkImage(course.imageUrl.isNotEmpty 
                                      ? course.imageUrl 
                                      : "https://via.placeholder.com/150"),// Placeholder si pas d'image
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 15),
                              
                              // B. Informations Principales
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(course.title, style: TextStyle(color: theme.textColor, fontWeight: FontWeight.bold, fontSize: 16)),
                                    const SizedBox(height: 4),
                                    Text("${course.category} • ${course.duration}", style: TextStyle(color: theme.subTextColor, fontSize: 12)),
                                    const SizedBox(height: 6),
                                    // Prix en Bleu
                                    Text("${course.price} MAD", style: const TextStyle(color: Color(0xFF2D62ED), fontWeight: FontWeight.bold, fontSize: 14)),
                                  ],
                                ),
                              ),
                              
                              // C. Colonne Droite (Statut + Capacité + Delete)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  // Badge Open/Closed
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: course.isOpen ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: course.isOpen ? Colors.green : Colors.red),
                                    ),
                                    child: Text(
                                      course.isOpen ? "Open" : "Closed",
                                      style: TextStyle(color: course.isOpen ? Colors.green : Colors.red, fontSize: 10, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  
                                  // Capacité
                                  Text(
                                    "0/${course.maxCapacity} inscrits", 
                                    style: TextStyle(color: theme.subTextColor, fontSize: 10)
                                  ),
                                  
                                  const SizedBox(height: 5),
                                  
                                  // Bouton Supprimer 
                                  InkWell(
                                    onTap: () => courseService.deleteCourse(course.id),
                                    child: const Padding(
                                      padding: EdgeInsets.all(4.0),
                                      child: Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      )
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