import '../services/storage_service.dart';

class OnboardingService {
  static const String _boxName = 'app_settings';
  static const String _hasSeenTourKey = 'has_seen_tour';
  final StorageService _storage = StorageService();

  Future<bool> hasSeenTour() async {
    try {
      final value = await _storage.getData(_boxName, _hasSeenTourKey);
      return value == true;
    } catch (e) {
      return false;
    }
  }

  Future<void> markTourAsSeen() async {
    await _storage.saveData(_boxName, _hasSeenTourKey, true);
  }
}
