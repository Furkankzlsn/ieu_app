import 'package:flutter/material.dart';
import '../../../../models/announcement_model.dart';
import '../../../../services/announcement_service.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/compact_announcements_widget.dart';

class CompactAnnouncementsList extends StatefulWidget {
  const CompactAnnouncementsList({super.key});

  @override
  State<CompactAnnouncementsList> createState() => _CompactAnnouncementsListState();
}

class _CompactAnnouncementsListState extends State<CompactAnnouncementsList> {
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
      final announcements = await _announcementService.getAnnouncements(limit: 3);
      if (mounted) {
        setState(() {
          _announcements = announcements;
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
