import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/user_model.dart';
import '../../services/student_service.dart';

class AddStudentScreen extends StatefulWidget {
  const AddStudentScreen({super.key});

  @override
  State<AddStudentScreen> createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends State<AddStudentScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  
  DateTime? _selectedDate;
  String _profilePreview = "En attente de date"; 

  final StudentService _studentService = StudentService();
  bool _isSaving = false;

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
      String code = StudentService.calculateProfileCode(date);
      _profilePreview = "$code (Catégorie)";
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2010),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) _onDateSelected(picked);
  }

  void _saveStudent() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Date de naissance requise")));
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Préparation du brouillon
      UserModel draftStudent = UserModel(
        uid: '',
        email: _emailController.text.trim(),
        name: "${_firstNameController.text.trim()} ${_lastNameController.text.trim()}",
        phone: _phoneController.text.trim(),
        dateOfBirth: _selectedDate,
        role: 'student',
        matricule: null, 
        profile: null,   
      );

      // Appel au service
      String matricule = await _studentService.addStudentWithAutoLogic(draftStudent);

      if (mounted) {
        _showSuccessDialog(matricule);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur: $e"), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showSuccessDialog(String matricule) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [Icon(Icons.check_circle, color: Colors.green), SizedBox(width: 10), Text("Succès")],
        ),
        content: Text("L'étudiant a été ajouté.\n\nMatricule généré :\n$matricule"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text("OK"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Nouvel Étudiant")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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

              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(10)),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.blue),
                    const SizedBox(width: 10),
                    const Text("Profil : ", style: TextStyle(color: Colors.white)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: Colors.purple.withOpacity(0.2), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.purple)),
                      child: Text(_profilePreview, style: const TextStyle(color: Colors.purpleAccent, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 25),
              const Text("Contact", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
              const SizedBox(height: 15),

              _buildTextField(_phoneController, "Téléphone", Icons.phone, type: TextInputType.phone),
              const SizedBox(height: 15),
              _buildTextField(_emailController, "Email", Icons.email, type: TextInputType.emailAddress),
              
              const SizedBox(height: 30),
              
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