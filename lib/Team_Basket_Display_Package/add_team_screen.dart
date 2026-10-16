import 'package:flutter/material.dart';

// TODO: Βάλε τα σωστά imports του Μπάσκετ σου
import '../../Data_Classes/basketball/basketTeam.dart';
import '../../Firebase_Handle/BasketTeamsHandle.dart';
import '../../Firebase_Handle/firebase_screen_stats_helper.dart';
import '../../globals.dart';

class BasketballAddTeamScreen extends StatefulWidget {
  const BasketballAddTeamScreen({super.key});

  @override
  State<BasketballAddTeamScreen> createState() => _BasketballAddTeamScreenState();
}

class _BasketballAddTeamScreenState extends State<BasketballAddTeamScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers για τα πεδία κειμένου
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
    // 1. Έλεγχος ότι όλα τα πεδία είναι συμπληρωμένα σωστά
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        // 2. Δημιουργία του αντικειμένου της Νέας Ομάδας Μπάσκετ
        basketTeam newTeam = basketTeam(
          _nameController.text.trim(),                  // name
          _nameEnglishController.text.trim(),           // nameEnglish
          0,                                            // matches
          0,                                            // wins
          0,                                            // losses
          1,                                            // group
          int.tryParse(_foundationYearController.text.trim()) ?? DateTime.now().year, // foundationYear
          0,                                            // titles
          "",                                           // coach
          0,                                            // position
          _initialsController.text.trim().toUpperCase(),// initials
          "",                                           // coachName
          [],                                           // players
          [],                                           // history
        );

        // 3. Αποθήκευση στο Firebase
        await BasketTeamsHandle().addNewTeam(newTeam);

        // 4. Μήνυμα Επιτυχίας και Επιστροφή (το true ενεργοποιεί το reload)
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(greek ? "Η ομάδα μπάσκετ προστέθηκε επιτυχώς!" : "Basketball team added successfully!"),
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
    logScreenViewSta(screenName: 'Add Basket Team Page', screenClass: 'Add Basket Team Page');

    bool isDark = darkModeNotifier.value;
    Color bgColor = isDark ? const Color(0xFF121212) : Colors.grey[100]!;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(greek ? "Προσθήκη Ομάδας Μπάσκετ" : "Add Basket Team", style: const TextStyle(color: Colors.white)),
        // Πορτοκαλί Θέμα
        backgroundColor: isDark ? Colors.grey[900] : Colors.orange[700],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.orange))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(_nameController, greek ? "Όνομα Ομάδας (Ελληνικά)" : "Team Name (Greek)", Icons.sports_basketball, isDark),
              _buildTextField(_nameEnglishController, greek ? "Όνομα Ομάδας (Αγγλικά)" : "Team Name (English)", Icons.language, isDark),
              _buildTextField(_initialsController, greek ? "Αρχικά (π.χ. CSD, ECE I)" : "Initials (e.g. CSD)", Icons.short_text, isDark, maxLength: 7),
              _buildTextField(_foundationYearController, greek ? "Έτος Ίδρυσης" : "Foundation Year", Icons.calendar_today, isDark, isNumber: true),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange[600], // Πορτοκαλί κουμπί
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
          prefixIcon: Icon(icon, color: Colors.orange[400]), // Πορτοκαλί icon
          filled: true,
          fillColor: isDark ? Colors.grey[850] : Colors.white,
          counterStyle: const TextStyle(color: Colors.grey),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.orange, width: 2)), // Πορτοκαλί focus
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