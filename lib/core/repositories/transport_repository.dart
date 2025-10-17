import '../models/transport_request.dart';

abstract class TransportRepository {
  Future<void> request(TransportRequest r);
  Future<List<TransportRequest>> myRides();
  Future<void> updateStatus(String id, RideStatus status);
}

class InMemoryTransportRepository implements TransportRepository {
  final List<TransportRequest> _rides = [];

  @override
  Future<List<TransportRequest>> myRides() async => List.unmodifiable(_rides);

  @override
  Future<void> request(TransportRequest r) async => _rides.add(r);

  @override
  Future<void> updateStatus(String id, RideStatus status) async {
    final i = _rides.indexWhere((e) => e.id == id);
    if (i >= 0) _rides[i].status = status;
  }
}
