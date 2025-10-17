enum RideStatus { pending, assigned, onTheWay, completed, cancelled }
class TransportRequest {
  final String id;
  final String patientName;
  final String pickup;
  final String dropoff;
  RideStatus status;
  TransportRequest({required this.id, required this.patientName, required this.pickup, required this.dropoff, this.status = RideStatus.pending});
}
