// lib/main.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/splash_screen.dart';

// กำหนดค่าสีหลักของ Messenger/Facebook
const Color messengerBlue = Color(0xFF0078FF); // สีน้ำเงินหลัก
// *** เปลี่ยนเป็นสีขาวตามภาพตัวอย่าง ***
const Color lightGrayBackground = Colors.white; // สีพื้นหลัง Scaffold
const Color appbarColor = Colors.white; // สี AppBar
const Color accentBlue = Color(0xFF00BFFF); // สีฟ้าอ่อนสำหรับเน้น (คล้ายสีในภาพ)

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key}); // ใช้ super.key

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // *** เปลี่ยน title เป็นชื่อแอปใหม่ (ใช้ใน Android App Switcher และ Web) ***
      title: 'Y-Phone', 
      theme: ThemeData(
        // ใช้สีขาวเป็นสีหลักของแอปฯ
        primaryColor: appbarColor, 
        
        // *** ใช้สีขาวเป็นสีพื้นหลัง Scaffold (ตามคำขอ) ***
        scaffoldBackgroundColor: lightGrayBackground,
        
        colorScheme: const ColorScheme.light(
          primary: messengerBlue, // สีหลัก (สำหรับปุ่ม/เน้น)
          secondary: accentBlue, // สีรอง
        ),
        
        // ใช้ Font Sarabun เหมือนเดิม
        textTheme: GoogleFonts.sarabunTextTheme(
          Theme.of(context).textTheme,
        ),

        // ปรับ AppBar ให้เป็นสีขาว มีชื่อเป็นสีดำ และยก Elevation เล็กน้อย
        appBarTheme: AppBarTheme(
          backgroundColor: appbarColor,
          foregroundColor: Colors.black, // สีของไอคอนและปุ่มบน AppBar
          elevation: 1, // มีเงาเล็กน้อย
          titleTextStyle: GoogleFonts.sarabun(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        // ปรับ Card ให้ไม่มีเงามากและใช้สีขาว
        cardTheme: const CardThemeData( 
          color: Colors.white,
          elevation: 1, // ลดเงาให้เรียบ
          shape: RoundedRectangleBorder( 
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}
