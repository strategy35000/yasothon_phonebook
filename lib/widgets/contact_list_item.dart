// lib/widgets/contact_list_item.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/contact.dart';
import '../screens/contact_detail_screen.dart';
// ignore: unused_import
import '../main.dart'; // import สีใหม่

// *** กำหนดสีเขียวหลักของ WhatsApp (เข้ม) ***
const Color whatsappGreen = Color(0xFF075E54);
// *** กำหนดสีเขียวอ่อนสำหรับ Icon/Placeholder (สว่าง) ***
const Color whatsappLightGreen = Color(0xFF25D366);

class ContactListItem extends StatelessWidget {
  final Contact contact;

  const ContactListItem({super.key, required this.contact});

  @override
  Widget build(BuildContext context) {
    // ใช้สีเขียวหลักของ WhatsApp สำหรับองค์ประกอบเน้น
    // ignore: unused_local_variable
    const Color primaryColor = whatsappGreen; 
    // ignore: unused_local_variable
    const Color accentColor = whatsappLightGreen;

    // ฟังก์ชันช่วยสร้าง CircleAvatar เพื่อให้โค้ดสะอาดขึ้น
    Widget buildAvatar() {
      // **ปรับขนาด Radius เป็น 32**
      const double radius = 32;

      // ใช้สีเขียวอ่อนสำหรับ Avatar Placeholder
      final Color avatarPlaceholderBg = whatsappLightGreen.withOpacity(0.1); 
      const Color placeholderIconColor = whatsappLightGreen; 

      if (contact.imageUrl != null) {
        return CachedNetworkImage(
          imageUrl: contact.imageUrl!,
          imageBuilder: (context, imageProvider) => CircleAvatar(
            radius: radius,
            backgroundImage: imageProvider,
          ),
          placeholder: (context, url) => CircleAvatar(
            radius: radius,
            backgroundColor: avatarPlaceholderBg, // สีอ่อนมาก
            child: CircularProgressIndicator(strokeWidth: 2, color: placeholderIconColor), // แสดงสถานะโหลดด้วยสีเขียว
          ),
          errorWidget: (context, url, error) => CircleAvatar(
            radius: radius,
            backgroundColor: avatarPlaceholderBg, // สีอ่อน
            child: Icon(Icons.person, color: placeholderIconColor, size: 32), // ไอคอนสีเขียว
          ),
        );
      } else {
        // รูป Avatar เมื่อไม่มี URL รูปภาพ
        return CircleAvatar(
          radius: radius,
          backgroundColor: avatarPlaceholderBg, // สีอ่อนตามธีม
          child: Icon(Icons.person, color: placeholderIconColor, size: 32), 
        );
      }
    }

    return Column(
      children: [
        InkWell(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => ContactDetailScreen(contact: contact),
            ));
          },
          // **ปรับ Padding ให้สมมาตรและมีพื้นที่มากขึ้น**
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), // เพิ่ม vertical padding เล็กน้อย
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                buildAvatar(), // รูปภาพ/Avatar
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ชื่อ (Title) - ปรับเป็น Bold และขนาด 17
                      Text(
                        contact.fullName, 
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 17, color: Colors.black87), 
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      // ตำแหน่ง/หน่วยงาน (Subtitle) - ใช้สีเทาอ่อนและขนาด 15 (เหมือนข้อความพรีวิว)
                      // *** ลบ Row ที่มีไอคอนออก และใช้ Text ธรรมดาแทน ***
                      Text(
                        contact.position, // ใช้ตำแหน่งเป็น Subtitle
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 14), 
                      ),
                    ],
                  ),
                ),
                // *** ลบส่วนที่แสดงเบอร์โทรศัพท์ (contact.tel) ออกตามคำขอ ***
              ],
            ),
          ),
        ),
        // *** เส้นแบ่งรายการ (Divider) - ปรับให้ชัดเจนขึ้น (Thickness: 0.5, Color: shade400) ***
        Padding(
          // 16 (padding ซ้าย) + 32*2 (radius) + 16 (SizedBox) = 80
          padding: const EdgeInsets.only(left: 64.0 + 16.0, right: 16.0), // 80.0
          child: Divider(
            height: 1,
            thickness: 0.5, // หนาขึ้นเล็กน้อย
            color: Colors.grey.shade400, // สีเข้มขึ้น
          ),
        ),
      ],
    );
  }
}
