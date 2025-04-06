import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class JournalListPage extends StatelessWidget {
  final String location;

  const JournalListPage({super.key, required this.location});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Dark background
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: Text(
          'Journals in $location',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('journalEntries')
            .where('location', isEqualTo: location)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: Colors.amber));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No journals found at this location.',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final journals = snapshot.data!.docs;

          return ListView.builder(
            itemCount: journals.length,
            itemBuilder: (context, index) {
              final journal = journals[index];
              final title = journal['title'] ?? 'Untitled';
              final description = journal['description'] ?? 'No description';
              final finalNotes = journal['finalNotes'] ?? 'No notes';
              final date = journal['date'] ?? 'No date';
              final rating = journal['rating']?.toString() ?? 'N/A';
              final mediaPaths = List<String>.from(journal['mediaPaths'] ?? []);

              Widget? imageWidget;

              if (mediaPaths.isNotEmpty) {
                final path = mediaPaths[0];
                if (path.startsWith('http')) {
                  imageWidget = ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(path,
                        height: 200, width: double.infinity, fit: BoxFit.cover),
                  );
                } else if (File(path).existsSync()) {
                  imageWidget = ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(File(path),
                        height: 200, width: double.infinity, fit: BoxFit.cover),
                  );
                } else {
                  imageWidget = const Text(
                    '🖼️ Image not available',
                    style: TextStyle(color: Colors.white),
                  );
                }
              }

              return Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withOpacity(0.5),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: Colors.amber,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (imageWidget != null) ...[
                      imageWidget,
                      const SizedBox(height: 16),
                    ],
                    _flashCardField("📅 Date", date),
                    _flashCardField("⭐ Rating", rating),
                    _flashCardField("📖 Description", description),
                    _flashCardField("🗒️ Final Notes", finalNotes),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _flashCardField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.amber,
                fontSize: 15,
              ),
            ),
            TextSpan(
              text: value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
