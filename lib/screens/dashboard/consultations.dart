import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../api/api_get.dart';
import '../../components/consultation_page.dart';
import '../../components/consultation_page.dart';
// import '../../components/forms/consultation_details_form.dart';
import '../../constants.dart';
import '../../models/class_consultation.dart';
import '../../models/class_users.dart';

class Consultations extends StatefulWidget {
  const Consultations({super.key});

  @override
  State<Consultations> createState() => _ConsultationsState();
}

class _ConsultationsState extends State<Consultations> {
  int _selectedIndex = -1; // Initialize to -1 instead of 0
  bool _isWideScreen = true;
  final TextEditingController _messageController = TextEditingController();
  bool _isLoadingConsultations = true;
  bool isLoggedIn = false;
  List<Consultation> consultations = [];
  Map<String, String> translatedNames = {};
  String? role;
  String presentCountry = "";
  TextEditingController searchText = TextEditingController();
  String searchQuery = "";
  bool typing = false;

  @override
  void initState() {
    super.initState();
    _fetchAllData();
    _updateScreenSize();
  }

  void _showConsultationFormModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(16.0),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.9,
            // child: ConsultationDetailsForm(
            //   consultation: Consultation.empty(),
            //   isEditing: false,
            //   onSave: () {
            //     _fetchAllData();
            //   },
            // ),
          ),
        );
      },
    );
  }

  List<User> allUsers = [];

  Future<void> _fetchAllData() async {
    if (mounted) setState(() => _isLoadingConsultations = true);
    try {
      consultations = await loadCachedConsultations();
      if (mounted && consultations.isNotEmpty) {
        setState(() {
          _isLoadingConsultations = false;
        });
      }
      final freshConsultations = await fetchConsultations();
      await cacheConsultations(freshConsultations);

      if (mounted) {
        setState(() {
          consultations = freshConsultations;
          // Auto-select first consultation if available and none selected
          if (consultations.isNotEmpty && _selectedIndex == -1) {
            _selectedIndex = 0;
          }
          _isLoadingConsultations = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching data: $e');
      if (mounted) {
        setState(() => _isLoadingConsultations = false);
      }
    }
  }

  Future<bool> isUserLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('token');
  }

  void _updateScreenSize() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final width = MediaQuery.of(context).size.width;
      setState(() {
        _isWideScreen = width > 900;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    _updateScreenSize();

    return SizedBox(
        height: MediaQuery.of(context).size.height - 100,
        child: Row(
          spacing: defaultPadding,
          children: [
            if (_isWideScreen || !_isWideScreen && _selectedIndex == -1)
              Expanded(
                flex: 1,
                child: buildConsultationList(),
              ),
            if (_isWideScreen || !_isWideScreen && _selectedIndex != -1)
              Expanded(
                flex: 3,
                child: buildConsultationDetails(),
              ),
          ],
        ));
  }

  Widget buildConsultationList() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: _isLoadingConsultations
          ? const Center(
        child: CircularProgressIndicator(
          color: primaryColor,
        ),
      )
          : consultations.isEmpty
          ? const Center(
        child: Text("No Consultations available"),
      )
          : ListView.builder(
        itemCount: consultations.length,
        itemBuilder: (context, index) {
          return _buildConsultationListItem(consultations[index], index);
        },
      ),
    );
  }

  Widget _buildConsultationListItem(Consultation consultation, int index) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: _selectedIndex == index
              ? Colors.blue.withOpacity(0.09)
              : Colors.white,
          border: Border(
            bottom: BorderSide(color: Colors.grey.withOpacity(0.2), width: 1),
          ),
        ),
        child: Row(
          children: [
            _buildConsultationAvatar(consultation),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        consultation.type.isNotEmpty ? consultation.type : 'General Consultation',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getStatusColor(consultation.status),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          consultation.status,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.person, size: 12, color: Colors.grey[600]),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          consultation.client.fullName ?? 'Unknown Client',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                            overflow: TextOverflow.ellipsis,
                          ),
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 12, color: Colors.grey[600]),
                      SizedBox(width: 4),
                      Text(
                        DateFormat('MMM dd, yyyy').format(consultation.scheduledDate),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.access_time, size: 12, color: Colors.grey[600]),
                      SizedBox(width: 4),
                      Text(
                        '${consultation.duration}min',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'scheduled':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'in-progress':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Widget _buildConsultationAvatar(Consultation consultation) {
    // Use client's profile picture if available, otherwise use initials
    if (consultation.client.image.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.network(
          consultation.client.image,
          width: 52,
          height: 52,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildInitialsAvatar(consultation);
          },
        ),
      );
    } else {
      return _buildInitialsAvatar(consultation);
    }
  }

  Widget _buildInitialsAvatar(Consultation consultation) {
    String initials = '';
    if (consultation.client.fullName.isNotEmpty) {
      initials = consultation.client.fullName[0];
    } else {
      initials = 'C'; // Default to 'C' for Consultation
    }

    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: Colors.blue[100],
        borderRadius: BorderRadius.circular(20),
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          color: Colors.blue,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget buildConsultationDetails() {
    // Check if we have consultations and a valid selection
    if (consultations.isEmpty || _selectedIndex == -1 || _selectedIndex >= consultations.length) {
      return const Center(
        child: Text("Select a Consultation to View Details"),
      );
    }

    final selectedConsultation = consultations[_selectedIndex];
    return ConsultationPage(
      consultation: selectedConsultation,
      onChange: () {
        _fetchAllData();
      },
    );
  }
}