import '../models/study_session.dart';
import 'api_service.dart';

class SessionService {
  final ApiService _api = ApiService();

  Future<List<StudySession>> getSessions({
    String? subject,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final queryParams = <String, String>{};
    if (subject != null) queryParams['subject'] = subject;
    if (startDate != null) queryParams['startDate'] = startDate.toIso8601String();
    if (endDate != null) queryParams['endDate'] = endDate.toIso8601String();

    final query = queryParams.entries.map((e) => '${e.key}=${e.value}').join('&');
    final endpoint = '/sessions${query.isNotEmpty ? '?$query' : ''}';

    final response = await _api.get(endpoint);
    if (response['success']) {
      final sessions = (response['sessions'] as List)
          .map((session) => StudySession.fromJson(session))
          .toList();
      return sessions;
    }
    return [];
  }

  Future<StudySession?> getSession(String id) async {
    final response = await _api.get('/sessions/$id');
    if (response['success']) {
      return StudySession.fromJson(response['session']);
    }
    return null;
  }

  Future<StudySession> createSession(StudySession session) async {
    final response = await _api.post('/sessions', session.toJson());
    return StudySession.fromJson(response['session']);
  }

  Future<StudySession> updateSession(String id, StudySession session) async {
    final response = await _api.put('/sessions/$id', session.toJson());
    return StudySession.fromJson(response['session']);
  }

  Future<void> deleteSession(String id) async {
    await _api.delete('/sessions/$id');
  }

  Future<Map<String, dynamic>> getStats({String period = 'week'}) async {
    final response = await _api.get('/sessions/stats?period=$period');
    if (response['success']) {
      return response['stats'];
    }
    return {};
  }
}
