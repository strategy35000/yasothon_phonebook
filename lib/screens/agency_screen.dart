// lib/screens/agency_screen.dart (Refactored to show Ministry list)
import 'package:flutter/material.dart';
import '../api/api_service.dart';
import 'ministry_contact_screen.dart'; // import หน้าจอแสดงรายชื่อที่ถูกกรอง

class AgencyScreen extends StatefulWidget {
  const AgencyScreen({super.key}); // ใช้ super.key

  @override
  State<AgencyScreen> createState() => _AgencyScreenState();
}

// NOTE: นี่คือหน้าจอที่แสดงรายการ กระทรวง/หน่วยงานหลัก (Ministry) ที่ไม่ซ้ำกัน
class _AgencyScreenState extends State<AgencyScreen> {
  Future<List<String>>? _ministriesFuture;

  @override
  void initState() {
    super.initState();
    _fetchMinistries();
  }

  void _fetchMinistries() {
    setState(() {
      _ministriesFuture = ApiService.fetchUniqueMinistries();
    });
  }

  @override
  Widget build(BuildContext context) {
    // ดึงค่าสีจาก Theme 
    final Color primaryBlue = Theme.of(context).colorScheme.primary; 
    final Color accentBlue = Theme.of(context).colorScheme.secondary; 

    return FutureBuilder<List<String>>(
      future: _ministriesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(color: primaryBlue),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text('เกิดข้อผิดพลาดในการโหลดกระทรวง: ${snapshot.error}', textAlign: TextAlign.center),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('ไม่พบข้อมูลกระทรวง/หน่วยงานหลัก'));
        }

        final ministries = snapshot.data!;
        
        return RefreshIndicator(
          onRefresh: () async {
            _fetchMinistries();
            await _ministriesFuture; 
          },
          child: ListView.builder(
            itemCount: ministries.length,
            itemBuilder: (context, index) {
              final ministryName = ministries[index];
              return Card(
                elevation: 1, 
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), 
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: Icon(
                    Icons.account_balance, // ไอคอนสื่อถึงหน่วยงาน/กระทรวง
                    color: primaryBlue, // ใช้ Primary Color
                  ),
                  title: Text(
                    ministryName,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  trailing: Icon(Icons.chevron_right, color: accentBlue), // ใช้ Secondary Color
                  onTap: () {
                    // นำทางไปยังหน้า MinistryContactScreen พร้อมส่งชื่อกระทรวง
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => MinistryContactScreen(ministry: ministryName),
                    ));
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }
}