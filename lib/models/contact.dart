// lib/models/contact.dart
class Contact {
  final int id;
  final String fullName;
  final String position;
  final String department;
  final String? tel; // หมายเลขโทรศัพท์ (มือถือ)
  final String? telOffice; // เบอร์โทรศัพท์สำนักงาน (phone_internal)
  final String? fax; // โทรสาร (FAX)
  final String? moicTel; // สื่อสาร (มท.) - เก็บค่าจาก phone_moi หากมี
  final String? email;
  final String? address; // สถานที่ติดต่อ
  final String? imageUrl;
  final String? ministry; // ** เพิ่ม field สำหรับ กระทรวง/หน่วยงานหลัก **

  Contact({
    required this.id,
    required this.fullName,
    required this.position,
    required this.department,
    this.tel,
    this.telOffice,
    this.fax, 
    this.moicTel, 
    this.email,
    this.address, 
    this.imageUrl,
    this.ministry, // ** เพิ่ม field ใน constructor **
  });

  factory Contact.fromJson(Map<String, dynamic> json) {
    String fullName = json['name'] ?? 'N/A';
    String? imageUrl = json['images']; 
    
    // Base URL ที่ใช้เมื่อ URL ที่ได้มาเป็นแค่ชื่อไฟล์
    const String baseUrl = 'https://oneplan.yasothon.go.th/storage/contacts/';

    // ตรวจสอบว่า URL ของรูปภาพถูกต้องหรือไม่
    if (imageUrl != null && imageUrl.isNotEmpty && !imageUrl.startsWith('http')) {
        imageUrl = '$baseUrl$imageUrl';
    } else if (imageUrl != null && imageUrl.isEmpty) {
      imageUrl = null;
    }

    return Contact(
      id: json['id'] ?? -1,
      fullName: fullName, 
      position: json['position'] ?? 'N/A',
      department: json['department'] ?? 'N/A',
      
      tel: json['phone_mobile'],      
      telOffice: json['phone_internal'], 
      fax: json['fax'],               
      moicTel: json['phone_moi'],     
      email: json['email'],           
      address: json['address'],       
      imageUrl: imageUrl,
      // ตรวจสอบให้แน่ใจว่าค่าเป็น String หรือ null
      ministry: json['ministry'] as String?, 
    );
  }
  
  // ** เพิ่ม: เมธอด toJson สำหรับการจัดเก็บใน shared_preferences **
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
      'images': imageUrl, 
      'ministry': ministry,
    };
  }
}
