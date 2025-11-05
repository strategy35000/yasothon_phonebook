// lib/services/cache_service.dart
import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  // Key สำหรับจัดเก็บข้อมูลรายชื่อติดต่อทั้งหมด
  static const String _contactsCacheKey = 'cached_contacts_data';
  // Key สำหรับจัดเก็บเวลาที่อัพเดทล่าสุด
  static const String _lastUpdatedKey = 'last_updated_timestamp';
  // กำหนดช่วงเวลาที่ถือว่าข้อมูลยัง 'ใหม่' (เช่น 1 วัน)
  static const Duration cacheValidityDuration = Duration(hours: 24); 

  /// บันทึกข้อมูล JSON String ของ Contacts ลงใน Local Cache
  static Future<void> cacheContacts(String jsonString) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_contactsCacheKey, jsonString);
      // บันทึกเวลาที่ทำการแคช
      await prefs.setInt(_lastUpdatedKey, DateTime.now().millisecondsSinceEpoch); 
      print('Contacts cached successfully.');
    } catch (e) {
      print('Error caching contacts: $e');
    }
  }

  /// ดึงข้อมูล JSON String ของ Contacts จาก Local Cache
  static Future<String?> getCachedContactsJson() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_contactsCacheKey);
    } catch (e) {
      print('Error getting cached contacts: $e');
      return null;
    }
  }

  /// ตรวจสอบว่าข้อมูลใน Cache ยังคงใช้ได้หรือไม่ (ไม่เก่าเกินไป)
  static Future<bool> isCacheValid() async {
    final prefs = await SharedPreferences.getInstance();
    final lastUpdated = prefs.getInt(_lastUpdatedKey);

    if (lastUpdated == null) {
      return false; // ไม่เคยแคชเลย
    }

    final lastUpdatedTime = DateTime.fromMillisecondsSinceEpoch(lastUpdated);
    final now = DateTime.now();
    
    // ตรวจสอบว่าเวลาปัจจุบัน - เวลาอัพเดทล่าสุด < ระยะเวลาที่กำหนด
    return now.difference(lastUpdatedTime) < cacheValidityDuration;
  }
}
