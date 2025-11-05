// lib/screens/contact_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/contact.dart';
// ignore: unused_import
import '../main.dart'; // import สีใหม่

class ContactDetailScreen extends StatelessWidget {
  final Contact contact;

  const ContactDetailScreen({super.key, required this.contact}); 

  Future<void> _makePhoneCall(String? phoneNumber) async {
    if (phoneNumber == null || phoneNumber.isEmpty) return; 
    
    // ลบ non-numeric characters ออกก่อนโทร เพื่อความชัวร์ 
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber.replaceAll(RegExp(r'[^0-9]'), '')); 
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      // Log จะหายไปหลังเพิ่ม queries ใน Manifest
      debugPrint('Could not launch $phoneNumber'); 
    }
  }

  Future<void> _sendEmail(String? email) async {
    if (email == null || email.isEmpty) return; 

    final Uri launchUri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      // Log จะหายไปหลังเพิ่ม queries ใน Manifest
      debugPrint('Could not launch email: $email');
    }
  }

  Widget _buildDetailAvatar(BuildContext context) {
    const double radius = 70;
    final Color accentColor = Theme.of(context).colorScheme.secondary; 
    
    if (contact.imageUrl != null) {
      return CachedNetworkImage(
        imageUrl: contact.imageUrl!,
        imageBuilder: (context, imageProvider) => CircleAvatar(
          radius: radius,
          backgroundImage: imageProvider,
        ),
        placeholder: (context, url) => CircleAvatar(
          radius: radius,
          backgroundColor: Colors.grey.shade200, 
          child: CircularProgressIndicator(strokeWidth: 3, color: accentColor), 
        ),
        errorWidget: (context, url, error) => CircleAvatar(
          radius: radius,
          backgroundColor: Colors.grey.shade300, 
          child: const Icon(Icons.person, color: Colors.white, size: 70), 
        ),
      );
    } else {
      return CircleAvatar(
        radius: radius,
        backgroundColor: accentColor, 
        child: const Icon(Icons.person, color: Colors.white, size: 70),
      );
    }
  }

  Widget _buildContactInfo({
    required BuildContext context, 
    required IconData leadingIcon, 
    required String title, 
    required String? subtitle,
    IconData? actionIcon, 
    VoidCallback? onActionTap,
    bool isAddress = false, 
    bool isFax = false,
  }) {
    final Color primaryColor = Theme.of(context).colorScheme.primary; 

    if (subtitle == null || subtitle.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0, top: 4.0),
            child: Icon(leadingIcon, color: primaryColor, size: 24), 
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: isFax || isAddress
                    ? const TextStyle(fontSize: 16, color: Colors.black87)
                    : const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          if (actionIcon != null && onActionTap != null)
            GestureDetector(
              onTap: onActionTap,
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0, top: 4.0),
                child: Icon(actionIcon, color: primaryColor, size: 24), 
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(contact.fullName),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. ส่วนหัว
            Card(
              margin: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 24.0, bottom: 24.0, left: 16.0, right: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildDetailAvatar(context), 
                    const SizedBox(height: 20),
                    Text(
                      contact.fullName,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      contact.position,
                      style: const TextStyle(fontSize: 18, color: Colors.black87),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      contact.department,
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            
            // 2. หัวข้อ "ข้อมูลการติดต่อ"
            Padding(
              padding: const EdgeInsets.only(top: 24.0, left: 20.0, right: 20.0, bottom: 8.0),
              child: Text(
                'ข้อมูลการติดต่อ',
                style: TextStyle(
                  fontSize: 18, 
                  fontWeight: FontWeight.bold, 
                  color: Colors.grey[800]
                ),
              ),
            ),
            
            // 3. Card ข้อมูลการติดต่อ
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16.0),
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // หมายเลขโทรศัพท์
                    _buildContactInfo(
                      context: context,
                      leadingIcon: Icons.phone_android, 
                      title: 'หมายเลขโทรศัพท์', 
                      subtitle: contact.tel,
                      actionIcon: Icons.call,
                      onActionTap: () => _makePhoneCall(contact.tel),
                    ),
                    
                    // เบอร์โทรศัพท์สำนักงาน
                    _buildContactInfo(
                      context: context,
                      leadingIcon: Icons.phone, 
                      title: 'เบอร์โทรศัพท์สำนักงาน', 
                      subtitle: contact.telOffice,
                      actionIcon: Icons.call,
                      onActionTap: () => _makePhoneCall(contact.telOffice),
                    ),

                    // โทรสาร (FAX)
                    _buildContactInfo(
                        context: context,
                        leadingIcon: Icons.print, 
                        title: 'โทรสาร (FAX)',
                        subtitle: contact.fax,
                        isFax: true,
                    ),

                    // เบอร์โทรศัพท์ มท
                    _buildContactInfo(
                      context: context,
                      leadingIcon: Icons.phone, 
                      title: 'สื่อสาร มท.', 
                      subtitle: contact.moicTel,
                      actionIcon: Icons.call,
                      onActionTap: () => _makePhoneCall(contact.moicTel),
                    ),

                    // ************ เส้นแบ่งส่วน ************
                    if (contact.tel?.isNotEmpty == true || contact.telOffice?.isNotEmpty == true || contact.fax?.isNotEmpty == true)
                      if (contact.email?.isNotEmpty == true || contact.address?.isNotEmpty == true)
                        const Divider(height: 30, thickness: 1), 

                    // อีเมล
                    _buildContactInfo(
                      context: context,
                      leadingIcon: Icons.email, 
                      title: 'อีเมล',
                      subtitle: contact.email,
                      actionIcon: Icons.email,
                      onActionTap: () => _sendEmail(contact.email),
                    ),
                    
                    // ************ เส้นแบ่งส่วน ************
                    if (contact.email?.isNotEmpty == true && contact.address?.isNotEmpty == true)
                      const Divider(height: 30, thickness: 1), 
                    
                    // สถานที่ติดต่อ
                    _buildContactInfo(
                      context: context,
                      leadingIcon: Icons.location_on, 
                      title: 'สถานที่ติดต่อ', 
                      subtitle: contact.address,
                      isAddress: true,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}