import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../api/api_delete.dart';
import '../api/api_get.dart';
import '../constants.dart';
import '../models/class_countries.dart';
import '../models/class_applications.dart';
import '../models/class_users.dart';
import 'forms/country_details_form.dart';


class CountryPage extends StatefulWidget {
  final Country country;
  final ValueChanged<int> onItemTapped;
  final ValueChanged<String> onTitleTapped;
  final ValueChanged<User> onItemUser;
  final Function() onChange;
  const CountryPage({
    super.key,
    required this.country,
    required this.onItemTapped,
    required this.onTitleTapped,
    required this.onItemUser,
    required this.onChange,
  });

  @override
  State<CountryPage> createState() => _CountryPageState();
}


class _CountryPageState extends State<CountryPage> {
  String countryTitle = "";
  String countryDescription = "";
  String countryPresident = "";
  String countryPopulation = "";
  String countryCapital = "";
  String countryCurrency = "";
  String countryImage = "";
  String countryDemonym = "";
  String countryLanguage = "";
  String countryTimeZone = "";
  String tutorialLink = "";
  String artCraftLink = "";
  String culturalDanceLink = "";
  String entityName = "";
  String associationLeaderName = "";
  String associationLeaderEmail = "";
  String associationLeaderPhone = "";
  String associationLeaderPhoto = "";
  String associationLeaderID = "";
  Country? countryDetails;

  List<Application> events = [];
  List<Application> allEvents = [];
  List<String> gallery = [];
  List<User> countryEntities = [];
  List<User> countryAmbassadors = [];
  List<User> fetchedUsers = [];
  bool _isLoading = true;
  String userID = "";
  void _showEditCountryFormModal(BuildContext context, Country country) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
            insetPadding: const EdgeInsets.all(16.0),
            child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.9,
                child: CountryDetailsForm(
                  country: country, isEditing: true, onSave: () {
                  widget.onChange();
                  _fetchCountryDetails();
                },
                )));
      },
    );
  }
  Future<void> _fetchCountryDetails() async {
    setState(() => _isLoading = true);
    try {
      // Fetch country details and users
      final country = widget.country;
      final users = await fetchUsers();

      if (country == null) {
        debugPrint("Country details are null");
        setState(() => _isLoading = false);
        return;
      }

      // Fetch events
      final fetchedEvents = await getFeaturedEvents();
      final now = DateTime.now();
      final upcoming = fetchedEvents.where((event) {
        if (event.createdAt == null) return false;
        try {
          DateTime eventDate = DateTime.parse(event.createdAt.toString());
          return eventDate.isAfter(now) || eventDate.isAtSameMomentAs(now);
        } catch (e) {
          debugPrint("Invalid event date: ${event.createdAt}, Error: $e");
          return false;
        }
      }).toList();

      // Update state safely
      setState(() {
        countryDetails = country;
        fetchedUsers = users;
        countryTitle = countryDetails!.title;
        countryDescription = countryDetails!.description;
        countryPopulation = countryDetails!.population;
        countryCapital = countryDetails!.capital;
        countryCurrency = countryDetails!.currency;
        countryDemonym = countryDetails!.demonym;
        countryLanguage = countryDetails!.language;
        countryTimeZone = countryDetails!.timeZone;

        countryImage = country.image ?? "";
        countryEntities = users
            .where((user) =>
        user.countries.contains(country.title) && user.role == "artist")
            .toList();
        // Find ambassadors
        countryAmbassadors = users
            .where((user) => user.representedCountry == country.title).toList();
        countryPresident = country.president ?? "";
        tutorialLink = country.link ?? "";
        artCraftLink = country.artCraft ?? "";
        culturalDanceLink = country.culturalDance ?? "";

        allEvents = upcoming;
        events = allEvents
            .where((event) =>
        event.adviser.fullName
            .toLowerCase()
            .contains(countryTitle.toLowerCase()))
            .toList();

        _isLoading = false;
      });
    } catch (error) {
      debugPrint("Error fetching country details: $error");
      setState(() => _isLoading = false);
    }
  }

  Future<void> showDeleteDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          title: Text("Delete"),
          content: Text("Are You Sure You Want To Delete This Country"),
          actions: <Widget>[
            TextButton(
              child: Text(
                "Cancel",
                style: TextStyle(color: Colors.green),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Delete", style: TextStyle(color: Colors.red)),
              onPressed: () {
                removeCountry(
                  context: context,
                  countryID: widget.country.id,
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchCountryDetails().then((_) => getUserInfo());
  }

  @override
  void didUpdateWidget(CountryPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.country.id != widget.country.id) {
      _fetchCountryDetails().then((_) => getUserInfo());
    }
  }

  Future<void> getUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userID = prefs.getString('id') ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: primaryColor))
          : countryDetails == null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Country Not Found"),
            InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                margin: const EdgeInsets.only(top: 16),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4)),
                padding: const EdgeInsets.symmetric(
                    vertical: 8, horizontal: 16),
                child: Text("Try Again"),
              ),
            )
          ],
        ),
      )
          : Column(
        children: [
          // Wiki-style header with navigation
          WikiHeader(
            countryTitle: countryTitle,
            onDelete: () => showDeleteDialog(context),
            onEdit: () {
              _showEditCountryFormModal(
                  context, widget.country);
            },
          ),
          Expanded(
            child: SingleChildScrollView(
              child: WikiContent(
                countryTitle: countryTitle,
                countryImage: countryImage,
                countryPresident: countryPresident,
                countryCapital: countryCapital,
                countryCurrency: countryCurrency,
                countryPopulation: countryPopulation,
                countryDemonym: countryDemonym,
                countryLanguage: countryLanguage,
                countryTimeZone: countryTimeZone,
                countryDescription: countryDescription,
                tutorialLink: tutorialLink,
                artCraftLink: artCraftLink,
                culturalDanceLink: culturalDanceLink,
                associationLeaderName: associationLeaderName,
                associationLeaderPhoto: associationLeaderPhoto,
                events: events,
                countryEntities: countryEntities,onItemTapped: (int index) {
                widget.onItemTapped(index);
              },
                  onTitleTapped: (String title) {
                    widget.onTitleTapped(title);
                  },
                  onItemUser: (User user) {
                    widget.onItemUser(user);
                  }
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WikiHeader extends StatelessWidget {
  final String countryTitle;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const WikiHeader({
    super.key,
    required this.countryTitle,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!, width: 1),
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            // Title and actions
            Row(
              children: [
                Expanded(
                  child: Text(
                    countryTitle,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Georgia',
                    ),
                  ),
                ),
                // Action buttons
                Row(
                  children: [
                    IconButton(
                      onPressed: onEdit,
                      icon: Icon(Icons.edit_outlined, color: Colors.grey[600]),
                      tooltip: "Edit",
                    ),
                    IconButton(
                      onPressed: onDelete,
                      icon: Icon(Icons.delete_outline, color: Colors.red[400]),
                      tooltip: "Delete",
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Article status bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                border: Border.all(color: Colors.blue[200]!),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: Colors.blue[700]),
                  const SizedBox(width: 8),
                  Text(
                    "This page is for modifying the details of the country: $countryTitle.",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue[700],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WikiContent extends StatelessWidget {
  final String countryTitle;
  final String countryImage;
  final String countryPresident;
  final String countryCapital;
  final String countryCurrency;
  final String countryPopulation;
  final String countryDemonym;
  final String countryLanguage;
  final String countryTimeZone;
  final String countryDescription;
  final String tutorialLink;
  final String artCraftLink;
  final String culturalDanceLink;
  final String associationLeaderName;
  final String associationLeaderPhoto;
  final List<Application> events;
  final List<User> countryEntities;
  final ValueChanged<int> onItemTapped;
  final ValueChanged<String> onTitleTapped;
  final ValueChanged<User> onItemUser;

  const WikiContent({
    super.key,
    required this.countryTitle,
    required this.countryImage,
    required this.countryPresident,
    required this.countryCapital,
    required this.countryCurrency,
    required this.countryPopulation,
    required this.countryDemonym,
    required this.countryLanguage,
    required this.countryTimeZone,
    required this.countryDescription,
    required this.tutorialLink,
    required this.artCraftLink,
    required this.culturalDanceLink,
    required this.associationLeaderName,
    required this.associationLeaderPhoto,
    required this.events,
    required this.countryEntities, required this.onItemTapped, required this.onTitleTapped, required this.onItemUser,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main content area (left side)
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),

                // Overview Section
                WikiSection(
                  title: "Overview",
                  content: countryDescription,
                ),
                const SizedBox(height: 24),

                // Government Section
                if (countryPresident.isNotEmpty)
                  WikiSection(
                    title: "Government",
                    content: "Current president of $countryTitle: $countryPresident.",
                  ),
                const SizedBox(height: 24),

                // Culture Section
                WikiSection(
                  title: "Culture",
                  content: "Cultural heritage of $countryTitle:",
                ),
                const SizedBox(height: 16),

                // Cultural Links
                WikiCulturalLinks(
                  tutorialLink: tutorialLink,
                  artCraftLink: artCraftLink,
                  culturalDanceLink: culturalDanceLink,
                ),
                const SizedBox(height: 24),

                // Events Section
                if (events.isNotEmpty)
                  WikiEventsSection(events: events),

              ],
            ),
          ),

          const SizedBox(width: 24),

          // Sidebar (right side)
          Expanded(
            flex: 1,
            child: Column(
              children: [
                WikiInfoBox(
                  countryTitle: countryTitle,
                  countryImage: countryImage,
                  countryCapital: countryCapital,
                  countryCurrency: countryCurrency,
                  countryPopulation: countryPopulation,
                  countryLanguage: countryLanguage,
                  countryTimeZone: countryTimeZone,
                  countryDemonym: countryDemonym,
                  associationLeaderName: associationLeaderName,
                  associationLeaderPhoto: associationLeaderPhoto,
                ),

                // Entities Section
                if (countryEntities.isNotEmpty)
                  WikiEntitiesSection(entities: countryEntities, onItemTapped: (int index) {
                    onItemTapped(index);
                  },
                      onTitleTapped: (String title) {
                        onTitleTapped(title);
                      },
                      onItemUser: (User user) {
                        onItemUser(user);
                      },),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class WikiSection extends StatelessWidget {
  final String title;
  final String content;

  const WikiSection({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.grey[300]!, width: 2),
            ),
          ),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w400,
              fontFamily: 'Georgia',
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          content,
          style: const TextStyle(
            fontSize: 16,
            height: 1.6,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}

class WikiInfoBox extends StatelessWidget {
  final String countryTitle;
  final String countryImage;
  final String countryCapital;
  final String countryCurrency;
  final String countryPopulation;
  final String countryLanguage;
  final String countryTimeZone;
  final String countryDemonym;
  final String associationLeaderName;
  final String associationLeaderPhoto;

  const WikiInfoBox({
    super.key,
    required this.countryTitle,
    required this.countryImage,
    required this.countryCapital,
    required this.countryCurrency,
    required this.countryPopulation,
    required this.countryLanguage,
    required this.countryTimeZone,
    required this.countryDemonym,
    required this.associationLeaderName,
    required this.associationLeaderPhoto,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            ),
            child: Text(
              countryTitle,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // Country Image
          if (countryImage.isNotEmpty)
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(countryImage),
                  fit: BoxFit.cover,
                ),
              ),
            ),

          // Info rows
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                _buildInfoRow("Capital:", countryCapital),
                _buildInfoRow("Language:", countryLanguage),
                _buildInfoRow("Currency:", countryCurrency),
                _buildInfoRow("Population:", countryPopulation),
                _buildInfoRow("Demonym:", countryDemonym),
                _buildInfoRow("Time Zone:", countryTimeZone),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 84,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

class WikiCulturalLinks extends StatelessWidget {
  final String tutorialLink;
  final String artCraftLink;
  final String culturalDanceLink;

  const WikiCulturalLinks({
    super.key,
    required this.tutorialLink,
    required this.artCraftLink,
    required this.culturalDanceLink,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        border: Border.all(color: Colors.blue[200]!),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "External Links",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          _buildExternalLink("Traditional Cuisines", tutorialLink),
          _buildExternalLink("Arts & Crafts", artCraftLink),
          _buildExternalLink("Cultural Dances", culturalDanceLink),
        ],
      ),
    );
  }

  Widget _buildExternalLink(String title, String url) {
    if (url.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: InkWell(
        onTap: () {
          launchUrl(Uri.parse(url.startsWith('http') ? url : 'https://$url'));
        },
        child: Row(
          children: [
            Icon(Icons.open_in_new, size: 16, color: Colors.blue[700]),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: Colors.blue[700],
                decoration: TextDecoration.underline,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WikiEventsSection extends StatelessWidget {
  final List<Application> events;

  const WikiEventsSection({
    super.key,
    required this.events,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        WikiSection(
          title: "Upcoming Events",
          content: "Cultural and community events taking place:",
        ),
        const SizedBox(height: 16),
        ...events.take(3).map((event) => _buildEventItem(event)),
      ],
    );
  }

  Widget _buildEventItem(Application event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            event.visaType,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            event.createdAt.toString(),
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
          if (event.stage.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              event.stage,
              style: const TextStyle(fontSize: 14),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}

class WikiEntitiesSection extends StatelessWidget {
  final List<User> entities;
  final ValueChanged<int> onItemTapped;
  final ValueChanged<String> onTitleTapped;
  final ValueChanged<User> onItemUser;

  const WikiEntitiesSection({
    super.key,
    required this.entities, required this.onItemTapped, required this.onTitleTapped, required this.onItemUser,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        WikiSection(
          title: "Notable People",
          content: "Artists and cultural figures from this country:",
        ),
        const SizedBox(height: 16),
        ...entities.take(5).map((entity) => _buildEntityItem(entity)),
      ],
    );
  }

  Widget _buildEntityItem(User entity) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.person, size: 16),
          const SizedBox(width: 8),
         TextButton(onPressed:  () {
    onItemTapped(8);
    onTitleTapped("User Details");
    onItemUser(entity);
    }, child: Text(
            entity.fullName ?? "Unknown",
            style: TextStyle(
              color: Colors.blue[700],
              decoration: TextDecoration.underline,
            ),
          )),
        ],
      ),
    );
  }
}