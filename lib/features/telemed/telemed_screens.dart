import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/repositories/telemed_repository.dart';
import '../../core/models/appointment.dart';
import '../../core/services/video_service.dart';

final telemedRepoProvider = Provider<TelemedRepository>((ref) => InMemoryTelemedRepository());
final videoServiceProvider = Provider((ref) => VideoService());

class TelemedHome extends ConsumerWidget {
  const TelemedHome({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Téléconsultation'),
          bottom: const TabBar(tabs: [
            Tab(text: 'Médecins'),
            Tab(text: 'Prendre RDV'),
            Tab(text: 'Mes RDV'),
          ]),
        ),
        body: const TabBarView(
          children: [DoctorsTab(), BookTab(), MyAppointmentsTab()],
        ),
      ),
    );
  }
}

class DoctorsTab extends ConsumerWidget {
  const DoctorsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder(
      future: ref.read(telemedRepoProvider).listDoctors(),
      builder: (context, snap) {
        if (!snap.hasData) return const Center(child: CircularProgressIndicator());
        final doctors = snap.data!;
        return ListView.builder(
          itemCount: doctors.length,
          itemBuilder: (_, i) => ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: Text(doctors[i]),
            trailing: TextButton(
              child: const Text('Appel vidéo'),
              onPressed: () => ref.read(videoServiceProvider).launchMeeting(doctors[i]),
            ),
          ),
        );
      },
    );
  }
}

class BookTab extends ConsumerStatefulWidget {
  const BookTab({super.key});
  @override
  ConsumerState<BookTab> createState() => _BookTabState();
}

class _BookTabState extends ConsumerState<BookTab> {
  String? _doctor;
  final _reasonCtrl = TextEditingController();
  DateTime? _date;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          FutureBuilder(
            future: ref.read(telemedRepoProvider).listDoctors(),
            builder: (ctx, snap) {
              final items = snap.data ?? [];
              return DropdownButtonFormField<String>(
                value: _doctor,
                items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (v) => setState(() => _doctor = v),
                decoration: const InputDecoration(labelText: 'Médecin'),
              );
            },
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _reasonCtrl,
            decoration: const InputDecoration(labelText: 'Motif'),
          ),
          const SizedBox(height: 12),
          ListTile(
            title: Text(_date == null ? 'Choisir une date' : _date.toString()),
            trailing: const Icon(Icons.calendar_month),
            onTap: () async {
              final now = DateTime.now();
              final d = await showDatePicker(
                context: context,
                firstDate: now,
                lastDate: now.add(const Duration(days: 365)),
                initialDate: now,
              );
              if (d == null) return;
              final t = await showTimePicker(context: context, initialTime: TimeOfDay.now());
              if (t == null) return;
              setState(() => _date = DateTime(d.year, d.month, d.day, t.hour, t.minute));
            },
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              if (_doctor == null || _date == null || _reasonCtrl.text.isEmpty) return;
              await ref.read(telemedRepoProvider).book(Appointment(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                doctorName: _doctor!,
                dateTime: _date!,
                reason: _reasonCtrl.text,
              ));
              if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('RDV enregistré')));
            },
            child: const Text('Valider'),
          )
        ],
      ),
    );
  }
}

class MyAppointmentsTab extends ConsumerWidget {
  const MyAppointmentsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder(
      future: ref.read(telemedRepoProvider).myAppointments(),
      builder: (ctx, snap) {
        if (!snap.hasData) return const Center(child: Text('Aucun RDV'));
        final list = snap.data!;
        if (list.isEmpty) return const Center(child: Text('Aucun RDV'));
        return ListView.separated(
          itemCount: list.length,
          separatorBuilder: (_, __) => const Divider(height: 0),
          itemBuilder: (ctx, i) {
            final a = list[i];
            return ListTile(
              leading: const Icon(Icons.event),
              title: Text('${a.doctorName} — ${a.reason}'),
              subtitle: Text(a.dateTime.toString()),
            );
          },
        );
      },
    );
  }
}
