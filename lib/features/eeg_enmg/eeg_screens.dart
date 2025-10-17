import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/eeg_file.dart';
import '../../core/repositories/eeg_repository.dart';

final eegRepoProvider = Provider<EegRepository>((ref) => InMemoryEegRepository());

class EegHome extends ConsumerStatefulWidget {
  const EegHome({super.key});
  @override
  ConsumerState<EegHome> createState() => _EegHomeState();
}

class _EegHomeState extends ConsumerState<EegHome> {
  final _note = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('EEG / ENMG')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(controller: _note, decoration: const InputDecoration(labelText: 'Note')),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () async {
              final res = await FilePicker.platform.pickFiles(
                allowedExtensions: ['edf', 'pdf', 'zip'],
                type: FileType.custom,
              );
              if (res == null) return;
              final name = res.files.first.name;
              await ref.read(eegRepoProvider).upload(EegFile(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                filename: name,
                uploadedAt: DateTime.now(),
                note: _note.text,
              ));
              if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Fichier $name téléversé')));
              setState(() {});
            },
            child: const Text('Téléverser un fichier'),
          ),
          const Divider(height: 32),
          FutureBuilder(
            future: ref.read(eegRepoProvider).listAll(),
            builder: (ctx, snap) {
              final list = snap.data ?? [];
              if (list.isEmpty) return const Text('Aucun fichier');
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: list.map((e) => ListTile(
                  leading: const Icon(Icons.insert_drive_file),
                  title: Text(e.filename),
                  subtitle: Text('${e.uploadedAt} — ${e.note}'),
                )).toList(),
              );
            },
          )
        ],
      ),
    );
  }
}
