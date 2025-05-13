import 'package:flutter/material.dart';

import '../Data_Classes/Player.dart';
import '../Data_Classes/Team.dart';

class PlayerEditPage extends StatefulWidget {
  final Player player;
  final Team team;
  const PlayerEditPage({
    Key? key,
    required this.player,
    required this.team

  }) : super(key: key);

  @override
  _PlayerEditPageState createState() => _PlayerEditPageState();
}

class _PlayerEditPageState extends State<PlayerEditPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _surnameController;
  late TextEditingController _goalsController;
  late TextEditingController _yellowController;
  late TextEditingController _redController;
  late TextEditingController _positionController;
  //late TextEditingController _ageController;
  late TextEditingController _numberController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.player.name);
    _surnameController = TextEditingController(text: widget.player.surname);
    _goalsController = TextEditingController(text: widget.player.goals.toString());
    _yellowController = TextEditingController(text: widget.player.numOfYellowCards.toString());
    _redController = TextEditingController(text: widget.player.numOfRedCards.toString());
    _positionController = TextEditingController(text: widget.player.position.toString());
    //_ageController = TextEditingController(text: widget.age.toString());
    _numberController = TextEditingController(text: widget.player.number.toString());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _goalsController.dispose();
    _yellowController.dispose();
    _redController.dispose();
    _positionController.dispose();
    //_ageController.dispose();
    _numberController.dispose();
    super.dispose();
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {

      Player newPlayer = Player(_nameController.text, _surnameController.text, int.parse(_positionController.text), int.parse(_goalsController.text), int.parse(_numberController.text), 22, widget.player.teamName, int.parse(_yellowController.text), int.parse(_redController.text),widget.player.teamNameEnglish);

      setState(() {
        widget.team.updatePlayer(widget.player, newPlayer);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Saved successfully')),
      );
      Navigator.pop(context, newPlayer);
    }
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool isNumber = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(labelText: label),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Required';
        if (isNumber && int.tryParse(value) == null) return 'Must be a number';
        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Player'),actions: [IconButton(
        icon: Icon(Icons.delete),
        onPressed: () async {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Διαγραφή παίκτη'),
              content: Text('Είσαι σίγουρος ότι θέλεις να διαγράψεις τον παίκτη;'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text('Ακύρωση'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text('Διαγραφή', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          );

          if (confirm == true) {
            widget.team.deletePlayer(widget.player);
            Navigator.pop(context, true);
          }
        },
      ),],),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField('Name', _nameController),
              _buildTextField('Surname', _surnameController),
              _buildTextField('Goals', _goalsController, isNumber: true),
              _buildTextField('Yellow Cards', _yellowController, isNumber: true),
              _buildTextField('Red Cards', _redController, isNumber: true),
              _buildTextField('Position', _positionController, isNumber: true),
              //_buildTextField('Age', _ageController, isNumber: true),
              _buildTextField('Number', _numberController, isNumber: true),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveForm,
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
