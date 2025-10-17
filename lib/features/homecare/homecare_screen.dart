import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/repositories/homecare_repository.dart';

final homeCareRepoProvider = Provider<HomeCareRepository>((ref) => InMemoryHomeCareRepository());

class HomeCareScreen extends ConsumerStatefulWidget {
  const HomeCareScreen({super.key});
  @override
  ConsumerState<HomeCareScreen> createState() => _HomeCareScreenState();
}

class _HomeCareScreenState extends ConsumerState<HomeCareScreen> {
  final _name = TextEditingController();
  final _address = TextEditingController();
  final _need = TextEditingController();
  DateTime _date = DateTime.now().add(const Duration(days: 1));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Soins à domicile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(controller: _name, decoration: const InputDecoration(labelText: 'Nom du patient')),
          const SizedBox(height: 8),
          TextField(controller: _address, decoration: const InputDecoration(labelText: 'Adresse')),
          const SizedBox(height: 8),
          TextField(controller: _need, decoration: const InputDecoration(labelText: 'Besoin / Spécificités')),
          const SizedBox(height: 8),
          ListTile(
            title: Text('Date: ${_date.toString()}'),
            trailing: const Icon(Icons.calendar_month),
            onTap: () async {
              final now = DateTime.now();
              final d = await showDatePicker(context: context, firstDate: now, lastDate: now.add(const Duration(days: 365)), initialDate: _date);
              if (d != null) setState(() => _date = d);
            },
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              await ref.read(homeCareRepoProvider).create(HomeCareRequest(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                patientName: _name.text,
                address: _address.text,
                need: _need.text,
                date: _date,
              ));
              if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Demande enregistrée')));
              setState(() {});
            },
            child: const Text('Envoyer la demande'),
          ),
          const Divider(height: 32),
          FutureBuilder(
            future: ref.read(homeCareRepoProvider).listAll(),
            builder: (ctx, snap) {
              final list = snap.data ?? [];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Mes demandes', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...list.map((e) => ListTile(
                    leading: const Icon(Icons.home_health),
                    title: Text(e.patientName),
                    subtitle: Text('${e.address} — ${e.date.toString()}\n${e.need}'),
                  ))
                ],
              );
            },
          )
        ],
      ),
    );
  }
}
