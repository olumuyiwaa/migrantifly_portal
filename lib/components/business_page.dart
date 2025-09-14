import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../api/api_delete.dart';
import '../api/api_get.dart';
import '../models/class_business.dart';
import 'forms/business_details_form.dart';

class BusinessPage extends StatefulWidget {
  final Business business;
  final Function() onChange;
  const BusinessPage({
    super.key,
    required this.business,
    required this.onChange,
  });

  @override
  State<BusinessPage> createState() => _BusinessPageState();
}

class _BusinessPageState extends State<BusinessPage> {
  String businessTitle = "";
  String businessDescription = "";
  String businessLocation = "";
  String businessImage = "";
  String businessCategory = "";
  String facebookUsername = "";
  String twitterUsername = "";
  String instagramUsername = "";
  String linkedinUsername = "";
  String whatsappNumber = "";
  String websiteURL = "";
  String email = "";
  List<String> gallery = [];
  String? userID;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    getUserInfo().then((_) {
      _fetchBusinessDetails();
    });
  }

  @override
  void didUpdateWidget(BusinessPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Check if the business has changed
    if (oldWidget.business.businessTitle != widget.business.businessTitle ||
        oldWidget.business.businessDescription != widget.business.businessDescription) {
      // Re-fetch business details when business changes
      _fetchBusinessDetails();
    }
  }
  void _showEditBusinessFormModal(BuildContext context, Business business) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
            insetPadding: const EdgeInsets.all(16.0),
            child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.9,
                child: BusinessDetailsForm(
                  business: business, isEditing: true, onSave: () {
                    widget.onChange();
                    _fetchBusinessDetails(); },
                )));
      },
    );
  }

  Future<void> getUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userID = prefs.getString('id');
    });
  }

  Future<void> _fetchBusinessDetails() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final businessDetails = widget.business;
      businessTitle =  businessDetails.businessTitle;
      businessDescription = businessDetails.businessDescription;
      businessLocation = businessDetails.businessLocation;
      email = businessDetails.businessAddress;
      businessCategory =businessDetails.businessCategory;

      setState(() {
        businessImage = businessDetails.mediaFiles.isNotEmpty
            ? businessDetails.mediaFiles[0]
            : "";
        gallery = businessDetails.mediaFiles;
        facebookUsername = businessDetails.facebook;
        twitterUsername = businessDetails.twitter;
        instagramUsername = businessDetails.instagram;
        linkedinUsername = businessDetails.linkedIn;
        whatsappNumber = businessDetails.whatsapp;
        websiteURL = businessDetails.webAddress;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
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
          content: Text("Are You Sure You Want To Delete This Business"),
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
                removeBusiness(context: context, businessID: widget.business.id);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.blue))
          : Column(
        children: [
          // Wiki-style header
          WikiBusinessHeader(
            businessTitle: businessTitle,
            businessCategory: businessCategory,
            onDelete: () => showDeleteDialog(context),
            onEdit: ()=> _showEditBusinessFormModal(context,widget.business),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: WikiBusinessContent(
                businessTitle: businessTitle,
                businessImage: businessImage,
                businessDescription: businessDescription,
                businessLocation: businessLocation,
                businessCategory: businessCategory,
                email: email,
                websiteURL: websiteURL,
                facebookUsername: facebookUsername,
                twitterUsername: twitterUsername,
                instagramUsername: instagramUsername,
                linkedinUsername: linkedinUsername,
                whatsappNumber: whatsappNumber,
                gallery: gallery,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WikiBusinessHeader extends StatelessWidget {
  final String businessTitle;
  final String businessCategory;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const WikiBusinessHeader({
    super.key,
    required this.businessTitle,
    required this.businessCategory,
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
                    businessTitle,
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
                  Icon(Icons.business, size: 16, color: Colors.blue[700]),
                  const SizedBox(width: 8),
                  Text(
                    "This page is for modifying the details of the Business: $businessTitle.",
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

class WikiBusinessContent extends StatelessWidget {
  final String businessTitle;
  final String businessImage;
  final String businessDescription;
  final String businessLocation;
  final String businessCategory;
  final String email;
  final String websiteURL;
  final String facebookUsername;
  final String twitterUsername;
  final String instagramUsername;
  final String linkedinUsername;
  final String whatsappNumber;
  final List<String> gallery;

  const WikiBusinessContent({
    super.key,
    required this.businessTitle,
    required this.businessImage,
    required this.businessDescription,
    required this.businessLocation,
    required this.businessCategory,
    required this.email,
    required this.websiteURL,
    required this.facebookUsername,
    required this.twitterUsername,
    required this.instagramUsername,
    required this.linkedinUsername,
    required this.whatsappNumber,
    required this.gallery,
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
                // Overview Section
                WikiSection(
                  title: "Overview",
                  content: businessDescription  ),
                const SizedBox(height: 24),

                // Services Section
                WikiSection(
                  title: "Services",
                  content: "As a $businessCategory business, $businessTitle offers a range of specialized services to meet customer needs in the local market.",
                ),
                const SizedBox(height: 24),

                // Location Section
                WikiSection(
                  title: "Location",
                  content: "$businessTitle is strategically located in $businessLocation, providing convenient access to customers throughout the region.",
                ),
                const SizedBox(height: 24),

                // Contact Information Section
                WikiSection(
                  title: "Contact Information",
                  content: "The business maintains multiple channels of communication to serve its customers effectively.",
                ),
                const SizedBox(height: 16),

                // Contact Details
                WikiContactSection(
                  email: email,
                  websiteURL: websiteURL,
                  whatsappNumber: whatsappNumber,
                ),
                const SizedBox(height: 24),

                // Gallery Section
                if (gallery.length > 1)
                  WikiGallerySection(gallery: gallery),
              ],
            ),
          ),

          const SizedBox(width: 24),

          // Sidebar (right side)
          Expanded(
            flex: 1,
            child: WikiBusinessInfoBox(
              businessTitle: businessTitle,
              businessImage: businessImage,
              businessCategory: businessCategory,
              businessLocation: businessLocation,
              email: email,
              websiteURL: websiteURL,
              facebookUsername: facebookUsername,
              twitterUsername: twitterUsername,
              instagramUsername: instagramUsername,
              linkedinUsername: linkedinUsername,
              whatsappNumber: whatsappNumber,
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

class WikiBusinessInfoBox extends StatelessWidget {
  final String businessTitle;
  final String businessImage;
  final String businessCategory;
  final String businessLocation;
  final String email;
  final String websiteURL;
  final String facebookUsername;
  final String twitterUsername;
  final String instagramUsername;
  final String linkedinUsername;
  final String whatsappNumber;

  const WikiBusinessInfoBox({
    super.key,
    required this.businessTitle,
    required this.businessImage,
    required this.businessCategory,
    required this.businessLocation,
    required this.email,
    required this.websiteURL,
    required this.facebookUsername,
    required this.twitterUsername,
    required this.instagramUsername,
    required this.linkedinUsername,
    required this.whatsappNumber,
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
              businessTitle,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // Business Image
          if (businessImage.isNotEmpty)
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(businessImage),
                  fit: BoxFit.cover,
                ),
              ),
            ),

          // Info rows
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                _buildInfoRow("Type", businessCategory),
                _buildInfoRow("Location", businessLocation),
                if (email.isNotEmpty)
                  _buildInfoRow("Email", email),
                if (websiteURL.isNotEmpty)
                  _buildWebsiteRow("Website", websiteURL),
                if (whatsappNumber.isNotEmpty)
                  _buildContactRow("WhatsApp", whatsappNumber, "https://wa.me/$whatsappNumber"),

                // Social Media Section
                const SizedBox(height: 16),
                const Text(
                  "Social Media",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),

                if (facebookUsername.isNotEmpty)
                  _buildSocialRow("Facebook", facebookUsername, "https://facebook.com/$facebookUsername"),
                if (twitterUsername.isNotEmpty)
                  _buildSocialRow("Twitter", twitterUsername, "https://twitter.com/$twitterUsername"),
                if (instagramUsername.isNotEmpty)
                  _buildSocialRow("Instagram", instagramUsername, "https://instagram.com/$instagramUsername"),
                if (linkedinUsername.isNotEmpty)
                  _buildSocialRow("LinkedIn", linkedinUsername, "https://linkedin.com/in/$linkedinUsername"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70,
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

  Widget _buildWebsiteRow(String label, String url) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () {
                launchUrl(Uri.parse(url.startsWith('http') ? url : 'https://$url'));
              },
              child: Text(
                url,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.blue[700],
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactRow(String label, String value, String url) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () {
                launchUrl(Uri.parse(url));
              },
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.blue[700],
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialRow(String platform, String username, String url) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: InkWell(
        onTap: () {
          launchUrl(Uri.parse(url));
        },
        child: Row(
          children: [
            _getSocialIcon(platform),
            const SizedBox(width: 8),
            Text(
              "@$username",
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

  Widget _getSocialIcon(String platform) {
    IconData icon;
    Color color;

    switch (platform.toLowerCase()) {
      case 'facebook':
        icon = Icons.facebook;
        color = const Color(0xFF1877F2);
        break;
      case 'twitter':
        icon = Icons.alternate_email;
        color = const Color(0xFF1DA1F2);
        break;
      case 'instagram':
        icon = Icons.camera_alt;
        color = const Color(0xFFE4405F);
        break;
      case 'linkedin':
        icon = Icons.business;
        color = const Color(0xFF0A66C2);
        break;
      default:
        icon = Icons.link;
        color = Colors.blue;
    }

    return Icon(icon, size: 16, color: color);
  }
}

class WikiContactSection extends StatelessWidget {
  final String email;
  final String websiteURL;
  final String whatsappNumber;

  const WikiContactSection({
    super.key,
    required this.email,
    required this.websiteURL,
    required this.whatsappNumber,
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
            "Contact Methods",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          if (email.isNotEmpty)
            _buildContactItem("Email", email, "mailto:$email"),
          if (websiteURL.isNotEmpty)
            _buildContactItem("Website", websiteURL, websiteURL.startsWith('http') ? websiteURL : 'https://$websiteURL'),
          if (whatsappNumber.isNotEmpty)
            _buildContactItem("WhatsApp", whatsappNumber, "https://wa.me/$whatsappNumber"),
        ],
      ),
    );
  }

  Widget _buildContactItem(String title, String value, String url) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: InkWell(
        onTap: () {
          launchUrl(Uri.parse(url));
        },
        child: Row(
          children: [
            Icon(
                title == "Email" ? Icons.email :
                title == "Website" ? Icons.web : Icons.message,
                size: 16,
                color: Colors.blue[700]
            ),
            const SizedBox(width: 8),
            Text(
              "$title: $value",
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

class WikiGallerySection extends StatelessWidget {
  final List<String> gallery;

  const WikiGallerySection({
    super.key,
    required this.gallery,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        WikiSection(
          title: "Gallery",
          content: "Visual representation of the business and its services:",
        ),
        const SizedBox(height: 16),
        Container(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: gallery.length > 5 ? 5 : gallery.length,
            itemBuilder: (context, index) {
              return Container(
                width: 120,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(4),
                  image: DecorationImage(
                    image: NetworkImage(gallery[index]),
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}