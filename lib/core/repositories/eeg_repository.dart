import '../models/eeg_file.dart';

abstract class EegRepository {
  Future<void> upload(EegFile f);
  Future<List<EegFile>> listAll();
}

class InMemoryEegRepository implements EegRepository {
  final List<EegFile> _files = [];

  @override
  Future<List<EegFile>> listAll() async => List.unmodifiable(_files);

  @override
  Future<void> upload(EegFile f) async => _files.add(f);
}
