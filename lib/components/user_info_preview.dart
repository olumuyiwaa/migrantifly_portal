import 'package:flutter/material.dart';

import '../models/class_users.dart';
import 'forms/user_info_fields.dart';

class UserInfoPreview extends StatelessWidget {
  final User user;

  const UserInfoPreview({
    super.key,
    required this.user,
  });
  void _showUserDetailsModal(BuildContext context, User user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return
          UserInfoFields(
          user: user,
        );
      },
    );
  }





  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 20),
          _buildSection('Personal Information', [
            Row(
              children: [
                Expanded(child: _buildDetailItem(Icons.person, 'Full Name', user.fullName)),
                Expanded(child: _buildDetailItem(Icons.email, 'Email', user.email)),
                Expanded(child: _buildDetailItem(Icons.phone, 'Phone', user.phoneNumber)),
                Expanded(child: _buildDetailItem(Icons.date_range, 'Joined On', user.createdAt.split('T').first)),

              ],
            ),
            Row(
              children: [
                Expanded(flex: 1, child: _buildDetailItem(Icons.group, 'Role', user.role)),
                Expanded(flex:3,child: _buildDetailItem(Icons.info_outline, 'Address', user.fullAddress)),
              ],
            ),
            Row(
              children: [
                Expanded(flex: 1, child: _buildDetailItem(Icons.location_on, 'Country Located', user.countryLocated)),
                Expanded( flex:3,child: _buildDetailItem(Icons.flag, 'Nationality', user.representedCountry)),
            ]),
          ]),
          const Divider(height: 30),
          _buildSection('Account Info', [
            Row(
              children: [
                Expanded(child: _buildDetailItem(Icons.label, 'User ID', user.id)),
                Expanded(child: _buildDetailItem(Icons.image, 'Media Count', '${user.mediaFiles.length} files')),
                Expanded(child: _buildDetailItem(Icons.bookmark, 'Bookmarked Events', '${user.bookmarkedEvents.length}')),
                if (user.role.toLowerCase()=="artist")
                  Expanded(child: _buildDetailItem(Icons.language, 'Countries of Interest', user.countries.join(', '))),
              ],
            ),
          ]),
        ],
      ),
    );
  }


  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundImage: user.image.isNotEmpty ? NetworkImage(user.image) : null,
          child: user.image.isEmpty
              ? Text(user.fullName.isNotEmpty ? user.fullName[0] : '?', style: const TextStyle(fontSize: 24))
              : null,
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('User Details', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            Text(user.fullName, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[600])),
          ],
        ),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.edit, color: Colors.grey),
          onPressed: () => _showUserDetailsModal(context, user),
        ),
      ],
    );
  }


  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withOpacity(0.1), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Icon(icon, size: 20, color: Colors.grey[600])),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color chipColor;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'activated':
        chipColor = Colors.green;
        icon = Icons.check_circle;
        break;
      case 'deactivated':
        chipColor = Colors.red;
        icon = Icons.cancel;
        break;
      default:
        chipColor = Colors.grey;
        icon = Icons.help_outline;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Icon(Icons.toggle_on, size: 20, color: Colors.grey[600])),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: chipColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: chipColor.withOpacity(0.5), width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 16, color: chipColor),
                const SizedBox(width: 6),
                Text(
                  status,
                  style: TextStyle(
                    color: chipColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
