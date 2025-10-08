// dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../api/api_get.dart';
import '../constants.dart';
import '../models/class_applications.dart';
import '../responsive.dart';
import 'application_details.dart';

class ApplicationListTable extends StatefulWidget {
  final List<String> filter;
  final String userID;

  const ApplicationListTable({
    super.key,
    required this.userID,
    required this.filter,
  });

  @override
  State<ApplicationListTable> createState() => _ApplicationListTableState();
}

class _ApplicationListTableState extends State<ApplicationListTable> {
  int _currentPage = 1;
  final int _itemsPerPage = 10;
  final int _maxPageButtons = 3;
  bool _isLoading = false;

  List<Application> allApplications = [];
  List<Application> applications = [];
  List<Application> fetchedApplications = [];

  @override
  void initState() {
    super.initState();
    _loadApplications();
  }

  @override
  void didUpdateWidget(ApplicationListTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.filter != widget.filter) {
      setState(() {
        _currentPage = 1;
      });
    }
  }

  Future<void> _loadApplications() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Cached first
      final cached = await loadCachedApplications();
      if (cached.isNotEmpty && mounted) {
        final userApps = _filterByUser(cached);
        setState(() {
          fetchedApplications = cached;
          applications = userApps;
        });
      }

      // Fresh data
      final fresh = await getFeaturedApplications();
      if (!mounted) return;

      await cacheApplications(fresh);

      if (!mounted) return;

      final userApps = _filterByUser(fresh);
      setState(() {
        fetchedApplications = fresh;
        applications = userApps;
        _isLoading = false;
      });
    } catch (error) {
      debugPrint("Error loading applications: $error");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  List<Application> _filterByUser(List<Application> list) {
    final id = widget.userID;
    if (id.isEmpty) return list;
    return list.where((a) => a.adviser.id == id || a.client.id == id).toList();
  }

  // Filter applications based on selected visa types
  List<Application> get _filteredApplications {
    if (widget.filter.isEmpty) {
      return applications;
    }
    return applications.where((app) {
      return widget.filter.contains(app.stage);
    }).toList();
  }

  void _showApplicationDetailsModal(BuildContext context, Application app) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.9,
            child: ApplicationDetailsPreviewModal(application: app),
          ),
        );
      },
    );
  }

  List<Application> get _currentPageItems {
    final filtered = _filteredApplications;
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = startIndex + _itemsPerPage;
    if (startIndex >= filtered.length) {
      return [];
    }
    return filtered.sublist(startIndex, endIndex > filtered.length ? filtered.length : endIndex);
  }

  int get _totalPages => (_filteredApplications.length / _itemsPerPage).ceil();

  // Calculate which page buttons to show
  List<int> get _visiblePageNumbers {
    if (_totalPages <= _maxPageButtons) {
      return List.generate(_totalPages, (index) => index + 1);
    }

    int start = _currentPage - (_maxPageButtons ~/ 2);
    int end = start + _maxPageButtons - 1;

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

  String _fmt(DateTime? dt) {
    if (dt == null) return '—';
    final local = dt.toLocal();
    final y = local.year.toString().padLeft(4, '0');
    final m = local.month.toString().padLeft(2, '0');
    final d = local.day.toString().padLeft(2, '0');
    return "$y-$m-$d";
  }
  Color _getProgressColor(int progress) {
    if (progress < 20) return Colors.red;
    if (progress < 50) return Colors.orange;
    if (progress < 70) return Colors.yellow;
    if (progress < 90) return Colors.green;
    return Colors.blue;
  }
  @override
  Widget build(BuildContext context) {
    return widget.userID.isNotEmpty && _filteredApplications.isEmpty && !_isLoading
        ?  Container(
      height: 692,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 12,
        children: [
          SvgPicture.asset("assets/icons/applications.svg",height: 120,color: Colors.grey),
          Text("No Application(s) At The Moment")
        ]),)
        : Container(
      decoration: const BoxDecoration(
        color: secondaryColor,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      'Applications Found: ${_filteredApplications.length}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (widget.filter.isNotEmpty) ...[
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Filtered (${widget.filter.length} Visa Type)',
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
                if (!Responsive.isMobile(context)) const SizedBox(width: 10),
                OutlinedButton.icon(
                  onPressed: () {
                    // TODO: Export to Excel with applications data
                  },
                  icon: const Icon(Icons.download, color: Colors.blue),
                  label: const Text(
                    'Export to Excel',
                    style: TextStyle(color: Colors.blue),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.blue),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                ),
              ],
            ),
          ),
          // Table
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: constraints.maxWidth),
                    child: _isLoading && applications.isEmpty
                        ? Center(child: CircularProgressIndicator(color: primaryColor))
                        : _filteredApplications.isEmpty
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
                            'No applications match the selected filters',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )
                        : DataTable(
                      columnSpacing: 8,
                      headingRowColor: MaterialStateProperty.all(Colors.grey[200]),
                      columns: const [
                        DataColumn(label: Text('Client', style: TextStyle(fontSize: 12))),
                        DataColumn(label: Text('Adviser', style: TextStyle(fontSize: 12))),
                        DataColumn(label: Text('Visa Type', style: TextStyle(fontSize: 12))),
                        DataColumn(label: Text('Stage', style: TextStyle(fontSize: 12))),
                        DataColumn(label: SizedBox(width: 120, child: Text('Progress', style: TextStyle(fontSize: 12)))),
                        DataColumn(label: Text('Consultation ID', style: TextStyle(fontSize: 12))),
                        DataColumn(label: Text('Created', style: TextStyle(fontSize: 12))),
                        DataColumn(label: Text('Updated', style: TextStyle(fontSize: 12))),
                        DataColumn(
                          label: SizedBox(width: 100,
                            child: Text('Actions', textAlign: TextAlign.center, style: TextStyle(fontSize: 12)),
                          ),
                        ),
                      ],
                      rows: _currentPageItems.map((app) {
                        final clientName = app.client.fullName.isNotEmpty
                            ? app.client.fullName
                            : (app.client.email.isNotEmpty ? app.client.email : 'Client');
                        final adviserName = app.adviser.fullName.isNotEmpty
                            ? app.adviser.fullName
                            : (app.adviser.email.isNotEmpty ? app.adviser.email : 'Adviser');

                        return DataRow(cells: [
                          DataCell(
                            GestureDetector(
                              onTap: () => _showApplicationDetailsModal(context, app),
                              child: Text(clientName, style: const TextStyle(fontSize: 12, color: Colors.blue)),
                            ),
                          ),
                          DataCell(Text(adviserName, style: const TextStyle(fontSize: 12))),
                          DataCell(Text(app.visaType, style: const TextStyle(fontSize: 12))),
                          DataCell(Text(app.stage, style: const TextStyle(fontSize: 12))),
                          DataCell(Row(
                            spacing:8,
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: LinearProgressIndicator(
                                    value: app.progress / 100,
                                    backgroundColor: Colors.grey[200],
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      _getProgressColor(app.progress),
                                    ),
                                    minHeight: 8,
                                  ),
                                ),
                              ),
                              Text("${app.progress}%", style: const TextStyle(fontSize: 12)),
                              SizedBox(width: 20,)
                            ],
                          )),
                          DataCell(SizedBox(
                            width: 120,
                            child: Text(app.consultationId, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
                          )),
                          DataCell(Text(_fmt(app.createdAt), style: const TextStyle(fontSize: 12))),
                          DataCell(Text(_fmt(app.updatedAt), style: const TextStyle(fontSize: 12))),
                          DataCell(
                            SizedBox(width:100,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    onPressed: () => _showApplicationDetailsModal(context, app),
                                    icon: const Icon(Icons.file_open, size: 18),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ]);
                      }).toList(),
                    ),
                  ),
                );
              },
            ),
          ),
          // Pagination
          if (_filteredApplications.isNotEmpty && _totalPages > 1)
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
                  if (_visiblePageNumbers.isNotEmpty && _visiblePageNumbers.first > 1)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
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
                  if (_visiblePageNumbers.isNotEmpty && _visiblePageNumbers.first > 2)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.0),
                      child: Text('...'),
                    ),
                  for (int i in _visiblePageNumbers)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          backgroundColor: _currentPage == i ? Colors.blue : Colors.grey[200],
                          foregroundColor: _currentPage == i ? Colors.white : Colors.black,
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
                  if (_visiblePageNumbers.isNotEmpty && _visiblePageNumbers.last < _totalPages - 1)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.0),
                      child: Text('...'),
                    ),
                  if (_visiblePageNumbers.isNotEmpty && _visiblePageNumbers.last < _totalPages)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
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