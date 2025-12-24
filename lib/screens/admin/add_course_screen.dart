import 'package:flutter/material.dart';
import '../../models/course_model.dart';
import '../../services/course_service.dart';

class AddCourseScreen extends StatefulWidget {
  const AddCourseScreen({super.key});

  @override
  State<AddCourseScreen> createState() => _AddCourseScreenState();
}

class _AddCourseScreenState extends State<AddCourseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _durationController = TextEditingController();
  final _imageController = TextEditingController();
  final _instructorController = TextEditingController();
  
  // NOUVEAUX CONTROLEURS
  final _priceController = TextEditingController();
  final _capacityController = TextEditingController(text: "30"); // Par défaut 30

  String _selectedCategory = 'Développement';
  String _selectedLevel = 'Débutant';
  bool _isOpen = true; // Statut par défaut

  final CourseService _courseService = CourseService();
  bool _isSaving = false;

  final List<String> _categories = ['Développement', 'Design', 'Réseaux', 'Sécurité', 'Marketing'];
  final List<String> _levels = ['Débutant', 'Intermédiaire', 'Avancé'];

  void _saveCourse() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      String finalImage = _imageController.text.trim();
      if (finalImage.isEmpty) {
       // Picsum est beaucoup plus stable. On ajoute un ID aléatoire pour varier les images.
finalImage = "https://picsum.photos/seed/${DateTime.now().millisecondsSinceEpoch}/800/600";
      }

      final newCourse = CourseModel(
        id: '',
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        category: _selectedCategory,
        level: _selectedLevel,
        duration: _durationController.text.trim(),
        instructorName: _instructorController.text.trim().isEmpty ? "Prof. TBD" : _instructorController.text.trim(),
        imageUrl: finalImage,
        // NOUVELLES DONNÉES
        price: double.tryParse(_priceController.text) ?? 0.0,
        maxCapacity: int.tryParse(_capacityController.text) ?? 30,
        isOpen: _isOpen,
        
      );

      await _courseService.addCourse(newCourse);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Cours publié !"), backgroundColor: Colors.green));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur: $e"), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Nouveau Cours")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Détails du Cours", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
              const SizedBox(height: 15),

              TextFormField(controller: _titleController, decoration: const InputDecoration(labelText: "Titre du cours", border: OutlineInputBorder()), validator: (v) => v!.isEmpty ? 'Requis' : null),
              const SizedBox(height: 15),
              
              TextFormField(controller: _descController, maxLines: 3, decoration: const InputDecoration(labelText: "Description", border: OutlineInputBorder()), validator: (v) => v!.isEmpty ? 'Requis' : null),
              const SizedBox(height: 15),

             Row(
  children: [
    // --- 1. Enveloppe le premier menu dans Expanded ---
    Expanded( 
      child: DropdownButtonFormField<String>(
        value: _selectedCategory,
        items: ["Développement", "Design", "Marketing", "Business"]
            .map((c) => DropdownMenuItem(value: c, child: Text(c, overflow: TextOverflow.ellipsis)))
            .toList(),
        onChanged: (v) => setState(() => _selectedCategory = v!),
        decoration: const InputDecoration(labelText: "Catégorie", border: OutlineInputBorder()),
      ),
    ),
    
    const SizedBox(width: 15), // Un peu d'espace au milieu

    // --- 2. Enveloppe le deuxième menu dans Expanded ---
    Expanded(
      child: DropdownButtonFormField<String>(
        value: _selectedLevel,
        items: ["Débutant", "Intermédiaire", "Avancé"]
            .map((l) => DropdownMenuItem(value: l, child: Text(l)))
            .toList(),
        onChanged: (v) => setState(() => _selectedLevel = v!),
        decoration: const InputDecoration(labelText: "Niveau", border: OutlineInputBorder()),
      ),
    ),
  ],
),
              const SizedBox(height: 25),
              
              const Text("Paramètres & Inscription", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
              const SizedBox(height: 15),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: "Prix (MAD)", suffixText: "DH", border: OutlineInputBorder()),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: TextFormField(
                      controller: _capacityController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: "Capacité Max", border: OutlineInputBorder()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              
              // Switch Statut
              SwitchListTile(
                title: const Text("Inscriptions Ouvertes ?"),
                subtitle: Text(_isOpen ? "Le cours est visible et ouvert" : "Le cours est fermé"),
                value: _isOpen,
                activeThumbColor: Colors.green,
                onChanged: (val) => setState(() => _isOpen = val),
              ),

              const SizedBox(height: 15),
              TextFormField(controller: _durationController, decoration: const InputDecoration(labelText: "Durée (ex: 20h)", border: OutlineInputBorder(), prefixIcon: Icon(Icons.timer))),
              const SizedBox(height: 15),
              TextFormField(controller: _imageController, decoration: const InputDecoration(labelText: "URL Image (Optionnel)", border: OutlineInputBorder(), prefixIcon: Icon(Icons.image))),

              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveCourse,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2D62ED), foregroundColor: Colors.white),
                  child: _isSaving ? const CircularProgressIndicator(color: Colors.white) : const Text("PUBLIER LE COURS"),
                ),
              ),
              const SizedBox(height: 20), // Espace pour le scroll
            ],
          ),
        ),
      ),
    );
  }
}