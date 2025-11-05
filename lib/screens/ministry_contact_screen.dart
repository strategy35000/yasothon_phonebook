// lib/screens/ministry_contact_screen.dart
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import '../api/api_service.dart';
import '../models/contact.dart';
import '../widgets/contact_list_item.dart';
// ignore: unused_import
import '../main.dart'; // เพื่อให้เข้าถึง Theme ได้

class MinistryContactScreen extends StatefulWidget {
  final String ministry;

  const MinistryContactScreen({super.key, required this.ministry}); // ใช้ super.key

  @override
  State<MinistryContactScreen> createState() => _MinistryContactScreenState();
}

class _MinistryContactScreenState extends State<MinistryContactScreen> {
  static const _pageSize = 10;
  final PagingController<int, Contact> _pagingController = PagingController(firstPageKey: 1);

  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      // ใช้ ApiService.fetchContacts โดยส่ง ministry name เป็น filter
      final newItems = await ApiService.fetchContacts(
        pageKey, 
        _pageSize, 
        ministry: widget.ministry, // กรองตามกระทรวงที่ถูกส่งมา
      );
      final isLastPage = newItems.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + 1;
        _pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  @override
  Widget build(BuildContext context) {
    // ดึงสี Primary Blue จาก Theme
    final Color primaryBlue = Theme.of(context).colorScheme.primary; 

    return Scaffold(
      appBar: AppBar(
        // ชื่อ AppBar คือชื่อกระทรวงที่ถูกเลือก
        title: Text('รายชื่อ: ${widget.ministry}'), 
      ),
      body: RefreshIndicator(
        onRefresh: () => Future.sync(() => _pagingController.refresh()),
        child: PagedListView<int, Contact>(
          pagingController: _pagingController,
          builderDelegate: PagedChildBuilderDelegate<Contact>(
            // ใช้ ContactListItem เพื่อแสดงรายชื่อ
            itemBuilder: (context, item, index) => ContactListItem(contact: item),
            // ใช้สี Primary Blue
            firstPageProgressIndicatorBuilder: (_) => Center(child: CircularProgressIndicator(color: primaryBlue)),
            newPageProgressIndicatorBuilder: (_) => Center(child: CircularProgressIndicator(color: primaryBlue)),
            firstPageErrorIndicatorBuilder: (_) => Center(child: Text('เกิดข้อผิดพลาด: ${_pagingController.error}')),
            noItemsFoundIndicatorBuilder: (_) => Center(child: Text('ไม่พบรายชื่อใน ${widget.ministry}')),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }
}