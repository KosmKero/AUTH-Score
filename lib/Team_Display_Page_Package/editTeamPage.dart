import 'package:flutter/material.dart';
import '../Data_Classes/Team.dart';
import '../Firebase_Handle/TeamsHandle.dart';
import '../globals.dart';

class EditTeamScreen extends StatefulWidget {
  final Team team; // Πρέπει να περάσουμε την ομάδα που θέλουμε να κάνουμε edit!

  const EditTeamScreen({super.key, required this.team});

  @override
  State<EditTeamScreen> createState() => _EditTeamScreenState();
}

class _EditTeamScreenState extends State<EditTeamScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late TextEditingController _nameController;
  late TextEditingController _nameEnglishController;
  late TextEditingController _initialsController;
  late TextEditingController _coachController;
  late TextEditingController _foundationYearController;
  late TextEditingController _groupController;
  late TextEditingController _titlesController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Προ-συμπληρώνουμε τα πεδία με τα υπάρχοντα δεδομένα της ομάδας!
    _nameController = TextEditingController(text: widget.team.name);
    _nameEnglishController = TextEditingController(text: widget.team.nameEnglish);
    _initialsController = TextEditingController(text: widget.team.initials);
    _coachController = TextEditingController(text: widget.team.coach);
    _foundationYearController = TextEditingController(text: widget.team.foundationYear.toString());
    _groupController = TextEditingController(text: widget.team.group.toString());
    _titlesController = TextEditingController(text: widget.team.titles.toString());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameEnglishController.dispose();
    _initialsController.dispose();
    _coachController.dispose();
    _foundationYearController.dispose();
    _groupController.dispose();
    _titlesController.dispose();
    super.dispose();
  }

  Future<void> _submitEdit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      int? titles;
      if (globalUser.isUpperAdmin) {
        titles = int.tryParse(_titlesController.text.trim()) ?? widget.team.titles;
      }

      try {
        await TeamsHandle().updateTeamDetails(
          widget.team.name, // Δεν αλλάζει ποτέ, είναι το ID!
          widget.team.nameEnglish, // Δεν το διαβάζουμε καν από τον controller πλέον, κρατάμε το αρχικό!
          _initialsController.text.trim().toUpperCase(),
          _coachController.text.trim(),
          int.parse(_foundationYearController.text.trim()),
          int.parse(_groupController.text.trim()),
          titles,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(greek ? "Οι αλλαγές αποθηκεύτηκαν! ✅" : "Changes saved! ✅"),
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
    Color cardColor = isDark ? Colors.grey[850]! : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          greek ? "Επεξεργασία Ομάδας" : "Edit Team",
          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: isDark ? Colors.grey[900] : const Color.fromARGB(250, 46, 90, 136),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        physics: const BouncingScrollPhysics(),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // 1. ΟΝΟΜΑ (GREEK) - Απενεργοποιημένο!
              _buildModernTextField(
                controller: _nameController,
                label: greek ? "Όνομα Ομάδας (Κλειδωμένο)" : "Team Name (Locked)",
                icon: Icons.lock,
                isDark: isDark,
                cardColor: cardColor,
                enabled: false,
              ),
              const SizedBox(height: 16),

              _buildModernTextField(
                controller: _nameEnglishController,
                label: greek ? "Αγγλικό Όνομα (Κλειδωμένο)" : "English Name (Locked)",
                icon: Icons.lock_outline, // Άλλαξα το εικονίδιο για να δείχνει ότι είναι κλειδωμένο
                isDark: isDark,
                cardColor: cardColor,
                enabled: false,
              ),
              const SizedBox(height: 16),

              // 3. ΑΡΧΙΚΑ & ΠΡΟΠΟΝΗΤΗΣ
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildModernTextField(
                      controller: _initialsController,
                      label: greek ? "Αρχικά" : "Initials",
                      icon: Icons.short_text,
                      isDark: isDark,
                      cardColor: cardColor,
                      maxLength: 7,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 3,
                    child: _buildModernTextField(
                      controller: _coachController,
                      label: greek ? "Προπονητής" : "Coach",
                      icon: Icons.person,
                      isDark: isDark,
                      cardColor: cardColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 4. ΕΤΟΣ, ΟΜΙΛΟΣ & ΤΙΤΛΟΙ
              Row(
                children: [
                  Expanded(
                    child: _buildModernTextField(
                      controller: _foundationYearController,
                      label: greek ? "Έτος" : "Year",
                      icon: Icons.calendar_today,
                      isDark: isDark,
                      cardColor: cardColor,
                      isNumber: true,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildModernTextField(
                      controller: _groupController,
                      label: greek ? "Όμιλος" : "Group",
                      icon: Icons.group_work,
                      isDark: isDark,
                      cardColor: cardColor,
                      isNumber: true,
                    ),
                  ),
                  const SizedBox(width: 10),
                  if (globalUser.isUpperAdmin)
                    Expanded(
                      child: _buildModernTextField(
                        controller: _titlesController,
                        label: greek ? "Τίτλοι" : "Titles",
                        icon: Icons.emoji_events,
                        isDark: isDark,
                        cardColor: cardColor,
                        isNumber: true,
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 32),

              // ΚΟΥΜΠΙ ΑΠΟΘΗΚΕΥΣΗΣ
              SizedBox(
                height: 50,
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange[700],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                  ),
                  onPressed: _submitEdit,
                  child: Text(
                    greek ? 'ΑΠΟΘΗΚΕΥΣΗ ΑΛΛΑΓΩΝ' : 'SAVE CHANGES',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Το Helper Widget
  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDark,
    required Color cardColor,
    bool enabled = true,
    bool isNumber = false,
    int? maxLength,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLength: maxLength,
      style: TextStyle(color: enabled ? (isDark ? Colors.white : Colors.black) : Colors.grey),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: enabled ? Colors.grey : Colors.grey[600], fontSize: 13),
        prefixIcon: Icon(icon, color: enabled ? Colors.blue[400] : Colors.grey),
        filled: true,
        fillColor: enabled ? cardColor : (isDark ? Colors.grey[900] : Colors.grey[300]),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        errorStyle: const TextStyle(color: Colors.redAccent, fontSize: 10),
        counterText: "",
      ),
      validator: (value) {
        if (!enabled) return null;
        if (value == null || value.trim().isEmpty) return greek ? 'Υποχρεωτικό' : 'Required';
        if (isNumber && int.tryParse(value) == null) return greek ? 'Λάθος' : 'Error';
        return null;
      },
    );
  }
}