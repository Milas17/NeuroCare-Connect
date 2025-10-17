class HomeCareRequest {
  final String id;
  final String patientName;
  final String address;
  final String need;
  final DateTime date;
  HomeCareRequest({required this.id, required this.patientName, required this.address, required this.need, required this.date});
}

abstract class HomeCareRepository {
  Future<void> create(HomeCareRequest req);
  Future<List<HomeCareRequest>> listAll();
}

class InMemoryHomeCareRepository implements HomeCareRepository {
  final List<HomeCareRequest> _items = [];
  @override
  Future<void> create(HomeCareRequest req) async => _items.add(req);

  @override
  Future<List<HomeCareRequest>> listAll() async => List.unmodifiable(_items);
}
