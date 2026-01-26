import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:orre_mmc_app/theme/app_colors.dart';
import 'package:orre_mmc_app/shared/widgets/glass_container.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text('Activity'),
        centerTitle: true,
        backgroundColor: AppColors.backgroundDark.withOpacity(0.9),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text(
              'Mark all',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: Colors.white,
          unselectedLabelColor: const Color(0xFF90CBAD),
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Unread'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildNotificationsList(),
          const Center(
            child: Text(
              'No unread notifications',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionHeader('Today'),
        _buildNotificationItem(
          icon: Icons.payments,
          iconColor: Colors.amber,
          bgColor: Colors.amber.withOpacity(0.2),
          title: 'Dividend Received',
          time: '2h ago',
          message:
              '\$450.00 has been credited to your wallet from the \'Azure Heights\' asset.',
          isUnread: true,
        ),
        const SizedBox(height: 12),
        _buildNotificationItem(
          icon: Icons.domain,
          iconColor: AppColors.primary,
          bgColor: AppColors.primary.withOpacity(0.2),
          title: 'New Property Launch',
          time: '5h ago',
          message:
              'Fractional ownership is now open for \'The Gilded Estate\' in London.',
          isUnread: true,
        ),
        const SizedBox(height: 24),
        _buildSectionHeader('Earlier'),
        _buildNotificationItem(
          icon: Icons.shield,
          iconColor: Colors.blue[400]!,
          bgColor: Colors.blue[500]!.withOpacity(0.2),
          title: 'Security Login',
          time: 'Yesterday',
          message:
              'A new login was recorded from an iPhone 15 in New York, USA.',
          isUnread: false,
          opacity: 0.7,
        ),
        const SizedBox(height: 12),
        _buildNotificationItem(
          icon: Icons.verified_user,
          iconColor: Colors.blueGrey[300]!,
          bgColor: Colors.blueGrey[500]!.withOpacity(0.2),
          title: 'Identity Verified',
          time: '2d ago',
          message:
              'Your KYC documents have been successfully verified. Welcome to Orre MMC.',
          isUnread: false,
          opacity: 0.7,
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildNotificationItem({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    required String time,
    required String message,
    required bool isUnread,
    double opacity = 1.0,
  }) {
    return Opacity(
      opacity: opacity,
      child: GlassContainer(
        padding: const EdgeInsets.all(16),
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withOpacity(0.05),
        child: Stack(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            time,
                            style: const TextStyle(
                              color: Color(0xFF90CBAD),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: Text(
                          message,
                          style: const TextStyle(
                            color: Color(0xFF90CBAD),
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (isUnread)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.4),
                        blurRadius: 8,
                        spreadRadius: 2,
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
