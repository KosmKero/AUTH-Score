import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../Data_Classes/basketball/basketPlayer.dart';
import '../../Data_Classes/basketball/basketTeam.dart';
import '../../Firebase_Handle/firebase_screen_stats_helper.dart';
import '../../globals.dart';

class BasketballPlayerEditPage extends StatefulWidget {
  final BasketPlayer player;
  final basketTeam team;

  const BasketballPlayerEditPage({super.key, required this.player, required this.team});

  @override
  _BasketballPlayerEditPageState createState() => _BasketballPlayerEditPageState();
}

class _BasketballPlayerEditPageState extends State<BasketballPlayerEditPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _surnameController;
  late TextEditingController _numberController;
  late TextEditingController _pointsController;

  late String _selectedPosition;
  final List<String> positions = ['Γκαρντ', 'Φόργουορντ', 'Σέντερ'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.player.name);
    _surnameController = TextEditingController(text: widget.player.surname);
    _numberController = TextEditingController(text: widget.player.number.toString());
    _pointsController = TextEditingController(text: widget.player.points.toString());

    int posIndex = widget.player.position - 1;
    if (posIndex < 0 || posIndex > 2) posIndex = 0;
    _selectedPosition = positions[posIndex];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _numberController.dispose();
    _pointsController.dispose();
    super.dispose();
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      int pos = positions.indexOf(_selectedPosition) + 1;

      BasketPlayer newPlayer = BasketPlayer(
          _nameController.text.trim(),
          _surnameController.text.trim(),
          pos,
          int.parse(_pointsController.text.trim()),
          int.parse(_numberController.text.trim()),
          widget.player.teamName,
          widget.player.teamNameEnglish,
          widget.player.id // ΚΡΑΤΑΜΕ ΤΟ ΙΔΙΟ ID!
      );

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
    logScreenViewSta(screenName: 'Edit basket player', screenClass: 'Edit basket player page');

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
        backgroundColor: isDark ? Colors.grey[900] : Colors.orange[700],
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 1,
                    child: _buildModernTextField(controller: _numberController, label: greek ? 'Νούμερο' : 'Number', icon: Icons.numbers, isNumber: true, isDark: isDark, cardColor: cardColor),
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

              _buildModernTextField(
                controller: _pointsController,
                label: greek ? 'Πόντοι (Σύνολο)' : 'Total Points',
                icon: Icons.sports_basketball,
                isNumber: true,
                isDark: isDark,
                cardColor: cardColor,
                iconColor: Colors.orange,
              ),

              const SizedBox(height: 40),

              SizedBox(
                height: 50,
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange[600],
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
        prefixIcon: Icon(icon, color: iconColor ?? (isDark ? Colors.orange[300] : Colors.orange[400])),
        filled: true,
        fillColor: cardColor,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.orangeAccent, width: 1.5)),
        errorStyle: const TextStyle(color: Colors.redAccent, fontSize: 10),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) return greek ? 'Υποχρεωτικό' : 'Required';
        if (isNumber) {
          final number = int.tryParse(value);
          if (number == null) return greek ? 'Λάθος' : 'Error';
          if (number < 0 || number > 999) {
            return greek ? '0-999' : '0-999';
          }
        }
        return null;
      },
    );
  }
}