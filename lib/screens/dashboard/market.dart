import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../api/api_get.dart';
import '../../components/business_page.dart';
import '../../components/country_page.dart';
import '../../components/forms/business_details_form.dart';
import '../../constants.dart';
import '../../models/class_business.dart';
import '../../models/class_users.dart';

class Market extends StatefulWidget {
  const Market({super.key});

  @override
  State<Market> createState() => _MarketState();
}


class _MarketState extends State<Market> {
  int _selectedIndex = -1; // Initialize to -1 instead of 0
  bool _isWideScreen = true;
  final TextEditingController _messageController = TextEditingController();
  bool _isLoadingMarket = true;
  bool isLoggedIn = false;
  List<Business> businesses = [];
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

  void _showBusinessFormModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(16.0),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.9,
            child: BusinessDetailsForm(
              business: Business.empty(), isEditing: false, onSave: () {_fetchAllData();  },
            ),
          ),
        );
      },
    );
  }

  List<User> allUsers = [];
  Future<void> _fetchAllData() async {
    if (mounted) setState(() => _isLoadingMarket = true);
    try {
      businesses = await loadCachedBusinesses();
      if (mounted &&  businesses.isNotEmpty) {
        setState(() {});
      }
      final freshBusinesses = await fetchBusinesses();
      await cacheBusinesses(freshBusinesses);

      if (mounted) {
        setState(() {
          businesses = freshBusinesses;
          // Auto-select first business if available and none selected
          if (businesses.isNotEmpty && _selectedIndex == -1) {
            _selectedIndex = 0;
          }
          _isLoadingMarket = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching data: $e');
      if (mounted) {
        setState(() => _isLoadingMarket = false);
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
                child: buildBusinessList(),
              ),
            if (_isWideScreen || !_isWideScreen && _selectedIndex != -1)
              Expanded(
                flex: 3,
                child: buildBusinessDetails(),
              ),
          ],
        ));
  }

  Widget buildBusinessList() {
    return Column(children:[

      ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        tileColor: Colors.green,
        onTap: (){_showBusinessFormModal(context);},
        leading:
        Icon(Icons.add,color: Colors.white,size: 24,)
        ,
        title: Text(
          "Create New Business",
          style: TextStyle(
            color:Colors.white,
          ),
        ),
      ),
      SizedBox(height:8),
      Expanded(child:Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: _isLoadingMarket
            ? const Center(
          child: CircularProgressIndicator(color: primaryColor,),
        )
            : businesses.isEmpty
            ? const Center(
          child: Text("No Business available"),
        )
            : ListView.builder(
          itemCount: businesses.length,
          itemBuilder: (context, index) {
            return _buildBusinessListItem(businesses[index], index);
          },
        ),
      ))
    ]);
  }

  Widget _buildBusinessListItem(Business business, int index) {
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
            _buildCountryAvatar(business),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        business.businessTitle,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        business.businessLocation,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          business.webAddress.isNotEmpty?business.webAddress:business.businessAddress,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                            overflow: TextOverflow.ellipsis,
                          ),
                          maxLines: 1,
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

  Widget _buildCountryAvatar(Business business) {
    if (business.mediaFiles.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.network(
          business.mediaFiles[0],
          width: 52,
          height: 52,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildInitialsAvatar(business);
          },
        ),
      );
    } else {
      return _buildInitialsAvatar(business);
    }
  }

  Widget _buildInitialsAvatar(Business business) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: Colors.blue[100],
        borderRadius: BorderRadius.circular(20),
      ),
      alignment: Alignment.center,
      child: Text(
        business.businessTitle.isNotEmpty ? business.businessTitle[0] : '?',
        style: TextStyle(
          color: Colors.blue,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget buildBusinessDetails() {
    // Check if we have Market and a valid selection
    if (businesses.isEmpty || _selectedIndex == -1 || _selectedIndex >= businesses.length) {
      return const Center(
        child: Text("Select a Business to View Details"),
      );
    }

    final selectedBusiness = businesses[_selectedIndex];
    return BusinessPage(business: selectedBusiness, onChange: () {
      _fetchAllData();
    },);
  }
}