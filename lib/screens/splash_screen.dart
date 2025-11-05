// lib/screens/splash_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'home_screen.dart';
import '../api/api_service.dart'; // ** เพิ่ม: สำหรับเรียก initializeContacts **
// ignore: unused_import
import '../main.dart'; 

const Color messengerBlue = Color(0xFF0078FF); 
const Color cleanLightBlue = Color(0xFFB3E5FC); 
const Color cleanMidBlue = Color(0xFF4FC3F7); 

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key}); 

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const String assetLogoPath = 'assets/logo.webp';
  // ** State สำหรับแสดง Error **
  String? _error; 

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  // ** ฟังก์ชันสำหรับโหลดข้อมูลและนำทาง **
  Future<void> _initializeApp() async {
    try {
      // ** โหลดข้อมูลทั้งหมด (Online-First/Offline-Fallback) **
      final contacts = await ApiService.initializeContacts(); 
      
      // เมื่อโหลดเสร็จแล้ว นำทางไปยัง HomeScreen โดยส่งข้อมูล Contacts ที่โหลดมา
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (BuildContext context) => HomeScreen(allContacts: contacts)),
        );
      }
    } catch (e) {
      // หากเกิดข้อผิดพลาดในการโหลด (เช่น ไม่มีเน็ต และไม่มีแคช)
      setState(() {
        _error = e.toString().contains('no local cache') 
          ? 'ไม่สามารถเชื่อมต่อเครือข่ายได้และไม่พบข้อมูลที่แคชไว้'
          : 'เกิดข้อผิดพลาดในการโหลดข้อมูล: $e';
        print('Initialization error: $e');
      });
      // สามารถเพิ่ม Timer เพื่อให้ผู้ใช้มีเวลาอ่านข้อความก่อนปิดแอปฯ ได้
      // Timer(const Duration(seconds: 5), () => print('App initialized with error, ready to exit.'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [cleanLightBlue, cleanMidBlue], 
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15.0), 
                child: Image.asset(
                  assetLogoPath,
                  width: 150, 
                  height: 150,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.message, 
                    size: 100, 
                    color: messengerBlue 
                  ), 
                ),
              ),
              
              const SizedBox(height: 30),
              const Text( 
                'สมุดโทรศัพท์จังหวัดยโสธร',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87, 
                ),
              ),
              
              const SizedBox(height: 8), 
              const Text( 
                'กำลังโหลดข้อมูล...',
                style: TextStyle(
                  fontSize: 18, 
                  color: Colors.black54, 
                ),
              ),

              const SizedBox(height: 30),
              // ** แสดง Error หรือ CircularProgressIndicator **
              _error != null
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0),
                    child: Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                  )
                : const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(messengerBlue),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
