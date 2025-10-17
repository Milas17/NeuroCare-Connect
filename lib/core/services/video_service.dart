import 'package:url_launcher/url_launcher.dart';

class VideoService {
  Future<void> launchMeeting(String doctor) async {
    final url = Uri.parse('https://meet.jit.si/NeuroCareConnect-${Uri.encodeComponent(doctor)}');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch video URL');
    }
  }
}
