import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../Data_Classes/Player.dart';
import '../Data_Classes/Team.dart';
import '../Firebase_Handle/firebase_screen_stats_helper.dart';
import '../globals.dart'; // Απαραίτητο για το darkModeNotifier και το greek

class PlayerEditPage extends StatefulWidget {
  final Player player;
  final Team team;

  const PlayerEditPage({super.key, required this.player, required this.team});

  @override
  _PlayerEditPageState createState() => _PlayerEditPageState();
}

class _PlayerEditPageState extends State<PlayerEditPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _surnameController;
  late TextEditingController _numberController;

  // Στατιστικά (Αν και συνήθως δεν τα πειράζουμε με το χέρι, τα αφήνουμε για τους Admins)
  late TextEditingController _goalsController;
  late TextEditingController _yellowController;
  late TextEditingController _redController;

  // Μεταβλητή για το Dropdown της θέσης
  late String _selectedPosition;

  // Αντιστοίχιση των int σε Strings για το UI
  final List<String> positions = ['Τερματοφύλακας', 'Αμυντικός', 'Μέσος', 'Επιθετικός'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.player.name);
    _surnameController = TextEditingController(text: widget.player.surname);
    _numberController = TextEditingController(text: widget.player.number.toString());

    _goalsController = TextEditingController(text: widget.player.goals.toString());
    _yellowController = TextEditingController(text: widget.player.numOfYellowCards.toString());
    _redController = TextEditingController(text: widget.player.numOfRedCards.toString());

    // Μετατρέπουμε το int της βάσης στο αντίστοιχο String για το Dropdown
    _selectedPosition = positions[widget.player.position.clamp(0, 3)];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _numberController.dispose();
    _goalsController.dispose();
    _yellowController.dispose();
    _redController.dispose();
    super.dispose();
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      // Μετατρέπουμε το String του Dropdown ξανά σε int (0, 1, 2, 3)
      int pos = positions.indexOf(_selectedPosition);

      Player newPlayer = Player(
          _nameController.text.trim(),
          _surnameController.text.trim(),
          pos, // Το σωστό int
          int.parse(_goalsController.text.trim()),
          int.parse(_numberController.text.trim()),
          widget.player.teamName,
          int.parse(_yellowController.text.trim()),
          int.parse(_redController.text.trim()),
          widget.team.nameEnglish,
          widget.player.cardExpiryDate,
          widget.player.appearances,
          widget.player.id); // Κρατάμε το ID!

      // Optimistic update
      setState(() {
        widget.team.updatePlayer(widget.player, newPlayer);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(greek ? 'Οι αλλαγές αποθηκεύτηκαν!' : 'Saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, newPlayer);
    }
  }

  @override
  Widget build(BuildContext context) {
    logScreenViewSta(screenName: 'Edit player', screenClass: 'Edit player page');

    bool isDark = darkModeNotifier.value;
    Color bgColor = isDark ? const Color(0xFF121212) : Colors.grey[100]!;
    Color cardColor = isDark ? Colors.grey[850]! : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          greek ? 'Επεξεργασία Παίκτη' : 'Edit Player',
          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: isDark ? Colors.grey[900] : const Color.fromARGB(250, 46, 90, 136),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.redAccent),
            tooltip: greek ? "Διαγραφή" : "Delete",
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: cardColor,
                  title: Text(
                    greek ? 'Διαγραφή παίκτη' : 'Delete Player',
                    style: TextStyle(color: isDark ? Colors.white : Colors.black),
                  ),
                  content: Text(
                    greek ? 'Είσαι σίγουρος ότι θέλεις να διαγράψεις τον παίκτη;' : 'Are you sure you want to delete this player?',
                    style: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text(greek ? 'Ακύρωση' : 'Cancel', style: const TextStyle(color: Colors.grey)),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: () => Navigator.of(context).pop(true),
                      child: Text(greek ? 'Διαγραφή' : 'Delete', style: const TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                widget.team.deletePlayer(widget.player);
                Navigator.pop(context, true);
              }
            },
          ),
        ],
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
                greek ? "Βασικά Στοιχεία" : "Basic Info",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
              ),
              const SizedBox(height: 10),

              _buildModernTextField(controller: _nameController, label: greek ? 'Όνομα' : 'Name', icon: Icons.person, isDark: isDark, cardColor: cardColor),
              const SizedBox(height: 12),

              _buildModernTextField(controller: _surnameController, label: greek ? 'Επώνυμο' : 'Surname', icon: Icons.person_outline, isDark: isDark, cardColor: cardColor),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: _buildModernTextField(controller: _numberController, label: greek ? 'Νούμερο' : 'Number', icon: Icons.numbers, isNumber: true, isDark: isDark, cardColor: cardColor),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedPosition,
                      dropdownColor: cardColor,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 16),
                      decoration: InputDecoration(
                        labelText: greek ? 'Θέση' : 'Position',
                        labelStyle: TextStyle(color: Colors.grey[600], fontSize: 13),
                        filled: true,
                        fillColor: cardColor,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
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

              const SizedBox(height: 30),
              Text(
                greek ? "Στατιστικά" : "Stats",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
              ),
              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                      child: _buildModernTextField(
                        controller: _goalsController,
                        label: greek ? 'Γκολ' : 'Goals',
                        icon: Icons.sports_soccer,
                        isNumber: true,
                        isDark: isDark,
                        cardColor: cardColor,

                      )
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                      child: _buildModernTextField(
                          controller: _yellowController,
                          label: greek ? 'Κίτρινες' : 'Yellow cards',
                          icon: Icons.style,
                          isNumber: true,
                          isDark: isDark,
                          cardColor: cardColor,
                          iconColor: Colors.amber
                      )
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                      child: _buildModernTextField(
                          controller: _redController,
                          label: greek ? 'Κόκκινες' : 'Red Cards',
                          icon: Icons.style,
                          isNumber: true,
                          isDark: isDark,
                          cardColor: cardColor,
                          iconColor: Colors.redAccent
                      )
                  ),
                ],
              ),

              const SizedBox(height: 40),

              SizedBox(
                height: 50,
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                  ),
                  onPressed: _saveForm,
                  child: Text(
                    greek ? 'ΑΠΟΘΗΚΕΥΣΗ' : 'SAVE',
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

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDark,
    required Color cardColor,
    bool isNumber = false,
    Color? iconColor,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,

      inputFormatters: isNumber ? [FilteringTextInputFormatter.digitsOnly] : null,

      style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: isDark ? Colors.grey[200] : Colors.grey[800], fontSize: 14),
        prefixIcon: Icon(icon, color: iconColor ?? (isDark ? Colors.blue[300] : Colors.blue[400])),
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
          if (number == null) return greek ? 'Λάθος' : 'Error';
          if (number < 0 || number > 99) {
            return greek ? '0-99' : '0-99';
          }
        }
        return null;
      },
    );
  }


}