import 'package:flutter/material.dart';
import '../../models/announcement_model.dart';
import '../../services/announcement_service.dart';
import './compact_announcements_widget.dart';

class AnnouncementsSection extends StatefulWidget {
  const AnnouncementsSection({Key? key}) : super(key: key);

  @override
  State<AnnouncementsSection> createState() => _AnnouncementsSectionState();
}

class _AnnouncementsSectionState extends State<AnnouncementsSection> {
  final AnnouncementService _announcementService = AnnouncementService();
  List<AnnouncementModel> _announcements = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAnnouncements();
  }

  Future<void> _loadAnnouncements() async {
    try {
      final announcements = await _announcementService.getAnnouncements();
      
      // Son 3 duyuru
      if (mounted) {
        setState(() {
          _announcements = announcements.take(3).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return CompactAnnouncementsWidget(announcements: _announcements);
  }
}
