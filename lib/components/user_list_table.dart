import 'package:flutter/material.dart';

import '../api/api_delete.dart';
import '../api/api_get.dart';
import '../constants.dart';
import '../models/class_users.dart';
import 'forms/user_info_fields.dart';

class UserListTable extends StatefulWidget {
  final List<String> filter;
  final ValueChanged<int> onItemTapped;
  final ValueChanged<String> onTitleTapped;
  final ValueChanged<User> onItemUser;

  const UserListTable({
    super.key,
    required this.onItemTapped,
    required this.onTitleTapped,
    required this.onItemUser,
    required this.filter,
  });

  @override
  State<UserListTable> createState() => _UserListTableState();
}

class _UserListTableState extends State<UserListTable> {
  int _currentPage = 1;
  final int _itemsPerPage = 10;
  final int _maxPageButtons = 3;
  List<User> allUser = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchAllUsers();
  }

  @override
  void didUpdateWidget(UserListTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reset to first page when filter changes
    if (oldWidget.filter != widget.filter) {
      setState(() {
        _currentPage = 1;
      });
    }
  }

  Future<void> _fetchAllUsers() async {
    if (mounted) setState(() => _isLoading = true);
    try {
      allUser = await loadCachedUsers();
      if (mounted && allUser.isNotEmpty) {
        setState(() {});
      }
      final freshUsers = await fetchUsers();
      await cacheUsers(freshUsers);

      if (mounted) {
        setState(() {
          allUser = freshUsers;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading users: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Get filtered users based on selected roles
  List<User> get _filteredUsers {
    if (widget.filter.isEmpty) {
      return allUser;
    }

    return allUser.where((user) {
      return widget.filter.contains(user.role);
    }).toList();
  }

  List<User> get _currentPageStaff {
    final filteredUsers = _filteredUsers;
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = startIndex + _itemsPerPage;
    if (startIndex >= filteredUsers.length) {
      return [];
    }
    return filteredUsers.sublist(
        startIndex,
        endIndex > filteredUsers.length
            ? filteredUsers.length
            : endIndex);
  }

  int get _totalPages => (_filteredUsers.length / _itemsPerPage).ceil();

  // Calculate which page buttons to show
  List<int> get _visiblePageNumbers {
    if (_totalPages <= _maxPageButtons) {
      // If total pages are less than or equal to max buttons, show all pages
      return List.generate(_totalPages, (index) => index + 1);
    }

    // Calculate start and end of visible page range
    int start = _currentPage - (_maxPageButtons ~/ 2);
    int end = start + _maxPageButtons - 1;

    // Adjust if range is out of bounds
    if (start < 1) {
      start = 1;
      end = start + _maxPageButtons - 1;
    }

    if (end > _totalPages) {
      end = _totalPages;
      start = end - _maxPageButtons + 1;
      if (start < 1) start = 1;
    }

    return List.generate(end - start + 1, (index) => start + index);
  }

  void _showUserDetailsModal(BuildContext context, User user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return UserInfoFields(
          user: user,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'Users: ${_filteredUsers.length}', // Show filtered count
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // Optional: Show filter status
                if (widget.filter.isNotEmpty) ...[
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Filtered (${widget.filter.length} roles)',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: constraints.maxWidth),
                    child: _isLoading && allUser.isEmpty
                        ? Center(child: CircularProgressIndicator(color: primaryColor))
                        : _filteredUsers.isEmpty
                        ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.filter_list_off,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No users match the selected filters',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )
                        : DataTable(
                      columnSpacing: 16,
                      headingRowColor:
                      MaterialStateProperty.all(Colors.grey[200]),
                      columns: const [
                        DataColumn(
                            label: Text('Full name',
                                style: TextStyle(fontSize: 12))),
                        DataColumn(
                            label: Text('Email',
                                style: TextStyle(fontSize: 12))),
                        DataColumn(
                            label: Text('Phone Number',
                                style: TextStyle(fontSize: 12))),
                        DataColumn(
                            label: Text('Role',
                                style: TextStyle(fontSize: 12))),
                        DataColumn(
                            label: Text('ID', style: TextStyle(fontSize: 12))),
                        DataColumn(
                            label: Expanded(
                                child: Text('Actions',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 12))))
                      ],
                      rows: _currentPageStaff
                          .map((user) => DataRow(
                        cells: [
                          DataCell(onTap: () {
                            widget.onItemTapped(8);
                            widget.onTitleTapped("User Details");
                            widget.onItemUser(user);
                          },
                              Text(user.fullName,
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700))),
                          DataCell(Text(user.email,
                              style: const TextStyle(fontSize: 12))),
                          DataCell(Text(user.phoneNumber,
                              style: const TextStyle(fontSize: 12))),
                          DataCell(Text(user.role,
                              style: const TextStyle(fontSize: 12))),
                          DataCell(Text(user.id,
                              style: const TextStyle(fontSize: 12))),
                          DataCell(Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            spacing: 4,
                            children: [
                              IconButton(
                                  onPressed: () {
                                    _showUserDetailsModal(
                                        context, user);
                                  },
                                  icon: Icon(Icons.edit, size: 18))
                            ],
                          ))
                        ],
                      ))
                          .toList(),
                    ),
                  ),
                );
              },
            ),
          ),
          // Only show pagination if there are filtered results
          if (_filteredUsers.isNotEmpty && _totalPages > 1)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: _currentPage > 1
                        ? () {
                      setState(() {
                        _currentPage--;
                      });
                    }
                        : null,
                    tooltip: 'Previous',
                  ),
                  // Show first page button if not in visible range
                  if (_visiblePageNumbers.isNotEmpty &&
                      _visiblePageNumbers.first > 1)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          backgroundColor: Colors.grey[200],
                          foregroundColor: Colors.black,
                          minimumSize: const Size(40, 40),
                          padding: EdgeInsets.zero,
                        ),
                        onPressed: () {
                          setState(() {
                            _currentPage = 1;
                          });
                        },
                        child: const Text('1'),
                      ),
                    ),
                  // Show ellipsis if there's a gap between first page and visible range
                  if (_visiblePageNumbers.isNotEmpty &&
                      _visiblePageNumbers.first > 2)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.0),
                      child: Text('...'),
                    ),
                  // Show the visible page buttons
                  for (int i in _visiblePageNumbers)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          backgroundColor:
                          _currentPage == i ? Colors.blue : Colors.grey[200],
                          foregroundColor:
                          _currentPage == i ? Colors.white : Colors.black,
                          minimumSize: const Size(40, 40),
                          padding: EdgeInsets.zero,
                        ),
                        onPressed: () {
                          setState(() {
                            _currentPage = i;
                          });
                        },
                        child: Text(i.toString()),
                      ),
                    ),
                  // Show ellipsis if there's a gap between visible range and last page
                  if (_visiblePageNumbers.isNotEmpty &&
                      _visiblePageNumbers.last < _totalPages - 1)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.0),
                      child: Text('...'),
                    ),
                  // Show last page button if not in visible range
                  if (_visiblePageNumbers.isNotEmpty &&
                      _visiblePageNumbers.last < _totalPages)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          backgroundColor: Colors.grey[200],
                          foregroundColor: Colors.black,
                          minimumSize: const Size(40, 40),
                          padding: EdgeInsets.zero,
                        ),
                        onPressed: () {
                          setState(() {
                            _currentPage = _totalPages;
                          });
                        },
                        child: Text(_totalPages.toString()),
                      ),
                    ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward),
                    onPressed: _currentPage < _totalPages
                        ? () {
                      setState(() {
                        _currentPage++;
                      });
                    }
                        : null,
                    tooltip: 'Next',
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}