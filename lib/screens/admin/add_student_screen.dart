import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Nécessite: flutter pub add intl
import 'dart:math'; // Pour le mot de passe aléatoire
import '../../models/user_model.dart';
import '../../services/student_service.dart';

class AddStudentScreen extends StatefulWidget {
  const AddStudentScreen({super.key});

  @override
  State<AddStudentScreen> createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends State<AddStudentScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Contrôleurs (Plus de password controller !)
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  
  DateTime? _selectedDate;
  String _calculatedProfile = "Inconnu";
  String _generatedMatricule = "Sera généré automatiquement";

  final StudentService _studentService = StudentService();
  bool _isSaving = false;

  // 1. Générateur de mot de passe aléatoire
  String _generatePassword() {
    const chars = 'abcdefghjkmnpqrstuvwxyz23456789'; // Pas de i, l, 1, o, 0 pour éviter confusion
    return List.generate(8, (index) => chars[Random().nextInt(chars.length)]).join();
  }

  // 2. Calcul du profil selon l'âge
  void _calculateProfile(DateTime date) {
    final age = DateTime.now().year - date.year;
    setState(() {
      _selectedDate = date;
      if (age < 13) {
        _calculatedProfile = "ENF (Enfant)";
      } else if (age < 18) {
        _calculatedProfile = "ADO (Ado)";
      } else {
        _calculatedProfile = "ADU (Adulte)";
      }
      // Prévisualisation
      String code = _calculatedProfile.substring(0, 3);
      _generatedMatricule = "${DateTime.now().year}-$code-XXXX";
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2010),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) _calculateProfile(picked);
  }

void _saveStudent() async {
    // 1. Validation du formulaire
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("La date de naissance est requise"))
      );
      return;
    }

    // 2. Lancer le spinner
    setState(() => _isSaving = true);

    try {
      // Génération des données
      String codeProfile = _calculatedProfile.substring(0, 3);
      String randomId = (1000 + Random().nextInt(9000)).toString();
      String finalMatricule = "${DateTime.now().year}-$codeProfile-$randomId";
      String autoPassword = _generatePassword();

      final newStudent = UserModel(
        uid: '',
        email: _emailController.text.trim(),
        name: "${_firstNameController.text.trim()} ${_lastNameController.text.trim()}",
        role: 'student',
        dateOfBirth: _selectedDate,
        profile: codeProfile,
        matricule: finalMatricule,
        status: 'Active',
        phone: _phoneController.text.trim(),
      );

      print("⏳ Envoi vers Firebase..."); 
      // 3. Appel au service (C'est ici que ça sauvegarde)
      await _studentService.addStudent(newStudent, autoPassword);
      print("✅ Sauvegarde réussie !");

      // 4. Si on est encore sur l'écran, on affiche le succès
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 10),
                Text("Succès"),
              ],
            ),
            content: Text("L'étudiant a été ajouté.\nMatricule: $finalMatricule"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx); // Ferme Dialog
                  Navigator.pop(context); // Ferme Ecran
                },
                child: const Text("OK"),
              )
            ],
          ),
        );
      }
    } catch (e) {
      print("❌ ERREUR : $e"); // Regarde ta console si ça plante !
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur: $e"), backgroundColor: Colors.red)
        );
      }
    } finally {
      // 5. LE PLUS IMPORTANT : On arrête le spinner QUOI QU'IL ARRIVE
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Nouvel Étudiant")),
      // SCROLL VIEW INDISPENSABLE
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- IDENTITÉ ---
              const Text("Identité", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
              const SizedBox(height: 15),

              Row(
                children: [
                  Expanded(child: _buildTextField(_firstNameController, "Prénom", Icons.person)),
                  const SizedBox(width: 15),
                  Expanded(child: _buildTextField(_lastNameController, "Nom", Icons.person_outline)),
                ],
              ),
              const SizedBox(height: 15),

              InkWell(
                onTap: _pickDate,
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: "Date de Naissance", border: OutlineInputBorder(), prefixIcon: Icon(Icons.calendar_today)),
                  child: Text(
                    _selectedDate == null ? "Sélectionner une date" : DateFormat('dd/MM/yyyy').format(_selectedDate!),
                    style: TextStyle(color: _selectedDate == null ? Colors.grey : Colors.black),
                  ),
                ),
              ),
              const SizedBox(height: 15),

              // Carte Info Profil (Automatique)
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(children: [
                      Icon(Icons.info_outline, color: Colors.blue, size: 20),
                      SizedBox(width: 10),
                      Text("Profil Calculé", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ]),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: Colors.purple.withOpacity(0.2), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.purple)),
                      child: Text(_calculatedProfile, style: const TextStyle(color: Colors.purpleAccent, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 25),
              
              // --- CONTACT & SYSTÈME ---
              const Text("Contact & Accès", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
              const SizedBox(height: 15),

              _buildTextField(_phoneController, "Téléphone", Icons.phone, type: TextInputType.phone),
              const SizedBox(height: 15),

              _buildTextField(_emailController, "Email (Identifiant)", Icons.email, type: TextInputType.emailAddress),
              const SizedBox(height: 15),

              // Matricule Read-only
              TextField(
                enabled: false,
                decoration: InputDecoration(
                  labelText: "Matricule",
                  hintText: _generatedMatricule,
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.qr_code),
                ),
              ),
              
              // Note sur le mot de passe
              const Padding(
                padding: EdgeInsets.only(top: 10, bottom: 20),
                child: Row(
                  children: [
                    Icon(Icons.lock_clock, size: 16, color: Colors.grey),
                    SizedBox(width: 5),
                    Text("Le mot de passe sera généré et envoyé par email.", style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),

              const SizedBox(height: 10),
              
              // BOUTON
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveStudent,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2D62ED), foregroundColor: Colors.white),
                  child: _isSaving 
                    ? const CircularProgressIndicator(color: Colors.white) 
                    : const Text("VALIDER L'INSCRIPTION", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              
              // Espace pour scroll clavier
              const SizedBox(height: 200), 
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {TextInputType type = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      keyboardType: type,
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder(), prefixIcon: Icon(icon)),
      validator: (v) => v!.isEmpty ? 'Requis' : null,
    );
  }
}