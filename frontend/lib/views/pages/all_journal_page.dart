import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AllJournalPage extends StatelessWidget {
  const AllJournalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Journals"),
        backgroundColor: Colors.black,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('journals').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading journals.'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text('No journals yet.'));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final journal = docs[index];
              final title = journal['title'] ?? 'Untitled';
              final content = journal['content'] ?? '';

              return ListTile(
                title: Text(title),
                subtitle:
                    Text(content, maxLines: 2, overflow: TextOverflow.ellipsis),
              );
            },
          );
        },
      ),
    );
  }
}
