// lib/screens/about_screen.dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
// ignore: unused_import
import '../main.dart'; // import สีใหม่

const Color primaryBlue = Color(0xFF0078FF); // สีน้ำเงินหลัก (messengerBlue)
const Color lightBlueBackground = Color(0xFFE9F1FE); // สีฟ้าอ่อนสำหรับพื้นหลัง/ส่วนหัว
const String appVersion = '1.0.0'; // ใช้เวอร์ชัน 1.0.0 ตาม pubspec
const String assetLogoPath = 'assets/logo.webp';


class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key}); 

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      // Log จะหายไปหลังเพิ่ม queries ใน Manifest
      debugPrint('Could not launch $url'); 
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // ส่วนหัว (Hero Section)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40.0),
            decoration: const BoxDecoration(
              color: lightBlueBackground,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(15.0),
                  child: Image.asset(
                    assetLogoPath,
                    width: 80, 
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon( 
                      Icons.message, 
                      size: 80, 
                      color: primaryBlue
                    ), 
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'สมุดโทรศัพท์ดิจิทัล',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: primaryBlue, 
                  ),
                ),
                const Text(
                  'เวอร์ชัน $appVersion',
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ],
            ),
          ),

          // ส่วนเนื้อหา
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Card 1: จุดประสงค์
                _buildInfoCard(
                  title: 'เกี่ยวกับแอปพลิเคชัน',
                  description:
                      'แอปพลิเคชันนี้ถูกพัฒนาขึ้นเพื่อเป็นเครื่องมือในการค้นหาข้อมูลติดต่อของบุคลากรและหน่วยงานต่าง ๆ ภายในองค์กรได้อย่างรวดเร็วและมีประสิทธิภาพ',
                  icon: FontAwesomeIcons.lightbulb,
                  color: Colors.amber.shade700,
                ),

                // Card 2: ผู้พัฒนา
                _buildInfoCard(
                  title: 'ผู้พัฒนา',
                  description:
                      'พัฒนาโดย นายไกรศร เกษงาม \nนักวิชาการคอมพิวเตอร์ชำนาญการ',
                  icon: FontAwesomeIcons.code,
                  color: Colors.blueGrey.shade600,
                ),

                const SizedBox(height: 20),
                const Text(
                  'ติดต่อเรา',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primaryBlue, 
                  ),
                ),
                const Divider(color: primaryBlue), 

                // รายการช่องทางการติดต่อ
                _buildContactTile(
                  title: 'โทรศัพท์ : 0 4571 2722', 
                  icon: FontAwesomeIcons.phone,
                  onTap: () => _launchURL('tel:045712722'),
                ),
                _buildContactTile(
                  title: 'เยี่ยมชมเว็บไซต์หลัก',
                  icon: FontAwesomeIcons.globe,
                  onTap: () => _launchURL('https://www2.yasothon.go.th/'),
                ),
                _buildContactTile(
                  title: 'ส่งอีเมลถึงทีมสนับสนุน',
                  icon: FontAwesomeIcons.solidEnvelope,
                  onTap: () => _launchURL(
                    'mailto:webmaster@yasothon.go.th?subject=สอบถามข้อมูลเกี่ยวกับแอปสมุดโทรศัพท์',
                  ),
                ),

                const SizedBox(height: 30),
                const Center(
                  child: Text(
                    '© 2025 Digital Team. สงวนลิขสิทธิ์',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2, 
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ), 
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FaIcon(icon, color: color, size: 28),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    description,
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactTile({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: FaIcon(icon, color: primaryBlue), 
      title: Text(title),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey,
      ),
      onTap: onTap,
    );
  }
}