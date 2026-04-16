import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';

import '../Data_Classes/Team.dart';
import '../Firebase_Handle/TeamsHandle.dart';
import '../Firebase_Handle/firebase_screen_stats_helper.dart';
import '../globals.dart';

class AddMatchScreen extends StatefulWidget {
  @override
  _AddMatchScreenState createState() => _AddMatchScreenState();
}

class _AddMatchScreenState extends State<AddMatchScreen> {
  final _formKey = GlobalKey<FormState>();

  Team? homeTeam;
  Team? awayTeam;
  int day = 0;
  int month = 0;
  int year = 0;
  bool isGroupPhase = true;
  int game = 0;

  TimeOfDay? matchTime;

  @override
  Widget build(BuildContext context) {
    logScreenViewSta(screenName: 'Add Match Page', screenClass: 'Add Match Page');

    bool isDark = darkModeNotifier.value;
    Color bgColor = isDark ? const Color(0xFF121212) : Colors.grey[100]!;
    Color cardColor = isDark ? Colors.grey[850]! : Colors.white;
    Color textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          greek ? "Προσθήκη Ματς" : "Add Match",
          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: isDark ? Colors.grey[900] : const Color.fromARGB(250, 46, 90, 136),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            physics: const BouncingScrollPhysics(),
            children: [
              // --- ΓΗΠΕΔΟΥΧΟΣ ---
              _buildDropdownTeam(
                label: greek ? 'Γηπεδούχος Ομάδα' : 'Home Team',
                icon: Icons.home,
                selectedTeam: homeTeam,
                isDark: isDark,
                cardColor: cardColor,
                onChanged: (Team? value) => setState(() => homeTeam = value),
              ),
              const SizedBox(height: 16),

              // --- ΦΙΛΟΞΕΝΟΥΜΕΝΗ ---
              _buildDropdownTeam(
                label: greek ? 'Φιλοξενούμενη Ομάδα' : 'Away Team',
                icon: Icons.flight_takeoff,
                selectedTeam: awayTeam,
                isDark: isDark,
                cardColor: cardColor,
                onChanged: (Team? value) => setState(() => awayTeam = value),
              ),
              const SizedBox(height: 24),

              // --- ΕΠΙΛΟΓΗ ΩΡΑΣ ---
              InkWell(
                onTap: () async {
                  final TimeOfDay? picked = await showTimePicker(
                    context: context,
                    initialTime: matchTime ?? const TimeOfDay(hour: 20, minute: 15),
                  );
                  if (picked != null) setState(() => matchTime = picked);
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.access_time, color: Colors.blue[400]),
                      const SizedBox(width: 12),
                      Text(
                        matchTime != null ? matchTime!.format(context) : (greek ? 'Επιλέξτε Ώρα' : 'Select Time'),
                        style: TextStyle(color: textColor, fontSize: 16),
                      ),
                      const Spacer(),
                      const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // --- ΗΜΕΡΟΜΗΝΙΑ (Ημέρα / Μήνας / Έτος) ---
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildModernTextField(
                      label: greek ? 'Ημέρα' : 'Day',
                      isDark: isDark,
                      cardColor: cardColor,
                      validator: (value) {
                        if (value == null || value.isEmpty) return greek ? 'Κενό' : 'Empty';
                        int? v = int.tryParse(value);
                        if (v == null || v < 1 || v > 31) return '1-31';
                        return null;
                      },
                      onSaved: (value) => day = int.parse(value!),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildModernTextField(
                      label: greek ? 'Μήνας' : 'Month',
                      isDark: isDark,
                      cardColor: cardColor,
                      validator: (value) {
                        if (value == null || value.isEmpty) return greek ? 'Κενό' : 'Empty';
                        int? v = int.tryParse(value);
                        if (v == null || v < 1 || v > 12) return '1-12';
                        return null;
                      },
                      onSaved: (value) => month = int.parse(value!),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildModernTextField(
                      label: greek ? 'Έτος' : 'Year',
                      isDark: isDark,
                      cardColor: cardColor,
                      validator: (value) {
                        if (value == null || value.isEmpty) return greek ? 'Κενό' : 'Empty';
                        int? v = int.tryParse(value);
                        int currentYear = DateTime.now().year;
                        if (v == null || v < currentYear || v > currentYear + 1) return 'Λάθος';
                        return null;
                      },
                      onSaved: (value) => year = int.parse(value!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // --- ΦΑΣΗ ΟΜΙΛΩΝ (Switch) ---
              Container(
                decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(12)),
                child: SwitchListTile(
                  title: Text(greek ? "Φάση Ομίλων;" : "Group Phase?", style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
                  activeColor: Colors.blue,
                  value: isGroupPhase,
                  onChanged: (value) => setState(() => isGroupPhase = value),
                ),
              ),
              const SizedBox(height: 16),

              // --- ΑΓΩΝΙΣΤΙΚΗ / ΦΑΣΗ ---
              if (!isGroupPhase)
                _buildModernTextField(
                  label: greek ? 'Φάση play-off (πχ 16, 8, 4, 2)' : "Play-off stage (16, 8, 4, 2)",
                  isDark: isDark,
                  cardColor: cardColor,
                  icon: Icons.emoji_events,
                  validator: (value) {
                    if (value == null || value.isEmpty) return greek ? 'Παρακαλώ εισάγετε αριθμό' : 'Required';
                    if (int.tryParse(value) == null) return greek ? 'Μόνο αριθμοί' : 'Numbers only';
                    return null;
                  },
                  onSaved: (value) => game = int.parse(value!),
                ),

              const SizedBox(height: 32),

              // --- ΚΟΥΜΠΙ ΑΠΟΘΗΚΕΥΣΗΣ ---
              SizedBox(
                height: 50,
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                  ),
                  onPressed: _onSavePressed,
                  child: Text(
                    greek ? 'ΑΠΟΘΗΚΕΥΣΗ ΜΑΤΣ' : 'SAVE MATCH',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // --- LOGIC ΓΙΑ ΤΟ SAVE (Καθαρισμένο από την UI μέθοδο) ---
  void _onSavePressed() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState?.save();

      if (homeTeam == null || awayTeam == null) {
        _showError(greek ? "Παρακαλώ επιλέξτε και τις δύο ομάδες!" : "Please select both teams!");
        return;
      }

      if (matchTime == null) {
        _showError(greek ? "Παρακαλώ επιλέξτε ώρα!" : "Please select time!");
        return;
      }

      DateTime currentDate = DateTime.now();
      final TimeOfDay time = matchTime ?? const TimeOfDay(hour: 20, minute: 15);
      DateTime matchDate = DateTime(year, month, day, time.hour, time.minute);

      if (matchDate.isBefore(currentDate)) {
        _showError(greek ? "Δεν γίνεται να βάλεις παρελθοντική ημερομηνία!" : "Cannot use past date!");
        return;
      }

      if (globalUser.controlTheseTeamsFootball(homeTeam!.name, awayTeam!.name) || globalUser.isUpperAdmin) {
        TeamsHandle().addMatch(
            homeTeam!, awayTeam!, day, month, year, game, false, isGroupPhase,
            time.hour * 100 + time.minute, "upcoming", 0, 0);

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(greek ? "Το ματς προστέθηκε επιτυχώς!" : "Match added successfully!"),
          backgroundColor: Colors.green,
        ));

        WidgetsBinding.instance.addPostFrameCallback((_) {
          navigatorKey.currentState?.pushReplacementNamed('/home');
        });
        Navigator.pop(context, true);
      } else {
        _showError(greek ? "Πρέπει να ελέγχεις τουλάχιστον τη μία ομάδα!" : "You must control at least one team!");
      }
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  // --- WIDGETS ΓΙΑ ΤΟ UI ---
  Widget _buildDropdownTeam({
    required String label,
    required IconData icon,
    required Team? selectedTeam,
    required bool isDark,
    required Color cardColor,
    required Function(Team?) onChanged,
  }) {
    return DropdownSearch<Team>(
      popupProps: PopupProps.menu(
        showSearchBox: true,
        menuProps: MenuProps(backgroundColor: cardColor, borderRadius: BorderRadius.circular(12)),
        searchFieldProps: TextFieldProps(
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
          decoration: InputDecoration(
            hintText: greek ? 'Αναζήτηση...' : 'Search...',
            hintStyle: const TextStyle(color: Colors.grey),
            prefixIcon: const Icon(Icons.search, color: Colors.grey),
          ),
        ),
        itemBuilder: (context, Team item, isSelected) {
          return ListTile(
            title: Text(item.name, style: TextStyle(color: isDark ? Colors.white : Colors.grey[900])),
          );
        },
      ),
      itemAsString: (Team team) => team.name,
      dropdownDecoratorProps: DropDownDecoratorProps(
        dropdownSearchDecoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey),
          prefixIcon: Icon(icon, color: Colors.blue[400]),
          filled: true,
          fillColor: cardColor,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
      ),
      selectedItem: selectedTeam,
      items: teams,
      onChanged: onChanged,
      dropdownBuilder: (context, selectedItem) {
        return Text(
          selectedItem != null ? selectedItem.name : (greek ? 'Επιλέξτε Ομάδα' : 'Select Team'),
          style: TextStyle(color: isDark ? Colors.white : Colors.grey[900]),
        );
      },
    );
  }

  Widget _buildModernTextField({
    required String label,
    required bool isDark,
    required Color cardColor,
    IconData? icon,
    required String? Function(String?) validator,
    required void Function(String?) onSaved,
  }) {
    return TextFormField(
      keyboardType: TextInputType.number,
      style: TextStyle(color: isDark ? Colors.white : Colors.black),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey, fontSize: 13),
        prefixIcon: icon != null ? Icon(icon, color: Colors.blue[400]) : null,
        filled: true,
        fillColor: cardColor,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        errorStyle: const TextStyle(color: Colors.redAccent, fontSize: 10),
      ),
      validator: validator,
      onSaved: onSaved,
    );
  }
}