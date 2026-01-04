import 'package:hive_flutter/hive_flutter.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  Future<void> initialize() async {
    await Hive.initFlutter();
    // Register adapters here if using Hive type adapters
  }

  Future<Box> openBox(String boxName) async {
    if (!Hive.isBoxOpen(boxName)) {
      return await Hive.openBox(boxName);
    }
    return Hive.box(boxName);
  }

  Future<void> saveData(String boxName, String key, dynamic value) async {
    final box = await openBox(boxName);
    await box.put(key, value);
  }

  Future<dynamic> getData(String boxName, String key) async {
    final box = await openBox(boxName);
    return box.get(key);
  }

  Future<void> deleteData(String boxName, String key) async {
    final box = await openBox(boxName);
    await box.delete(key);
  }

  Future<void> clearBox(String boxName) async {
    final box = await openBox(boxName);
    await box.clear();
  }

  Future<Map<dynamic, dynamic>> getAllData(String boxName) async {
    final box = await openBox(boxName);
    return box.toMap();
  }
}
