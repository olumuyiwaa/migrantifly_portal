import 'package:Migrantifly/components/forms/book_consultation.dart';
import 'package:Migrantifly/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'dart:convert';

import '../../api/api_get.dart';
import '../../api/api_post.dart';
import '../../models/class_consultation.dart';

// Consultations List Screen
class ClientConsultations extends StatefulWidget {
  const ClientConsultations({
    super.key,
  });

  @override
  State<ClientConsultations> createState() => _ClientConsultationsState();
}

class _ClientConsultationsState extends State<ClientConsultations> {
  List<Consultation> _consultations = [];
  bool _isLoading = true;
  String? _error;
  String _selectedStatus = 'all';
  int _currentPage = 1;
  int _totalPages = 1;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadConsultations();
  }

  Future<void> _loadConsultations() async {
    if (mounted) setState(() => _isLoading = true);
    try {
      _consultations = await loadCachedConsultations();
      if (mounted && _consultations.isNotEmpty) {
        setState(() {
          _isLoading = false;
        });
      }
      final freshConsultations = await fetchConsultations();
      await cacheConsultations(freshConsultations);

      if (mounted) {
        setState(() {
          _consultations = freshConsultations;
          if (_consultations.isNotEmpty && _currentPage == -1) {
            _currentPage = 1;
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching data: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<Consultation> get _filteredConsultations {
    return _consultations.where((consultation) {
      final matchesStatus = _selectedStatus == 'all' ||
          consultation.status == _selectedStatus;
      final matchesSearch = _searchQuery.isEmpty ||
          consultation.adviser?.fullName
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) == true ||
          consultation.method
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());
      return matchesStatus && matchesSearch;
    }).toList();
  }

  void _onStatusFilterChanged(String? status) {
    if (status != null) {
      setState(() {
        _selectedStatus = status;
        _currentPage = 1;
      });
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _currentPage = 1;
    });
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
    _loadConsultations();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);

    return SizedBox(
      height: MediaQuery.of(context).size.height - 100,
      child: Column(
        children: [
          // Header Section
          Container(
            clipBehavior: Clip.hardEdge,
            padding: EdgeInsets.all(isMobile ? 16 : 24),
            decoration: BoxDecoration(
              color: Colors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(12),topRight: Radius.circular(12)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_month, size: isMobile ? 24 : 28,
                        color: Colors.blue[700]),
                    SizedBox(width: isMobile ? 8 : 12),
                    Text(
                      'My Consultations',
                      style: TextStyle(
                        fontSize: isMobile ? 20 : 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    Spacer(),
                    ElevatedButton(onPressed: (){
                      // Show the modal
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => BookConsultationModal(
                          onClose: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      );
                    },style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 8,horizontal: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
                    ), child: Text("Book New",style: TextStyle(color: Colors.white),))
                  ],
                ),
                if (!_isLoading) ...[
                  const SizedBox(height: 8),
                  Text(
                    '${_filteredConsultations.length} consultation${_filteredConsultations.length != 1 ? 's' : ''}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(height: 4,),
          // Filter Bar
          _buildFilterBar(),

          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? _buildErrorWidget()
                : _filteredConsultations.isEmpty
                ? _buildEmptyWidget()
                : _buildConsultationsList(),
          ),

          if (!_isLoading && _filteredConsultations.isNotEmpty)
            _buildPagination(),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    final isMobile = Responsive.isMobile(context);

    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(12),bottomRight: Radius.circular(12))
      ),
      child: Column(
        children: [
          if (!isMobile)
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _buildSearchField(),
                ),
                const SizedBox(width: 16),
                SizedBox(
                  width: 200,
                  child: _buildStatusDropdown(),
                ),
              ],
            )
          else ...[
            _buildSearchField(),
            const SizedBox(height: 12),
            _buildStatusDropdown(),
          ],
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      onChanged: _onSearchChanged,
      decoration: InputDecoration(
        hintText: 'Search by adviser or method...',
        prefixIcon: const Icon(Icons.search, color: Colors.grey),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildStatusDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedStatus,
      decoration: InputDecoration(
        labelText: 'Status',
        prefixIcon: const Icon(Icons.filter_list, size: 20),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      items: const [
        DropdownMenuItem(value: 'all', child: Text('All Status')),
        DropdownMenuItem(value: 'scheduled', child: Text('Scheduled')),
        DropdownMenuItem(value: 'completed', child: Text('Completed')),
        DropdownMenuItem(value: 'cancelled', child: Text('Cancelled')),
      ],
      onChanged: _onStatusFilterChanged,
    );
  }

  Widget _buildConsultationsList() {
    final isMobile = Responsive.isMobile(context);

    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical:  16),
      itemCount: _filteredConsultations.length,
      itemBuilder: (context, index) {
        return AnimatedOpacity(
          opacity: 1.0,
          duration: const Duration(milliseconds: 300),
          child: ConsultationCard(
            consultation: _filteredConsultations[index],
            isMobile: isMobile,
            onTap: () => _showConsultationDetails(_filteredConsultations[index]),
          ),
        );
      },
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.event_busy, size: 64, color: Colors.blue[300]),
          ),
          const SizedBox(height: 24),
          Text(
            _searchQuery.isNotEmpty || _selectedStatus != 'all'
                ? 'No consultations match your filters'
                : 'No consultations found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty || _selectedStatus != 'all'
                ? 'Try adjusting your search or filters'
                : 'Your consultations will appear here',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red[50],
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
            ),
            const SizedBox(height: 24),
            Text(
              'Error loading consultations',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? 'Something went wrong',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadConsultations,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPagination() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: _currentPage > 1 ? () => _onPageChanged(_currentPage - 1) : null,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Previous',style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              )),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Page $_currentPage of $_totalPages',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _currentPage < _totalPages ? () => _onPageChanged(_currentPage + 1) : null,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Next',style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            )),
          ),
        ],
      ),
    );
  }

  void _showConsultationDetails(Consultation consultation) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(32),backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SizedBox(
          width: 650,
          child: ConsultationDetailsDialog(consultation: consultation),
        ),
      ),
    );
  }
}

// Consultation Card Widget
class ConsultationCard extends StatelessWidget {
  final Consultation consultation;
  final bool isMobile;
  final VoidCallback onTap;

  const ConsultationCard({
    Key? key,
    required this.consultation,
    required this.isMobile,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: isMobile ? _buildMobileLayout() : _buildDesktopLayout(),
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildStatusChip(),
            _buildMethodChip(),
          ],
        ),
        const SizedBox(height: 16),
        _buildDateInfo(),
        if (consultation.adviser != null) ...[
          const SizedBox(height: 16),
          _buildAdviserInfo(),
        ],
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: _buildDateInfo(),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: _buildMethodChip(),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: _buildStatusChip(),
        ),
        const SizedBox(width: 16),
        if (consultation.adviser != null)
          Expanded(
            flex: 3,
            child: _buildAdviserInfo(),
          ),
        const SizedBox(width: 12),
        Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
      ],
    );
  }

  Widget _buildDateInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.calendar_today, size: 18, color: Colors.blue[700]),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatDate(consultation.scheduledDate),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(
                      _formatTime(consultation.scheduledDate),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMethodChip() {
    final icons = {
      'zoom': Icons.videocam,
      'phone': Icons.phone,
      'in-person': Icons.location_on,
    };

    final colors = {
      'zoom': Colors.purple,
      'phone': Colors.green,
      'in-person': Colors.orange,
    };

    final color = colors[consultation.method] ?? Colors.blue;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icons[consultation.method] ?? Icons.help_outline,
              size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            _capitalizeMethod(consultation.method),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip() {
    final colors = {
      'scheduled': Colors.orange,
      'completed': Colors.green,
      'cancelled': Colors.red,
    };

    final color = colors[consultation.status] ?? Colors.grey;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            consultation.status.toUpperCase(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdviserInfo() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.person, size: 18, color: Colors.grey[700]),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Adviser',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                consultation.adviser!.fullName,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _formatTime(DateTime date) {
    final hour = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  String _capitalizeMethod(String method) {
    if (method == 'in-person') return 'In-Person';
    return method[0].toUpperCase() + method.substring(1);
  }
}

class ConsultationDetailsDialog extends StatelessWidget {
  final Consultation consultation;

  const ConsultationDetailsDialog({super.key, required this.consultation});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Consultation Details',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.grey[100],
                  ),
                ),
              ],
            ),
            const Divider(height: 32),

            _buildDetailRow(
                Icons.calendar_today, 'Date', _formatDate(consultation.scheduledDate)),
            _buildDetailRow(
                Icons.access_time, 'Time', _formatTime(consultation.scheduledDate)),
            _buildDetailRow(
                Icons.videocam, 'Method', _capitalizeMethod(consultation.method)),
            _buildDetailRow(
                Icons.info_outline, 'Status', consultation.status.toUpperCase()),

            if (consultation.adviser != null) ...[
              const Divider(height: 32),
              Text(
                'Adviser Information',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildDetailRow(
                  Icons.person, 'Name', consultation.adviser!.fullName),
              _buildDetailRow(Icons.email, 'Email', consultation.adviser!.email),
            ],

            if (consultation.visaPathways.isNotEmpty) ...[
              const Divider(height: 32),
              Text(
                'Recommended Visa Pathways',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ...consultation.visaPathways.map(
                    (pathway) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[100]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.verified, color: Colors.blue[700], size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "${pathway.capitalizeWords()} Pathway",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[800],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            if (consultation.notes.isNotEmpty) ...[
              const Divider(height: 32),
              Text(
                'Notes',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Text(
                  consultation.notes,
                  style: TextStyle(
                    height: 1.5,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 32),
            Row(
                spacing: 12,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if(consultation.status.toLowerCase().contains("pending_payment"))
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Make Payment'),
                    ),
                  if(consultation.status.toLowerCase().contains("complete"))
                ElevatedButton(
                  onPressed: (){
                      String? selectedVisaType;
                      showDialog(
                        context: context,
                        builder: (context) {
                          return StatefulBuilder(
                            builder: (context, setState) {
                              return AlertDialog(
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                title: const Text('Apply for visa'),
                                content: SizedBox(
                                  width: 400,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SvgPicture.asset("assets/icons/applications.svg",height: 64,color: Colors.grey),
                                      const SizedBox(height: 16),

                                      // Dropdown for selecting type
                                      DropdownButtonFormField<String>(
                                        decoration: const InputDecoration(
                                          labelText: "Visa Type",
                                          border: OutlineInputBorder(),
                                        ),
                                        value: selectedVisaType,
                                        items: consultation.visaPathways
                                            .map((type) =>
                                            DropdownMenuItem(value: type, child: Text(type.capitalizeWords())))
                                            .toList(),
                                        onChanged: (value) => setState(() => selectedVisaType = value),
                                      ),

                                    ],
                                  ),
                                ),
                                actions: [
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    onPressed: () => Navigator.of(context).pop(),
                                    child: const Text('Cancel'),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    onPressed: selectedVisaType != null
                                        ? () {postApplication(context,consultation.id,selectedVisaType!);}
                                        : null,
                                    child:  Text('Submit',style: TextStyle(color: selectedVisaType != null ? Colors.white : Colors.grey),),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Create Application',style: TextStyle(color: Colors.white),),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Close'),
                )
              ],),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: Colors.blue[700]),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
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

  String _formatDate(DateTime date) {
    final months = ['January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'];
    return "${months[date.month - 1]} ${date.day}, ${date.year}";
  }

  String _formatTime(DateTime date) {
    final hour = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  String _capitalizeMethod(String method) =>
      method == 'in-person'
          ? 'In-Person'
          : method[0].toUpperCase() + method.substring(1);
}

extension StringCasingExtension on String {
  String capitalizeWords() {
    return split("_")
        .map((word) =>
    word.isNotEmpty ? "${word[0].toUpperCase()}${word.substring(1)}" : "")
        .join(" ");
  }
}