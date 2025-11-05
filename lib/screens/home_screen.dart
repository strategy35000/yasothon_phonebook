// lib/screens/home_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import '../api/api_service.dart';
import '../models/contact.dart';
import '../widgets/contact_list_item.dart';
import 'about_screen.dart';
import 'agency_screen.dart';
// ignore: unused_import
import '../main.dart';
// *** (สำคัญ: ต้องเพิ่ม dependency ใน pubspec.yaml เช่น motion_tab_bar_v2: ^latest) ***
import 'package:motion_tab_bar_v2/motion-tab-bar.dart';
import 'package:motion_tab_bar_v2/motion-tab-controller.dart';

class HomeScreen extends StatefulWidget {
  // ** รับข้อมูลทั้งหมดที่โหลดมาจาก Splash Screen **
  final List<Contact> allContacts;

  const HomeScreen({super.key, required this.allContacts});

  @override
  // *** เพิ่ม with TickerProviderStateMixin ***
  State<HomeScreen> createState() => _HomeScreenState();
}

// *** เพิ่ม TickerProviderStateMixin เพื่อใช้กับ MotionTabBarController ***
class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  static const _pageSize = 10;
  final PagingController<int, Contact> _pagingController = PagingController(firstPageKey: 1);
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  String _searchQuery = '';

  // ** ข้อมูลที่ใช้สำหรับการค้นหา/แสดงผล **
  List<Contact> _filteredContacts = [];

  final List<String> _appBarTitles = const [
    'สมุดโทรศัพท์จังหวัดยโสธร',
    'หน่วยงานทั้งหมด',
    'เกี่ยวกับ',
  ];

  // *** MotionTabBarController ***
  late MotionTabBarController _motionTabBarController;

  @override
  void initState() {
    super.initState();

    // *** เริ่มต้น MotionTabBarController ***
    _motionTabBarController = MotionTabBarController(
      initialIndex: 0,
      length: 3, // จำนวนแท็บทั้งหมด
      vsync: this,
    );

    // ตั้งค่าเริ่มต้น: _filteredContacts คือ allContacts ทั้งหมด
    _applyFilterAndRefreshPaging();

    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });

    _searchController.addListener(_onSearchChanged);
  }

  // 1. ฟังก์ชันที่ใช้ในการกรองข้อมูลจาก In-Memory List
  void _applyFilterAndRefreshPaging() {
    if (_searchQuery.isEmpty) {
      _filteredContacts = widget.allContacts;
    } else {
      final queryLower = _searchQuery.toLowerCase();
      _filteredContacts = widget.allContacts.where((contact) {
        // ค้นหาจากชื่อ, ตำแหน่ง, หรือหน่วยงาน
        return contact.fullName.toLowerCase().contains(queryLower) ||
               contact.position.toLowerCase().contains(queryLower) ||
               contact.department.toLowerCase().contains(queryLower);
      }).toList();
    }
    // รีเซ็ต PagingController ให้เริ่มโหลดหน้าแรกใหม่จาก _filteredContacts
    _pagingController.refresh();
  }

  // 2. ฟังก์ชันหลักในการดึงข้อมูลสำหรับ PagingController
  Future<void> _fetchPage(int pageKey) async {
    try {
      final isOnline = await ApiService.isConnected();

      if (isOnline) {
        // ** โหมด Online: ใช้ API สำหรับ Paging/Search **
        final newItems = await ApiService.fetchContacts(pageKey, _pageSize, query: _searchQuery);
        final isLastPage = newItems.length < _pageSize;

        if (isLastPage) {
          _pagingController.appendLastPage(newItems);
        } else {
          final nextPageKey = pageKey + 1;
          _pagingController.appendPage(newItems, nextPageKey);
        }

      } else {
        // ** โหมด Offline: ใช้ In-Memory Data (_filteredContacts) **
        final startIndex = (pageKey - 1) * _pageSize;
        final endIndex = startIndex + _pageSize;

        final itemsToReturn = startIndex < _filteredContacts.length
            ? _filteredContacts.sublist(startIndex, endIndex.clamp(0, _filteredContacts.length))
            : <Contact>[];

        final isLastPage = endIndex >= _filteredContacts.length;

        if (isLastPage) {
          _pagingController.appendLastPage(itemsToReturn);
        } else {
          final nextPageKey = pageKey + 1;
          _pagingController.appendPage(itemsToReturn, nextPageKey);
        }

        // หาก Offline, และไม่มีข้อมูลที่โหลดมาเลย
        if (widget.allContacts.isEmpty) {
          _pagingController.error = 'Network unavailable and no local cache found.';
        }
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  // 3. จัดการการค้นหา
  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      final newQuery = _searchController.text;
      if (_searchQuery != newQuery) {
        _searchQuery = newQuery;

        if (await ApiService.isConnected()) {
          _pagingController.refresh();
        } else {
          _applyFilterAndRefreshPaging();
        }
      }
    });
  }

  // 4. จัดการการ Pull-to-Refresh
  Future<void> _onRefresh() async {
    _pagingController.refresh();

    if (await ApiService.isConnected()) {
      try {
        // อัพเดท cache
        final newContacts = await ApiService.initializeContacts();
        setState(() {
          // อัพเดท widget.allContacts ในหน่วยความจำ (หากจำเป็น)
          widget.allContacts.clear();
          widget.allContacts.addAll(newContacts);
        });
      } catch (e) {
        // จัดการข้อผิดพลาดในการอัพเดท cache
        debugPrint('Error updating cache on refresh: $e');
      }
    }
  }

  // 5. Build Widget List
  Widget _buildContactListPage() {
    final Color primaryBlue = Theme.of(context).colorScheme.primary;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, left: 16.0, right: 16.0),
          color: Colors.white,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'ค้นหาข้อมูลติดต่อ',
                prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade200,
                contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
              ),
            ),
          ),
        ),

        Expanded(
          child: RefreshIndicator(
            onRefresh: _onRefresh,
            child: PagedListView<int, Contact>(
              pagingController: _pagingController,
              builderDelegate: PagedChildBuilderDelegate<Contact>(
                itemBuilder: (context, item, index) => ContactListItem(contact: item),
                // Custom Indicators
                firstPageProgressIndicatorBuilder: (_) => Center(child: CircularProgressIndicator(color: primaryBlue)),
                newPageProgressIndicatorBuilder: (_) => Center(child: CircularProgressIndicator(color: primaryBlue)),
                firstPageErrorIndicatorBuilder: (_) {
                  final errorMessage = _pagingController.error.toString();
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Text(
                        errorMessage.contains('Network unavailable')
                          ? 'คุณไม่ได้เชื่อมต่ออินเทอร์เน็ต'
                          : 'เกิดข้อผิดพลาดในการโหลดข้อมูล: $errorMessage',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  );
                },
                noItemsFoundIndicatorBuilder: (_) => const Center(child: Text('ไม่พบข้อมูลที่ค้นหา')),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryBlue = Theme.of(context).colorScheme.primary;
    // ใช้ _motionTabBarController.index ในการอ้างอิง
    final int safeIndex = _motionTabBarController.index.clamp(0, _appBarTitles.length - 1);

    return Scaffold(
      appBar: AppBar(
        title: Text(_appBarTitles[safeIndex]),
      ),
      // *** ใช้ TabBarView คู่กับ Controller ***
      body: TabBarView(
        controller: _motionTabBarController,
        physics: const NeverScrollableScrollPhysics(), // ป้องกันการปัด
        children: [
          _buildContactListPage(),
          const AgencyScreen(),
          const AboutScreen(),
        ],
      ),

      // *** MotionTabBar แทน BottomNavigationBar ***
      bottomNavigationBar: MotionTabBar(
        controller: _motionTabBarController,
        initialSelectedTab: 'รายชื่อ',
        useSafeArea: true,

        tabBarColor: Colors.white,
        tabIconColor: Colors.grey.shade700,
        tabSelectedColor: primaryBlue,
        tabIconSize: 24.0,
        tabIconSelectedSize: 24.0,

        labels: const ['รายชื่อ', 'หน่วยงาน', 'เกี่ยวกับ'],
        icons: const [
          Icons.message_outlined,
          Icons.groups_2_outlined,
          Icons.settings_outlined,
        ],
        // ======================= โค้ดที่แก้ไข =======================
        onTabItemSelected: (int index) {
          // สั่งให้ controller เปลี่ยน index และ re-render UI
          setState(() {
            _motionTabBarController.index = index;
          });
        },
        // ==========================================================
      ),
    );
  }

  @override
  void dispose() {
    _pagingController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    // *** Dispose MotionTabBarController ***
    _motionTabBarController.dispose();
    super.dispose();
  }
}