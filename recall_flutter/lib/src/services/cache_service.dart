import 'package:hive_flutter/hive_flutter.dart';

class CacheService {
  static const String boxName = 'recall_cache';

  /// Initialize Hive and open the main cache box
  Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(boxName);
  }

  /// Store data in the cache
  Future<void> cacheData(String key, dynamic data) async {
    print('CacheService: Writing $key...');
    final box = Hive.box(boxName);
    await box.put(key, data);
    print('CacheService: Wrote $key successfully. data type: ${data.runtimeType}');
  }

  /// Retrieve data from the cache
  dynamic getCachedData(String key) {
    if (!Hive.isBoxOpen(boxName)) {
      print('CacheService: Box $boxName not open!');
      return null;
    }
    final box = Hive.box(boxName);
    final data = box.get(key);
    print('CacheService: Reading $key... Found: ${data != null}');
    return data;
  }
}
