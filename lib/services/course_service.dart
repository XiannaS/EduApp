import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart'; // Pour le local
import 'package:connectivity_plus/connectivity_plus.dart'; // Pour tester la connexion
import '../models/course_model.dart';

class CourseService {
  final CollectionReference _courses = FirebaseFirestore.instance.collection('courses');
  final Box _localBox = Hive.box('courses_cache'); // Notre boite locale

  // AJOUTER (Firebase + Sauvegarde Local)
  Future<void> addCourse(CourseModel course) async {
    // On ajoute à Firebase
    await _courses.add(course.toMap());
    // Note : On ne sauvegarde pas manuellement en local ici, 
    // car le Stream ci-dessous va détecter le changement et mettre à jour le cache automatiquement.
  }

  // SUPPRIMER
  Future<void> deleteCourse(String docId) async {
    await _courses.doc(docId).delete();
  }

  // RÉCUPÉRER (Mode Hybride : Local + Cloud)
  Stream<List<CourseModel>> getCoursesStream() async* {
    // 1. D'ABORD : On envoie ce qu'on a en cache (Affichage instantané !)
    if (_localBox.isNotEmpty) {
      print("Chargement depuis le cache local Hive...");
      final List<dynamic> cachedMaps = _localBox.values.toList();
      final List<CourseModel> localCourses = cachedMaps.map((map) {
        // On doit caster le map dynamique en Map<String, dynamic>
        return CourseModel.fromMap(Map<String, dynamic>.from(map), map['id'] ?? 'local');
      }).toList();
      yield localCourses;
    }

    // 2. ENSUITE : On vérifie la connexion internet
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      print("Pas d'internet, utilisation du cache local uniquement.");
      return; // On s'arrête là, on garde les données locales
    }

    // 3. SI INTERNET : On écoute Firebase pour avoir les dernières infos
    print(" Connexion à Firebase...");
    try {
      yield* _courses.snapshots().map((snapshot) {
        // A. On convertit les données Firebase
        final liveCourses = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          // Important : on stocke l'ID dans la map pour la sauvegarde locale
          data['id'] = doc.id; 
          return CourseModel.fromMap(data, doc.id);
        }).toList();

        // B. On met à jour le cache local (HIVE)
        print(" Mise à jour du cache local...");
        _localBox.clear(); // On vide le vieux cache
        for (var course in liveCourses) {
          // On sauvegarde chaque cours sous forme de Map
          Map<String, dynamic> mapToSave = course.toMap();
          mapToSave['id'] = course.id; // On force l'ajout de l'ID
          _localBox.add(mapToSave);
        }

        return liveCourses;
      });
    } catch (e) {
      print("Erreur Firebase: $e");
      // Si Firebase plante, on a déjà envoyé le cache au début (étape 1), donc l'app ne sera pas blanche.
    }
  }
}