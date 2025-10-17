import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/webinar.dart';
import '../../core/repositories/academy_repository.dart';
import 'package:url_launcher/url_launcher.dart';

final academyRepoProvider = Provider<AcademyRepository>((ref) => AssetAcademyRepository());

class AcademyScreen extends ConsumerWidget {
  const AcademyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Academy')),
      body: FutureBuilder<List<Webinar>>(
        future: ref.read(academyRepoProvider).webinars(),
        builder: (ctx, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final list = snap.data!;
          if (list.isEmpty) return const Center(child: Text('Aucun webinaire'));
          return ListView.separated(
            itemCount: list.length,
            separatorBuilder: (_, __) => const Divider(height: 0),
            itemBuilder: (ctx, i) {
              final w = list[i];
              return ListTile(
                leading: const Icon(Icons.school),
                title: Text(w.title),
                subtitle: Text('${w.date.toLocal()} — ${w.speaker}'),
                trailing: TextButton(
                  onPressed: () => launchUrl(Uri.parse(w.url), mode: LaunchMode.externalApplication),
                  child: const Text('Détails'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
