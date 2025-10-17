import '../models/appointment.dart';

abstract class TelemedRepository {
  Future<List<String>> listDoctors();
  Future<void> book(Appointment appt);
  Future<List<Appointment>> myAppointments();
}

class InMemoryTelemedRepository implements TelemedRepository {
  final List<String> _doctors = ['Dr. A. Neuroped', 'Dr. B. Neurophys', 'Dr. C. Neuro'];
  final List<Appointment> _appts = [];

  @override
  Future<void> book(Appointment appt) async {
    _appts.add(appt);
  }

  @override
  Future<List<String>> listDoctors() async => _doctors;

  @override
  Future<List<Appointment>> myAppointments() async => List.unmodifiable(_appts);
}
