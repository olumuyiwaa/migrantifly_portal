import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../api/api_get.dart';
import '../../components/country_page.dart';
import '../../components/forms/country_details_form.dart';
import '../../constants.dart';
import '../../models/class_countries.dart';
import '../../models/class_users.dart';

class Countries extends StatefulWidget {
  final ValueChanged<int> onItemTapped;
  final ValueChanged<String> onTitleTapped;
  final ValueChanged<User> onItemUser;
  const Countries({super.key, required this.onItemTapped, required this.onTitleTapped, required this.onItemUser,});

  @override
  State<Countries> createState() => _CountriesState();
}

class _CountriesState extends State<Countries> {
  int _selectedIndex = -1; // Initialize to -1 instead of 0
  bool _isWideScreen = true;
  final TextEditingController _messageController = TextEditingController();
  bool _isLoadingCountries = true;
  bool _isLoadingUsers = true;
  bool isLoggedIn = false;
  List<Country> countries = [];
  Map<String, String> translatedNames = {};
  String? role;
  String presentCountry = "";
  TextEditingController searchText = TextEditingController();
  String searchQuery = "";
  bool typing = false;
  void _showCountryFormModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(16.0),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.9,
            child: CountryDetailsForm(
              country: Country.empty(), isEditing: false, onSave: () {_loadData();  },
            ),
          ),
        );
      },
    );
  }
  @override
  void initState() {
    super.initState();
    _loadData();
    _loadUsers();
    _updateScreenSize();
  }

  Future<void> _loadData() async {
    setState(() => _isLoadingCountries = true);
    // isLoggedIn = await isUserLoggedIn();
    await _loadCountries();
    setState(() => _isLoadingCountries = false);
  }

  Future<bool> isUserLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('token');
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoadingUsers = true);
    // await getUserInfo();
    setState(() => _isLoadingUsers = false);
  }
  //
  // Future<void> getUserInfo() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   role = prefs.getString('role');
  // }

  Future<void> _loadCountries() async {
    try {
      final fetchedCountries = await getCountries();
      setState(() {
        countries = fetchedCountries;
        // Auto-select first country if available and none selected
        if (countries.isNotEmpty && _selectedIndex == -1) {
          _selectedIndex = 0;
        }
      });

      await _translateCountryNames();
    } catch (e) {
      debugPrint("Error fetching countries: $e");
    }
  }

  Future<void> _translateCountryNames() async {
    Map<String, String> newTranslations = {};

    for (var country in countries) {
      try {
        String translated = country.title;
        newTranslations[country.id] = translated;
      } catch (e) {
        debugPrint("Translation error for ${country.title}: $e");
      }
    }

    countries.sort((a, b) {
      final aTranslated = newTranslations[a.id] ?? a.title;
      final bTranslated = newTranslations[b.id] ?? b.title;
      return aTranslated.toLowerCase().compareTo(bTranslated.toLowerCase());
    });

    setState(() {
      translatedNames = newTranslations;
    });
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
                child: _buildCountryList(),
              ),
            if (_isWideScreen || !_isWideScreen && _selectedIndex != -1)
              Expanded(
                flex: 3,
                child: _buildCountryDetail(),
              ),
          ],
        ));
  }

  Widget _buildCountryList() {
    return Column(children:[
      ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        tileColor: Colors.green,
        onTap: (){_showCountryFormModal(context);},
        leading:
        Icon(Icons.add,color: Colors.white,size: 24,)
        ,
        title: Text(
          "Create New Country",
          style: TextStyle(
            color:Colors.white,
          ),
        ),
      ),
      SizedBox(height:8)
      ,
    Expanded(child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: _isLoadingCountries
          ? const Center(
        child: CircularProgressIndicator(color: primaryColor,),
      )
          : countries.isEmpty
          ? const Center(
        child: Text("No countries available"),
      )
          :ListView.builder(
        itemCount: countries.length,
        itemBuilder: (context, index) {
          return _buildCountryListItem(countries[index], index);
        },
      ),
    )),

      ]);
  }

  Widget _buildCountryListItem(Country country, int index) {
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
            _buildCountryAvatar(country),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        country.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        country.capital,
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
                          "Population: ${country.population}",
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

  Widget _buildCountryAvatar(Country country) {
    if (country.image.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.network(
          country.image,
          width: 52,
          height: 52,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildInitialsAvatar(country);
          },
        ),
      );
    } else {
      return _buildInitialsAvatar(country);
    }
  }

  Widget _buildInitialsAvatar(Country country) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: Colors.blue[100],
        borderRadius: BorderRadius.circular(20),
      ),
      alignment: Alignment.center,
      child: Text(
        country.title.isNotEmpty ? country.title[0] : '?',
        style: TextStyle(
          color: Colors.blue,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildCountryDetail() {
    // Check if we have countries and a valid selection
    if (countries.isEmpty || _selectedIndex == -1 || _selectedIndex >= countries.length) {
      return const Center(
        child: Text("Select a Country to View Details"),
      );
    }

    final selectedCountry = countries[_selectedIndex];
    return CountryPage(
      country: selectedCountry,
      onItemTapped: (int index) {
      widget.onItemTapped(index);
    },
      onTitleTapped: (String title) {
        widget.onTitleTapped(title);
      },
      onItemUser: (User user) {
        widget.onItemUser(user);
      }, onChange: () {
      _loadData();
    },);
  }
}