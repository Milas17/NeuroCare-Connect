import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/webinar.dart';

abstract class AcademyRepository {
  Future<List<Webinar>> webinars();
}

class AssetAcademyRepository implements AcademyRepository {
  @override
  Future<List<Webinar>> webinars() async {
    final s = await rootBundle.loadString('assets/data/webinars.json');
    final List data = jsonDecode(s);
    return data.map((e) => Webinar(
      id: e['id'], title: e['title'], date: DateTime.parse(e['date']),
      speaker: e['speaker'], url: e['url']
    )).toList();
  }
}
