import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dailydevotion/l10n/app_localizations.dart';
import 'package:dailydevotion/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class VideoSettingsPage extends StatefulWidget {
  final AppLocalizations tr;
  const VideoSettingsPage({super.key, required this.tr});

  @override
  State<VideoSettingsPage> createState() => _VideoSettingsPageState();
}

class _VideoSettingsPageState extends State<VideoSettingsPage> {
  DateTime? _selectedDate;
  final TextEditingController _limitController = TextEditingController();
  bool _isSaving = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  /// Load saved settings from Firestore
  Future<void> _loadSettings() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection("app_settings")
          .doc("video_rules")
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          // if (data["startDate"] != null) {
          //   // ✅ Handle Timestamp
          //   _selectedDate = (data["startDate"] as Timestamp).toDate();
          // }
          if (data["dailyVideoLimit"] != null) {
            _limitController.text = data["dailyVideoLimit"].toString();
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${widget.tr.errorLoadingSettings}: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Pick a start date
  // Future<void> _pickDate() async {
  //   final DateTime now = DateTime.now();
  //   final DateTime? picked = await showDatePicker(
  //     context: context,
  //     initialDate: _selectedDate ?? now,
  //     firstDate: now,
  //     lastDate: DateTime(now.year + 5),
  //   );

  //   if (picked != null) {
  //     setState(() {
  //       _selectedDate = picked;
  //     });
  //   }
  // }

  /// Save settings to Firestore
  Future<void> _saveSettings() async {
    // if (_selectedDate == null || _limitController.text.isEmpty) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text("Please select a date and limit")),
    //   );
    //   return;
    // }

    final int? dailyLimit = int.tryParse(_limitController.text);
    if (dailyLimit == null || dailyLimit <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(widget.tr.enterValidNumber)));
      return;
    }

    setState(() => _isSaving = true);

    try {
      await FirebaseFirestore.instance
          .collection("app_settings")
          .doc("video_rules")
          .set({
            "startDate": Timestamp.fromDate(
              _selectedDate!,
            ), // ✅ Save as Timestamp
            "dailyVideoLimit": dailyLimit,
          }, SetOptions(merge: true));

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("${widget.tr.settingsSaved}!")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${widget.tr.errorSavingSettings}: $e")),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: CustomAppBar(title: widget.tr.devotionsManagement),
      body: _isLoading
          ? const Center(child: SizedBox())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Date Picker Card
                  // Card(
                  //   shape: RoundedRectangleBorder(
                  //     borderRadius: BorderRadius.circular(12),
                  //   ),
                  //   elevation: 3,
                  //   child: ListTile(
                  //     leading: const Icon(
                  //       Icons.calendar_today,
                  //       color: Colors.blue,
                  //     ),
                  //     title: Text(
                  //       _selectedDate == null
                  //           ? "No start date selected"
                  //           : DateFormat.yMMMMd().format(_selectedDate!),
                  //       style: const TextStyle(fontSize: 16),
                  //     ),
                  //     trailing: TextButton(
                  //       onPressed: _pickDate,
                  //       child: const Text("Pick Date"),
                  //     ),
                  //   ),
                  // ),
                  const SizedBox(height: 20),

                  // Limit Input Card
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: TextField(
                        controller: _limitController,
                        decoration: InputDecoration(
                          labelText: widget.tr.dailyDevotionsLimit,
                          prefixIcon: const Icon(Icons.video_library),
                          border: const OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Save Button
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF130E6A),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                      ),
                      onPressed: _isSaving ? null : _saveSettings,
                      child: _isSaving
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              widget.tr.save,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
