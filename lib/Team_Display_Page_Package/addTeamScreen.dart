import 'package:flutter/material.dart';
import '../Data_Classes/Team.dart';
import '../Firebase_Handle/TeamsHandle.dart';
import '../globals.dart';

class AddTeamScreen extends StatefulWidget {
  const AddTeamScreen({super.key});

  @override
  State<AddTeamScreen> createState() => _AddTeamScreenState();
}

class _AddTeamScreenState extends State<AddTeamScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _nameEnglishController = TextEditingController();
  final TextEditingController _initialsController = TextEditingController();
  final TextEditingController _foundationYearController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _nameEnglishController.dispose();
    _initialsController.dispose();
    _foundationYearController.dispose();
    super.dispose();
  }

  Future<void> _submitTeam() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        // 💡 Τα ονόματα που γράφει ο χρήστης εδώ, γίνονται ΤΑΥΤΟΧΡΟΝΑ
        // τα αμετάβλητα ID (name/nameEnglish) ΚΑΙ τα αρχικά Display Names.
        String inputGreek = _nameController.text.trim();
        String inputEnglish = _nameEnglishController.text.trim();

        Team newTeam = Team(
          inputGreek,                                   // name (Immutable ID)
          inputEnglish,                                 // nameEnglish (Immutable ID)
          inputGreek,                                   // displayGreek (Αρχικό display)
          inputEnglish,                                 // displayEnglish (Αρχικό display)
          0,                                            // matches
          0,                                            // wins
          0,                                            // losses
          0,                                            // draws
          0,                                            // group (0 = Χωρίς Όμιλο αρχικά!)
          int.tryParse(_foundationYearController.text.trim()) ?? DateTime.now().year, // foundationYear
          0,                                            // titles
          "",                                           // coach
          0,                                            // position
          _initialsController.text.trim().toUpperCase(),// initials
          0,                                            // goals for
          0,                                            // goals against
          [],                                           // players
        );

        await TeamsHandle().addNewTeam(newTeam);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(greek ? "Η ομάδα προστέθηκε επιτυχώς!" : "Team added successfully!"),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Σφάλμα: $e"), backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = darkModeNotifier.value;
    Color bgColor = isDark ? const Color(0xFF121212) : Colors.grey[100]!;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(greek ? "Προσθήκη Νέας Ομάδας" : "Add New Team", style: const TextStyle(color: Colors.white)),
        backgroundColor: isDark ? Colors.grey[900] : const Color.fromARGB(250, 46, 90, 136),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(_nameController, greek ? "Όνομα Ομάδας (Ελληνικά)" : "Team Name (Greek)", Icons.sports_soccer, isDark),
              _buildTextField(_nameEnglishController, greek ? "Όνομα Ομάδας (Αγγλικά)" : "Team Name (English)", Icons.language, isDark),

              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildTextField(_initialsController, greek ? "Αρχικά (π.χ. CSD)" : "Initials", Icons.short_text, isDark, maxLength: 7),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 3,
                    child: _buildTextField(_foundationYearController, greek ? "Έτος Ίδρυσης" : "Foundation Year", Icons.calendar_today, isDark, isNumber: true),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: _submitTeam,
                  child: Text(
                    greek ? "ΑΠΟΘΗΚΕΥΣΗ ΟΜΑΔΑΣ" : "SAVE TEAM",
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Το ίδιο Helper Widget που είχες
  Widget _buildTextField(TextEditingController controller, String label, IconData icon, bool isDark, {bool isNumber = false, int? maxLength}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        maxLength: maxLength,
        style: TextStyle(color: isDark ? Colors.white : Colors.black),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey),
          prefixIcon: Icon(icon, color: Colors.blue[400]),
          filled: true,
          fillColor: isDark ? Colors.grey[850] : Colors.white,
          counterStyle: const TextStyle(color: Colors.grey),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.blue, width: 2)),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return greek ? "Υποχρεωτικό πεδίο" : "Required field";
          }
          return null;
        },
      ),
    );
  }
}