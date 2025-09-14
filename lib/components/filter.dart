import 'package:flutter/material.dart';

import '../models/class_users.dart';

// Model to store filter item data
class FilterItem {
  final String label;
  final String role; // Add role field to map to actual user role
  final int count;
  bool isSelected;

  FilterItem({
    required this.label,
    required this.role,
    required this.count,
    this.isSelected = false,
  });
}

class FilterWidget extends StatefulWidget {
  final List<User> users;
  final Function(List<String>)? onFiltersChanged; // This will now receive user roles

  const FilterWidget({
    Key? key,
    required this.users,
    this.onFiltersChanged,
  }) : super(key: key);

  @override
  _FilterWidgetState createState() => _FilterWidgetState();
}

class _FilterWidgetState extends State<FilterWidget> {
  Map<String, FilterItem> practices = {};

  @override
  void initState() {
    super.initState();
    _initializePractices();
  }

  void _initializePractices() {
    practices = {
      'Customers': FilterItem(
        label: 'Customers',
        role: 'user', // Map to actual user role
        count: widget.users.where((user) => user.role == "user").length,
        isSelected: false,
      ),
      'Association Leaders': FilterItem(
        label: 'Association Leaders',
        role: 'ambassador', // Map to actual user role
        count: widget.users.where((user) => user.role == "ambassador").length,
        isSelected: false,
      ),
      'Entities/Group': FilterItem(
        label: 'Entities/Group',
        role: 'artist', // Map to actual user role
        count: widget.users.where((user) => user.role == "artist").length,
        isSelected: false,
      ),
      'Sub Admin': FilterItem(
        label: 'Sub Admin',
        role: 'sub_admin', // Map to actual user role
        count: widget.users.where((user) => user.role == "sub_admin").length,
        isSelected: false,
      ),
    };
  }

  @override
  void didUpdateWidget(FilterWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.users != widget.users) {
      _initializePractices();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: Container(
        width: 248,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Filter Title
            const Text(
              'Filter',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Practice Section
            _buildFilterSection('User Roles', practices),

            // Flexible spacing instead of fixed height
            SizedBox(height: MediaQuery.of(context).size.height * 0.442),

            // Clear Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _clearAllFilters,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: BorderSide(color: Colors.grey[400]!),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Clear',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection(String title, Map<String, FilterItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        ...items.entries.map((entry) {
          return _buildCheckboxItem(
            entry.value,
                (bool? value) {
              setState(() {
                items[entry.key]!.isSelected = value ?? false;
              });
              _notifyFiltersChanged();
            },
          );
        }).toList(),
      ],
    );
  }

  Widget _buildCheckboxItem(FilterItem item, Function(bool?) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: Checkbox(
              value: item.isSelected,
              onChanged: onChanged,
              activeColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${item.label} (${item.count})',
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _clearAllFilters() {
    setState(() {
      for (var item in practices.values) {
        item.isSelected = false;
      }
    });
    _notifyFiltersChanged();
  }

  void _notifyFiltersChanged() {
    if (widget.onFiltersChanged != null) {
      // Pass the actual user roles instead of filter labels
      final selectedRoles = practices.entries
          .where((entry) => entry.value.isSelected)
          .map((entry) => entry.value.role) // Use role instead of key
          .toList();
      widget.onFiltersChanged!(selectedRoles);
    }
  }

  // Public method to get currently selected user roles
  List<String> getSelectedUserRoles() {
    return practices.entries
        .where((entry) => entry.value.isSelected)
        .map((entry) => entry.value.role) // Return roles instead of labels
        .toList();
  }

  // Public method to get filtered users
  List<User> getFilteredUsers() {
    final selectedRoles = getSelectedUserRoles();

    if (selectedRoles.isEmpty) {
      return widget.users;
    }

    return widget.users.where((user) {
      return selectedRoles.contains(user.role);
    }).toList();
  }
}