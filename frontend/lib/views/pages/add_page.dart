import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddPage extends StatefulWidget {
  const AddPage({super.key});

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  final ImagePicker _picker = ImagePicker();
  List<XFile> _mediaFiles = [];

  DateTime? _selectedDate;
  String _formattedDate = '';
  double _rating = 0;

  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _finalNotesController = TextEditingController();
  final TextEditingController _locationController =
      TextEditingController(); // Location controller

  final primaryColor = Colors.black;
  final secondaryColor = Colors.amber;

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _formattedDate = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _pickMedia() async {
    final List<XFile> files = await _picker.pickMultiImage();
    if (files.isNotEmpty) {
      setState(() {
        _mediaFiles.addAll(files);
      });
    }
  }

  Widget _buildMediaPreview() {
    final maxToShow = 7;
    final previewFiles = _mediaFiles.take(maxToShow).toList();
    final remaining = _mediaFiles.length - maxToShow;

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          for (var file in previewFiles)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                File(file.path),
                height: 80,
                width: 80,
                fit: BoxFit.cover,
              ),
            ),
          if (_mediaFiles.length > maxToShow)
            Container(
              width: 80,
              height: 80,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text("+$remaining",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: primaryColor)),
            ),
        ],
      ),
    );
  }

  Future<void> _saveEntryToFirestore() async {
    try {
      await FirebaseFirestore.instance.collection('journalEntries').add({
        'date': _formattedDate,
        'description': _descriptionController.text.trim(),
        'title': _titleController.text.trim(),
        'rating': _rating,
        'finalNotes': _finalNotesController.text.trim(),
        'location': _locationController.text.trim(), // 🔥 Added location
        'mediaPaths': _mediaFiles.map((file) => file.path).toList(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Entry saved to Firestore!")),
      );

      setState(() {
        _formattedDate = '';
        _selectedDate = null;
        _descriptionController.clear();
        _titleController.clear();
        _finalNotesController.clear();
        _locationController.clear(); // 🔥 Clear location input
        _rating = 0;
        _mediaFiles.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving entry: $e")),
      );
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _titleController.dispose();
    _finalNotesController.dispose();
    _locationController.dispose(); // Dispose location controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                "Create Your Entry",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                readOnly: true,
                onTap: () => _pickDate(context),
                decoration: InputDecoration(
                  labelText: "Select Date",
                  hintText: "2025-04-05",
                  border: const OutlineInputBorder(),
                  suffixIcon: const Icon(Icons.calendar_today),
                  fillColor: Colors.white,
                  filled: true,
                ),
                controller: TextEditingController(text: _formattedDate),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: "Location",
                  border: OutlineInputBorder(),
                  fillColor: Colors.white,
                  filled: true,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: "Journal / Description",
                  border: OutlineInputBorder(),
                  fillColor: Colors.white,
                  filled: true,
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: ElevatedButton.icon(
                  onPressed: _pickMedia,
                  icon: Icon(Icons.upload, color: primaryColor),
                  label: Text("Upload Images",
                      style: TextStyle(color: primaryColor)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: secondaryColor,
                  ),
                ),
              ),
              if (_mediaFiles.isNotEmpty) _buildMediaPreview(),
              const SizedBox(height: 12),
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: "Title",
                  border: OutlineInputBorder(),
                  fillColor: Colors.white,
                  filled: true,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text("Rate:",
                      style: TextStyle(fontSize: 16, color: primaryColor)),
                  const SizedBox(width: 12),
                  Row(
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < _rating
                              ? Icons.star
                              : Icons.star_border_outlined,
                          color: secondaryColor,
                        ),
                        onPressed: () {
                          setState(() {
                            _rating = (index + 1).toDouble();
                          });
                        },
                      );
                    }),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _finalNotesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "Final Notes / Review",
                  border: OutlineInputBorder(),
                  fillColor: Colors.white,
                  filled: true,
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text("Save Entry"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: secondaryColor,
                    foregroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _saveEntryToFirestore,
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}
