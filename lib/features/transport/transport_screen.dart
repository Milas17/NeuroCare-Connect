import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/transport_request.dart';
import '../../core/repositories/transport_repository.dart';

final transportRepoProvider = Provider<TransportRepository>((ref) => InMemoryTransportRepository());

class TransportScreen extends ConsumerStatefulWidget {
  const TransportScreen({super.key});
  @override
  ConsumerState<TransportScreen> createState() => _TransportScreenState();
}

class _TransportScreenState extends ConsumerState<TransportScreen> {
  final _name = TextEditingController();
  final _pickup = TextEditingController();
  final _drop = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transport (VSL)')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(controller: _name, decoration: const InputDecoration(labelText: 'Nom du patient')),
          const SizedBox(height: 8),
          TextField(controller: _pickup, decoration: const InputDecoration(labelText: 'Départ')),
          const SizedBox(height: 8),
          TextField(controller: _drop, decoration: const InputDecoration(labelText: 'Destination')),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () async {
              await ref.read(transportRepoProvider).request(TransportRequest(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                patientName: _name.text, pickup: _pickup.text, dropoff: _drop.text,
              ));
              if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Transport demandé')));
              setState(() {});
            },
            child: const Text('Demander un transport'),
          ),
          const Divider(height: 32),
          FutureBuilder(
            future: ref.read(transportRepoProvider).myRides(),
            builder: (ctx, snap) {
              final list = snap.data ?? [];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Mes transports', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...list.map((e) => ListTile(
                    leading: const Icon(Icons.local_taxi),
                    title: Text('${e.pickup} → ${e.dropoff}'),
                    subtitle: Text('Statut: ${e.status.name} — ${e.patientName}'),
                    trailing: PopupMenuButton<RideStatus>(
                      onSelected: (s) async {
                        await ref.read(transportRepoProvider).updateStatus(e.id, s);
                        setState(() {});
                      },
                      itemBuilder: (ctx) => RideStatus.values.map((s) => PopupMenuItem(
                        value: s, child: Text(s.name)
                      )).toList(),
                    ),
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
