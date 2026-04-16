import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:untitled1/Data_Classes/MatchDetails.dart';
import 'package:untitled1/Firebase_Handle/TeamsHandle.dart';

import '../Data_Classes/Team.dart';
import '../Firebase_Handle/firebase_screen_stats_helper.dart';
import '../globals.dart';
import '../main.dart';

class MatchEditPage extends StatefulWidget {
  final MatchDetails match;

  const MatchEditPage({super.key, required this.match});

  @override
  State<MatchEditPage> createState() => _MatchEditPageState();
}

class _MatchEditPageState extends State<MatchEditPage> {
  final _formKey = GlobalKey<FormState>();

  Team? homeTeam;
  Team? awayTeam;
  late int day;
  late int month;
  late int year;
  late bool isGroupPhase;
  late int game;
  TimeOfDay? matchTime;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Προ-συμπληρώνουμε τα πεδία με τα υπάρχοντα δεδομένα του αγώνα
    homeTeam = widget.match.homeTeam;
    awayTeam = widget.match.awayTeam;
    day = widget.match.day;
    month = widget.match.month;
    year = widget.match.year;
    isGroupPhase = widget.match.isGroupPhase;
    game = widget.match.game;

    int hour = widget.match.time ~/ 100;
    int minute = widget.match.time % 100;
    matchTime = TimeOfDay(hour: hour, minute: minute);
  }

  @override
  Widget build(BuildContext context) {
    logScreenViewSta(screenName: 'Match edit page', screenClass: 'Match edit page');

    bool isDark = darkModeNotifier.value;
    Color bgColor = isDark ? const Color(0xFF121212) : Colors.grey[100]!;
    Color cardColor = isDark ? Colors.grey[850]! : Colors.white;
    Color textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          greek ? "Επεξεργασία Αγώνα" : "Edit Match",
          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: isDark ? Colors.grey[900] : const Color.fromARGB(250, 46, 90, 136),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
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
                      Icon(Icons.access_time, color: Colors.orange[400]), // Πορτοκαλί για Edit
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
                      initialValue: day.toString(),
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
                      initialValue: month.toString(),
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
                      initialValue: year.toString(),
                      isDark: isDark,
                      cardColor: cardColor,
                      validator: (value) {
                        if (value == null || value.isEmpty) return greek ? 'Κενό' : 'Empty';
                        int? v = int.tryParse(value);
                        int currentYear = DateTime.now().year;
                        // Επιτρέπουμε και την προηγούμενη χρονιά σε περίπτωση που κάνει edit παλιό ματς
                        if (v == null || v < currentYear - 1 || v > currentYear + 1) return 'Λάθος';
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
                  activeColor: Colors.orange[700], // Πορτοκαλί για το edit theme
                  value: isGroupPhase,
                  onChanged: (value) => setState(() => isGroupPhase = value),
                ),
              ),
              const SizedBox(height: 16),

              // --- ΑΓΩΝΙΣΤΙΚΗ / ΦΑΣΗ ---
              if (!isGroupPhase)
                _buildModernTextField(
                  label: greek ? 'Φάση play-off (πχ 16, 8, 4, 2)' : "Play-off stage (16, 8, 4, 2)",
                  initialValue: game.toString(),
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
                    backgroundColor: Colors.orange[700], // Πορτοκαλί για να ξεχωρίζει ως "Edit"
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                  ),
                  onPressed: _onSavePressed,
                  child: Text(
                    greek ? 'ΑΠΟΘΗΚΕΥΣΗ ΑΛΛΑΓΩΝ' : 'SAVE CHANGES',
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

  // --- LOGIC ΓΙΑ ΤΟ SAVE ---
  Future<void> _onSavePressed() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState?.save();

      if (homeTeam == null || awayTeam == null) {
        _showError(greek ? "Παρακαλώ επιλέξτε και τις δύο ομάδες!" : "Please select both teams!");
        return;
      }

      if (homeTeam == awayTeam) {
        _showError(greek ? "Οι ομάδες πρέπει να είναι διαφορετικές!" : "Teams must be different!");
        return;
      }

      if (matchTime == null) {
        _showError(greek ? "Παρακαλώ επιλέξτε ώρα!" : "Please select time!");
        return;
      }

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      DateTime matchDate = DateTime(year, month, day);

      if (matchDate.isBefore(today)) {
        _showError(greek ? "Η ημερομηνία δεν μπορεί να είναι παλαιότερη από σήμερα" : "Cannot use past date!");
        return;
      }

      if (!widget.match.hasMatchStarted) {
        if (globalUser.controlTheseTeamsFootball(widget.match.homeTeam.name, widget.match.awayTeam.name) || globalUser.isUpperAdmin) {

          setState(() => _isLoading = true);

          try {
            int formattedTime = matchTime!.hour * 100 + matchTime!.minute;

            // 1. Διαγραφή του παλιού αγώνα
            await TeamsHandle().deleteMatch(widget.match);

            // 2. Προσθήκη του νέου (ανανεωμένου) αγώνα
            await TeamsHandle().addMatch(
              homeTeam!,
              awayTeam!,
              day,
              month,
              year,
              isGroupPhase ? 0 : game, // Αν είναι όμιλος, ας το κάνει 0 όπως στο παλιό ή κράτα το
              false,
              isGroupPhase,
              formattedTime,
              "upcoming",
              0,
              0,
            );

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(greek ? "Ο αγώνας ενημερώθηκε επιτυχώς! ✅" : "Match updated successfully! ✅"),
                backgroundColor: Colors.green,
              ));

              WidgetsBinding.instance.addPostFrameCallback((_) {
                navigatorKey.currentState?.pushReplacementNamed('/home');
              });
            }
          } catch (e) {
            _showError("Σφάλμα: $e");
          } finally {
            if (mounted) setState(() => _isLoading = false);
          }
        } else {
          _showError(greek ? "Δεν έχετε δικαίωμα επεξεργασίας!" : "You must control at least one team!");
        }
      } else {
        _showError(greek ? "Ο αγώνας έχει ήδη ξεκινήσει!" : "Match has already started!");
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
          prefixIcon: Icon(icon, color: Colors.orange[400]), // Πορτοκαλί πινελιά
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
    String? initialValue,
    IconData? icon,
    required String? Function(String?) validator,
    required void Function(String?) onSaved,
  }) {
    return TextFormField(
      initialValue: initialValue,
      keyboardType: TextInputType.number,
      style: TextStyle(color: isDark ? Colors.white : Colors.black),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey, fontSize: 13),
        prefixIcon: icon != null ? Icon(icon, color: Colors.orange[400]) : null, // Πορτοκαλί πινελιά
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