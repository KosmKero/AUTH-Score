import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

import '../Data_Classes/Player.dart';
import '../Data_Classes/Team.dart';
import '../Firebase_Handle/firebase_screen_stats_helper.dart';
import '../globals.dart';

class AddPlayerScreen extends StatefulWidget {
  final Team team;
  final Function(Player) onPlayerAdded;

  const AddPlayerScreen({Key? key, required this.team, required this.onPlayerAdded}) : super(key: key);

  @override
  _AddPlayerScreenState createState() => _AddPlayerScreenState();
}

class _AddPlayerScreenState extends State<AddPlayerScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _numberController = TextEditingController();

  String _selectedPosition = 'Τερματοφύλακας';
  final List<String> positions = ['Τερματοφύλακας', 'Αμυντικός', 'Μέσος', 'Επιθετικός'];

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _numberController.dispose();
    super.dispose();
  }

  void _savePlayer() {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text.trim();
      final surname = _surnameController.text.trim();
      final number = int.parse(_numberController.text.trim());
      int pos = positions.indexOf(_selectedPosition);

      final newPlayer = Player(
          name,
          surname,
          pos,
          0, // Goals
          number,
          widget.team.name,
          0, // Yellow cards
          0, // Red cards
          widget.team.nameEnglish,
          null, // Health card
          0, // Appearances
          const Uuid().v4() // Νέο ασφαλές ID!
      );

      widget.onPlayerAdded(newPlayer);
      Navigator.pop(context, newPlayer);
    }
  }

  @override
  Widget build(BuildContext context) {
    logScreenViewSta(screenName: 'Add player', screenClass: 'Add player page');

    bool isDark = darkModeNotifier.value;
    Color bgColor = isDark ? const Color(0xFF121212) : Colors.grey[100]!;
    Color cardColor = isDark ? Colors.grey[850]! : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          greek ? 'Προσθήκη Νέου Παίκτη' : 'Add New Player',
          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: isDark ? Colors.grey[900] : const Color.fromARGB(250, 46, 90, 136),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        physics: const BouncingScrollPhysics(),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greek ? "Στοιχεία Παίκτη" : "Player Details",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
              ),
              const SizedBox(height: 15),

              _buildModernTextField(
                  controller: _nameController,
                  label: greek ? 'Όνομα' : 'Name',
                  icon: Icons.person,
                  isDark: isDark,
                  cardColor: cardColor
              ),
              const SizedBox(height: 12),

              _buildModernTextField(
                  controller: _surnameController,
                  label: greek ? 'Επώνυμο' : 'Surname',
                  icon: Icons.person_outline,
                  isDark: isDark,
                  cardColor: cardColor
              ),
              const SizedBox(height: 12),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start, // Στοίχιση πάνω γιατί το FormField μπορεί να μεγαλώσει με το error text
                children: [
                  Expanded(
                    flex: 1,
                    child: _buildModernTextField(
                        controller: _numberController,
                        label: greek ? 'Νούμερο' : 'Number',
                        icon: Icons.numbers,
                        isNumber: true,
                        isDark: isDark,
                        cardColor: cardColor
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      value: _selectedPosition,
                      dropdownColor: cardColor,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 16),
                      decoration: InputDecoration(
                        labelText: greek ? 'Θέση' : 'Position',
                        labelStyle: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 13),
                        prefixIcon: Icon(Icons.sports_soccer, color: isDark ? Colors.blue[300] : Colors.blue[400]),
                        filled: true,
                        fillColor: cardColor,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.blueAccent, width: 1.5)),
                      ),
                      items: positions.map((position) {
                        return DropdownMenuItem<String>(
                          value: position,
                          child: Text(position),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedPosition = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              SizedBox(
                height: 50,
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[600], // Πράσινο χρώμα γιατί είναι ενέργεια "Προσθήκης"
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                  ),
                  onPressed: _savePlayer,
                  child: Text(
                    greek ? 'ΠΡΟΣΘΗΚΗ ΠΑΙΚΤΗ' : 'ADD PLAYER',
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

  // Το ίδιο Helper Widget για τέλεια ευκρίνεια και συνέπεια
  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDark,
    required Color cardColor,
    bool isNumber = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      inputFormatters: isNumber ? [FilteringTextInputFormatter.digitsOnly] : null,
      style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 13),
        prefixIcon: Icon(icon, color: isDark ? Colors.blue[300] : Colors.blue[400]),
        filled: true,
        fillColor: cardColor,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.blueAccent, width: 1.5)),
        errorStyle: const TextStyle(color: Colors.redAccent, fontSize: 10),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) return greek ? 'Υποχρεωτικό' : 'Required';
        if (isNumber) {
          final number = int.tryParse(value);
          if (number == null || number < 1 || number > 99) {
            return greek ? 'Από 1 έως 99' : 'Between 1 and 99';
          }
        }
        return null;
      },
    );
  }
}