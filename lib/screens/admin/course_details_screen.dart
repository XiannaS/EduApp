import 'package:flutter/material.dart';
import '../../models/course_model.dart';
import '../../models/enrollment_model.dart'; 
import '../../services/enrollment_service.dart';  
import 'add_enrollment_screen.dart';

class CourseDetailsScreen extends StatelessWidget {
  final CourseModel course;

  const CourseDetailsScreen({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    // On instancie le service pour récupérer les élèves
    final EnrollmentService enrollmentService = EnrollmentService();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // 1. EN-TÊTE AVEC IMAGE
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(course.title, 
                style: const TextStyle(fontSize: 16, color: Colors.white, shadows: [Shadow(color: Colors.black, blurRadius: 10)])
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    course.imageUrl.isNotEmpty ? course.imageUrl : "https://via.placeholder.com/400",
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey, child: const Icon(Icons.broken_image)),
                  ),
                  Container(color: Colors.black.withOpacity(0.4)), // Filtre sombre
                ],
              ),
            ),
          ),

          // 2. LE CONTENU DE LA PAGE
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badges
                  Row(
                    children: [
                      Chip(label: Text(course.category), backgroundColor: Colors.blue.withOpacity(0.1), labelStyle: const TextStyle(color: Colors.blue)),
                      const SizedBox(width: 10),
                      Chip(
                        label: Text(course.isOpen ? "Ouvert" : "Fermé"),
                        backgroundColor: course.isOpen ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                        labelStyle: TextStyle(color: course.isOpen ? Colors.green : Colors.red),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Prix & Durée
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("${course.price} MAD", style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF2D62ED))),
                      Row(children: [const Icon(Icons.access_time, size: 20), const SizedBox(width: 5), Text(course.duration)]),
                    ],
                  ),
                  const Divider(height: 30),

                  // Instructeur
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(child: Text(course.instructorName[0].toUpperCase())),
                    title: Text(course.instructorName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text("Instructeur Principal"),
                  ),
                  const Divider(height: 30),

                  // Description
                  const Text("À propos", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text(course.description, style: const TextStyle(color: Colors.black87, height: 1.5)),
                  const Divider(height: 40),

                  // Liste des Étudiants Inscrits
                  StreamBuilder<List<EnrollmentModel>>(
                    stream: enrollmentService.getStudentsForCourse(course.id),
                    builder: (context, snapshot) {
                      // 1. Calcul du nombre d'inscrits (0 par défaut si chargement)
                      int currentCount = 0;
                      if (snapshot.hasData) {
                        currentCount = snapshot.data!.length;
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Titre + Compteur dynamique
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Étudiants Inscrits", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              Text(
                                "$currentCount/${course.maxCapacity}",  
                                style: TextStyle(
                                  color: currentCount >= course.maxCapacity ? Colors.red : Colors.grey, 
                                  fontWeight: FontWeight.bold
                                )
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),

                          // 2. Gestion des états (Chargement, Vide, Liste)
                          if (snapshot.connectionState == ConnectionState.waiting)
                            const Center(child: CircularProgressIndicator()),
                          
                          if (!snapshot.hasData || snapshot.data!.isEmpty)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(10)),
                              child: const Column(
                                children: [
                                  Icon(Icons.person_off, color: Colors.grey),
                                  SizedBox(height: 5),
                                  Text("Aucun inscrit.", style: TextStyle(color: Colors.grey)),
                                ],
                              ),
                            )
                          else
                            
                            ListView.separated(
                              shrinkWrap: true,  
                              physics: const NeverScrollableScrollPhysics(),  
                              itemCount: snapshot.data!.length,
                              separatorBuilder: (ctx, i) => const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final enrollment = snapshot.data![index];
                                return ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.blue.withOpacity(0.1),
                                    child: Text(enrollment.studentName[0].toUpperCase(), style: const TextStyle(color: Colors.blue)),
                                  ),
                                  title: Text(enrollment.studentName, style: const TextStyle(fontWeight: FontWeight.w600)),
                                  subtitle: Text("Inscrit le ${enrollment.enrollmentDate.day}/${enrollment.enrollmentDate.month}"),
                                  trailing: const Icon(Icons.check_circle, color: Colors.green, size: 18),
                                );
                              },
                            ),
                            
                          // Petit espace en bas pour le bouton flottant
                          const SizedBox(height: 80),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      // Bouton Inscription
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddEnrollmentScreen(preselectedCourse: course),
            ),
          );
        },
        label: const Text("Inscrire un étudiant"),
        icon: const Icon(Icons.person_add),
        backgroundColor: const Color(0xFF2D62ED),
      ),
    );
  }
}