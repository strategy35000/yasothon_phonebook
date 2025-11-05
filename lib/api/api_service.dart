// lib/api/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart'; // ** เพิ่ม: สำหรับตรวจสอบ Network **
import '../models/contact.dart';
import '../models/agency.dart'; // Import model agency เดิม
import '../services/cache_service.dart'; // ** เพิ่ม: สำหรับ Local Cache **

class ApiService {
  static const String _baseContactUrl = 'https://oneplan.yasothon.go.th/api/contacts';
  static const String _baseAgencyUrl = 'https://oneplan.yasothon.go.th/api/agencies'; 

  // ** 1. ฟังก์ชันใหม่: ตรวจสอบสถานะอินเทอร์เน็ต **
  static Future<bool> isConnected() async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    return connectivityResult != ConnectivityResult.none;
  }

  // ** 2. ฟังก์ชันใหม่: ดึงข้อมูล Contacts ทั้งหมด (สำหรับการแคชในครั้งแรก) **
  // เนื่องจาก API เดิมเป็นแบบ Pagination เราต้องดึงทุกหน้าจนกว่าจะหมด
  static Future<List<Contact>> fetchAllContactsForCaching() async {
    List<Contact> allContacts = [];
    int currentPage = 1;
    int? lastPage;
    const int perPage = 50; 

    print('Fetching ALL contacts for caching...');

    while (lastPage == null || currentPage <= lastPage) {
      final uri = Uri.parse('$_baseContactUrl?page=$currentPage&per_page=$perPage');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> data = responseData['data'] ?? [];

        lastPage ??= responseData['last_page'] as int? ?? 1;

        allContacts.addAll(data.map((json) => Contact.fromJson(json)).toList());
        currentPage++;

        if (lastPage == 0 && currentPage > 1) break; 
        
      } else {
        throw Exception('Failed to load all contacts from API (Page $currentPage)');
      }
    }
    
    // แปลง List<Contact> กลับเป็น JSON String และแคช
    final jsonString = json.encode(allContacts.map((c) => c.toJson()).toList());
    await CacheService.cacheContacts(jsonString); // ** ทำการแคชข้อมูล **
    print('All contacts fetched and cached successfully: ${allContacts.length} items');
    return allContacts;
  }

  // ** 3. ฟังก์ชันปรับปรุง: ดึงข้อมูลหลัก (Online-First/Offline-Fallback) **
  // ฟังก์ชันนี้ถูกเรียกใช้ใน Splash Screen เพื่อโหลดข้อมูลตั้งต้น
  static Future<List<Contact>> initializeContacts() async {
    // 1. ตรวจสอบการเชื่อมต่อ
    final isOnline = await isConnected();
    
    if (isOnline) {
      print('Network available. Checking cache validity...');
      
      // 2. หาก Online และ Cache หมดอายุ (หรือยังไม่เคยแคช)
      if (!await CacheService.isCacheValid()) {
        print('Cache is invalid or expired. Fetching fresh data from API...');
        try {
          // ดึงข้อมูลทั้งหมดและทำการแคชใหม่
          return await fetchAllContactsForCaching();
        } catch (e) {
          print('Error fetching fresh data: $e');
          // 3. หากดึงข้อมูลใหม่ไม่สำเร็จ (แม้จะ Online) ให้ลองใช้ข้อมูลเก่าจาก Cache
          final cachedJson = await CacheService.getCachedContactsJson();
          if (cachedJson != null) {
            print('Falling back to expired cache due to API error.');
            final List<dynamic> data = json.decode(cachedJson);
            return data.map((json) => Contact.fromJson(json)).toList();
          }
          // 4. หากไม่มีทั้งข้อมูลใหม่และข้อมูลแคช ให้ Throw Error
          throw Exception('Failed to initialize data from both network and local cache.');
        }
      } else {
        // 5. หาก Online และ Cache ยังใช้ได้ (เพื่อประหยัดทรัพยากร/เวลาโหลด)
        print('Cache is still valid. Using local cache data.');
        final cachedJson = await CacheService.getCachedContactsJson();
        final List<dynamic> data = json.decode(cachedJson!);
        return data.map((json) => Contact.fromJson(json)).toList();
      }
    } else {
      // 6. หาก Offline
      print('Network UNVAILABLE. Loading from local cache...');
      final cachedJson = await CacheService.getCachedContactsJson();
      if (cachedJson != null) {
        final List<dynamic> data = json.decode(cachedJson);
        return data.map((json) => Contact.fromJson(json)).toList();
      }
      // 7. หาก Offline และไม่มี Cache
      throw Exception('Network is unavailable and no local cache found.');
    }
  }

  // ** 4. ฟังก์ชันเดิม: ดึงข้อมูลแบบ Pagination สำหรับ PagedListView **
  // ฟังก์ชันนี้จะใช้ข้อมูลที่โหลดไว้ในหน่วยความจำ (หรืออาจจะดึงใหม่ในอนาคต หากมีการปรับปรุงระบบ)
  // แต่สำหรับโครงสร้างปัจจุบันที่ใช้ infinite_scroll_pagination ต้องคงรูปแบบนี้ไว้ 
  // NOTE: เนื่องจากการใช้งานจริงแบบ Offline กับ PagedListView จะซับซ้อน (ต้องใช้ Local DB)
  // ในเวอร์ชันนี้ เราจะถือว่า PagedListView (HomeScreen) จะทำงานกับข้อมูลที่โหลดมาแล้วทั้งหมด 
  // หรืออาจจะปรับให้เรียก API โดยตรงหาก Online, แต่ถ้า Offline จะใช้ข้อมูลที่โหลดมาทั้งหมดในครั้งแรก
  // ********** แต่เพื่อความยืดหยุ่น จะคงฟังก์ชันเดิมไว้ **********
  static Future<List<Contact>> fetchContacts(int page, int pageSize, {String? query, String? ministry}) async {
    if (await isConnected()) {
      // ใช้ API สำหรับการค้นหาและ Pagination เมื่อ Online
      String params = '';
      if (query != null && query.isNotEmpty) {
        params += '&search=$query';
      }
      if (ministry != null && ministry.isNotEmpty) {
        params += '&search=$ministry';
      }

      final uri = Uri.parse('$_baseContactUrl?page=$page&per_page=$pageSize$params');
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['data'];
        return data.map((json) => Contact.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load contacts from API');
      }
    } else {
      // หาก Offline, จะต้องใช้ข้อมูลที่โหลดมาทั้งหมดในหน่วยความจำแทน
      // แต่เนื่องจาก `infinite_scroll_pagination` ไม่ได้ออกแบบมาเพื่อใช้กับ In-Memory Data โดยตรง 
      // การใช้งาน Offline Paging จะถูกจำลองใน `HomeScreen` แทนการเรียกจาก `ApiService` นี้
      // ฟังก์ชันนี้จึงควรจะถูกเรียกใช้เมื่อ Online เท่านั้น หรือให้ throw error เพื่อให้ PagedListView แสดง Error
      throw Exception('Network unavailable for PagingController');
    }
  }


  // ** 5. ฟังก์ชันเดิมสำหรับดึงรายการกระทรวง/หน่วยงานหลัก (Ministry) ที่ไม่ซ้ำกัน **
  // ฟังก์ชันนี้ควรดึงจาก API เสมอหาก Online เนื่องจากข้อมูลอาจมีการเปลี่ยนแปลง
  static Future<List<String>> fetchUniqueMinistries() async {
    if (!await isConnected()) {
      throw Exception('Network unavailable to fetch ministries.');
    }
    Set<String> uniqueMinistries = {};
    int currentPage = 1;
    int? lastPage;
    const int perPage = 50; 

    while (lastPage == null || currentPage <= lastPage) {
      final uri = Uri.parse('$_baseContactUrl?page=$currentPage&per_page=$perPage');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> data = responseData['data'] ?? [];

        lastPage ??= responseData['last_page'] as int? ?? 1;

        for (var json in data) {
          String? ministry = json['ministry']; 
          if (ministry != null && ministry.isNotEmpty) {
            uniqueMinistries.add(ministry);
          }
        }
        
        currentPage++;

        if (lastPage == 0 && currentPage > 1) break; 
        
      } else {
        throw Exception('Failed to load ministries');
      }
    }
    
    List<String> sortedMinistries = uniqueMinistries.toList();
    sortedMinistries.sort();
    return sortedMinistries;
  }

  // 6. ฟังก์ชันเดิมสำหรับดึงหน่วยงาน (Agency) - ยังไม่ได้มีการจัดการ Offline
  static Future<List<Agency>> fetchAgencies(int page, int pageSize) async {
    final uri = Uri.parse('$_baseAgencyUrl?page=$page&per_page=$pageSize');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['data'];
      return data.map((json) => Agency.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load agencies');
    }
  }
}

// ** ปรับปรุง Contact Model เพื่อรองรับการแปลงเป็น JSON String สำหรับการแคช **
extension ContactExtension on Contact {
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': fullName,
      'position': position,
      'department': department,
      'phone_mobile': tel,
      'phone_internal': telOffice,
      'fax': fax,
      'phone_moi': moicTel,
      'email': email,
      'address': address,
      'images': imageUrl, // เก็บเป็น URL เต็มหรือชื่อไฟล์ก็ได้
      'ministry': ministry,
    };
  }
}
