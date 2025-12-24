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
  
  // Contrôleurs
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _durationController = TextEditingController();
  final _imageController = TextEditingController();
  final _instructorController = TextEditingController();
  final _priceController = TextEditingController();
  final _capacityController = TextEditingController(text: "30");

  // Listes de choix (Définies une seule fois pour éviter les bugs)
  final List<String> _categories = ['Développement', 'Design', 'Réseaux', 'Sécurité', 'Marketing', 'Business'];
  final List<String> _levels = ['Débutant', 'Intermédiaire', 'Avancé'];

  // Valeurs par défaut
  String _selectedCategory = 'Développement';
  String _selectedLevel = 'Débutant';
  bool _isOpen = true;
  bool _isSaving = false;

  final CourseService _courseService = CourseService();

  void _saveCourse() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      // Gestion de l'image par défaut si vide
      String finalImage = _imageController.text.trim();
      if (finalImage.isEmpty) {
        finalImage = "https://picsum.photos/seed/${DateTime.now().millisecondsSinceEpoch}/800/600";
      }

      final newCourse = CourseModel(
        id: '', // Sera généré par Firebase
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        category: _selectedCategory,
        level: _selectedLevel,
        duration: _durationController.text.trim(),
        instructorName: _instructorController.text.trim().isEmpty ? "Prof. TBD" : _instructorController.text.trim(),
        imageUrl: finalImage,
        price: double.tryParse(_priceController.text.replaceAll(',', '.')) ?? 0.0, // Gère les virgules
        maxCapacity: int.tryParse(_capacityController.text) ?? 30,
        isOpen: _isOpen,
      );

      await _courseService.addCourse(newCourse);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Cours publié avec succès !"), backgroundColor: Colors.green));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur: $e"), backgroundColor: Colors.red));
      }
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

              // Titre
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: "Titre du cours", border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Requis' : null,
              ),
              const SizedBox(height: 15),
              
              // Description
              TextFormField(
                controller: _descController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: "Description", border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Requis' : null,
              ),
              const SizedBox(height: 15),

              // --- ZONE DES DROPDOWNS (CORRIGÉE) ---
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      isExpanded: true, // Empêche le texte de dépasser
                      items: _categories.map((c) => DropdownMenuItem(
                        value: c, 
                        child: Text(c, overflow: TextOverflow.ellipsis)
                      )).toList(),
                      onChanged: (v) => setState(() => _selectedCategory = v!),
                      decoration: const InputDecoration(labelText: "Catégorie", border: OutlineInputBorder()),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedLevel,
                      isExpanded: true,
                      items: _levels.map((l) => DropdownMenuItem(
                        value: l, 
                        child: Text(l)
                      )).toList(),
                      onChanged: (v) => setState(() => _selectedLevel = v!),
                      decoration: const InputDecoration(labelText: "Niveau", border: OutlineInputBorder()),
                    ),
                  ),
                ],
              ),
              // -------------------------------------
              
              const SizedBox(height: 25),
              const Text("Paramètres & Inscription", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
              const SizedBox(height: 15),

              // Prix et Capacité
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true), // Clavier numérique
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
              
              // Switch
              SwitchListTile(
                contentPadding: EdgeInsets.zero, // Aligne bien à gauche
                title: const Text("Inscriptions Ouvertes ?"),
                subtitle: Text(_isOpen ? "Le cours est visible et ouvert" : "Le cours est fermé"),
                value: _isOpen,
                activeColor: Colors.green,
                onChanged: (val) => setState(() => _isOpen = val),
              ),

              const SizedBox(height: 15),
              // Durée
              TextFormField(
                controller: _durationController,
                decoration: const InputDecoration(labelText: "Durée (ex: 20h)", border: OutlineInputBorder(), prefixIcon: Icon(Icons.timer)),
              ),
              
              const SizedBox(height: 15),
              // Image URL (On garde ton champ texte simple)
              TextFormField(
                controller: _imageController,
                decoration: const InputDecoration(labelText: "URL Image (Optionnel)", border: OutlineInputBorder(), prefixIcon: Icon(Icons.image)),
              ),
              // Professeur
               const SizedBox(height: 15),
              TextFormField(
                controller: _instructorController,
                decoration: const InputDecoration(labelText: "Nom du Professeur", border: OutlineInputBorder(), prefixIcon: Icon(Icons.person)),
              ),

              const SizedBox(height: 30),
              
              // BOUTON VALIDER
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveCourse,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2D62ED), foregroundColor: Colors.white),
                  child: _isSaving 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                    : const Text("PUBLIER LE COURS"),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}