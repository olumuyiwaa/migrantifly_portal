import 'dart:io';
import 'dart:typed_data';
import 'dart:js' as js;
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geocoding/geocoding.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../models/class_countries.dart';
import '../../api/api_post.dart';
import '../../api/api_update.dart';
import '../../constants.dart';

class CountryDetailsForm extends StatefulWidget {
  final Country country;
  final bool isEditing;
  final Function() onSave;

  const CountryDetailsForm({
    super.key,
    required this.country,
    required this.isEditing,
    required this.onSave,
  });

  @override
  State<CountryDetailsForm> createState() => _CountryDetailsFormState();
}

class _CountryDetailsFormState extends State<CountryDetailsForm> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  // State variables
  File? _coverImage;
  Uint8List? _coverImageBytes;
  String _latitude = "";
  String _longitude = "";
  bool _isLoading = false;
  bool _isConverting = false;

  // Text controllers - mapped to correct Country fields
  late final TextEditingController _titleController;
  late final TextEditingController _presidentController;
  late final TextEditingController _capitalController;
  late final TextEditingController _currencyController;
  late final TextEditingController _populationController;
  late final TextEditingController _demonymController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _languageController;
  late final TextEditingController _timeZoneController;
  late final TextEditingController _linkController;
  late final TextEditingController _artCraftController;
  late final TextEditingController _culturalDanceController;

  // Dropdown values
  String? _selectedCountry;

  // Constants
  static const List<String> _africanCountries = [
    "Select Country",
    "Algeria", "Angola", "Benin", "Botswana", "Burkina Faso", "Burundi",
    "Cabo Verde", "Cameroon", "Central African Republic", "Chad", "Comoros",
    "Congo", "Congo (DRC)", "Djibouti", "Egypt", "Equatorial Guinea", "Eritrea",
    "Eswatini", "Ethiopia", "Gabon", "Gambia", "Ghana", "Guinea", "Guinea-Bissau",
    "Ivory Coast", "Kenya", "Lesotho", "Liberia", "Libya", "Madagascar", "Malawi",
    "Mali", "Mauritania", "Mauritius", "Morocco", "Mozambique", "Namibia", "Niger",
    "Nigeria", "Rwanda", "Sao Tome and Principe", "Senegal", "Seychelles",
    "Sierra Leone", "Somalia", "South Africa", "South Sudan", "Sudan", "Tanzania",
    "Togo", "Tunisia", "Uganda", "Zambia", "Zimbabwe"
  ];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeFields();
    getUserInfo();
  }
  String userID = "";
  Future<void> getUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userID = prefs.getString('id') ?? "";
    });
  }

  void _initializeControllers() {
    _titleController = TextEditingController();
    _presidentController = TextEditingController();
    _capitalController = TextEditingController();
    _currencyController = TextEditingController();
    _populationController = TextEditingController();
    _demonymController = TextEditingController();
    _descriptionController = TextEditingController();
    _languageController = TextEditingController();
    _timeZoneController = TextEditingController();
    _linkController = TextEditingController();
    _artCraftController = TextEditingController();
    _culturalDanceController = TextEditingController();
  }

  void _initializeFields() {
    // Initialize controllers with correct Country model fields
    _titleController.text = widget.country.title;
    _presidentController.text = widget.country.president;
    _capitalController.text = widget.country.capital;
    _currencyController.text = widget.country.currency;
    _populationController.text = widget.country.population;
    _demonymController.text = widget.country.demonym;
    _descriptionController.text = widget.country.description;
    _languageController.text = widget.country.language;
    _timeZoneController.text = widget.country.timeZone;
    _linkController.text = widget.country.link;
    _artCraftController.text = widget.country.artCraft ?? '';
    _culturalDanceController.text = widget.country.culturalDance ?? '';

    // Set coordinates
    _latitude = widget.country.latitude?.toString() ?? '';
    _longitude = widget.country.longitude?.toString() ?? '';

    _selectedCountry = _africanCountries.contains(widget.country.title)
        ? widget.country.title
        : "Select Country";
  }

  Future<void> _pickCoverImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'gif', 'webp', 'heic', 'heif'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;

        if (file.bytes != null) {
          // Check if it's a HEIC file
          if (_isHeicFile(file.name, file.extension)) {
            setState(() {
              _isConverting = true;
            });

            // Convert HEIC to JPEG
            final convertedBytes = await _convertHeicToJpeg(file.bytes!);

            setState(() {
              _isConverting = false;
              if (convertedBytes != null) {
                _coverImageBytes = convertedBytes;
              } else {
                // Show error message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to convert HEIC image. Please try a different format.'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            });
          } else {
            // Regular image format
            setState(() {
              _coverImageBytes = file.bytes;
            });
          }
        }
      }
    } catch (e) {
      setState(() {
        _isConverting = false;
      });
      debugPrint('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error selecting image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

// Clear selected image
  void _clearCoverImage() {
    setState(() {
      _coverImageBytes = null;
    });
  }




  Future<http.MultipartFile?> _getImageMultipartFile() async {
    if (_coverImageBytes != null) {
      // For web, create MultipartFile from bytes
      return http.MultipartFile.fromBytes(
        'image',
        _coverImageBytes!,
        filename: 'cover_image.jpg',
        contentType: MediaType('image', 'jpeg'),
      );
    }
    return null;
  }

// Update your API calls to use the new image handling
  Future<void> _submitCreateCountryForm() async {
    if (!_validateForm()) return;

    setState(() => _isLoading = true);

    try {
      // Get image as MultipartFile
      final imageFile = await _getImageMultipartFile();

      await createCountry(
          context: context,
          coverImage: imageFile,
          userID: userID,
          countryTitle: _selectedCountry!,
          countryDescription: _descriptionController.text.trim(),
          countryCapital: _capitalController.text.trim(),
          countryCurrency: _currencyController.text.trim(),
          countryPopulation: _populationController.text.trim(),
          countryDemonym: _demonymController.text.trim(),
          countryLanguage: _languageController.text.trim(),
          countryTimeZone: _timeZoneController.text.trim(),
          countryPresident: _presidentController.text.trim(),
          countryCuisinesLink: _linkController.text.trim(),
          countryCulturalDanceLink: _artCraftController.text.trim(),
          countryArtsCraftsLink: _culturalDanceController.text.trim()
      );

      _showSuccessSnackBar('Event saved successfully');
      widget.onSave();
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      _showErrorSnackBar('Error saving event: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _submitUpdateCountryForm() async {
    if (!_validateForm()) return;

    setState(() => _isLoading = true);

    try {

      // Get image as MultipartFile
      final imageFile = await _getImageMultipartFile();

      await updateCountry(
          context: context,
          coverImage: imageFile,
          userID: userID,
          countryTitle: _selectedCountry!,
          countryID: widget.country.id,
          countryDescription: _descriptionController.text.trim(),
          countryCapital: _capitalController.text.trim(),
          countryCurrency: _currencyController.text.trim(),
          countryPopulation: _populationController.text.trim(),
          countryDemonym: _demonymController.text.trim(),
          countryLanguage: _languageController.text.trim(),
          countryTimeZone: _timeZoneController.text.trim(),
          countryPresident: _presidentController.text.trim(),
          countryCuisinesLink: _linkController.text.trim(),
          countryCulturalDanceLink: _artCraftController.text.trim(),
          countryArtsCraftsLink: _culturalDanceController.text.trim()
      );

      _showSuccessSnackBar('Event updated successfully');
      widget.onSave();
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      _showErrorSnackBar('Error updating event: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }


  bool _validateForm() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return false;
    }

    if (_selectedCountry == null || _selectedCountry == "Select Country") {
      _showErrorSnackBar('Please select a country Name');
      return false;
    }

    return true;
  }


  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildInputField({
    required String title,
    required String hintText,
    required TextEditingController controller,
    bool isReadOnly = false,
    String? Function(String?)? validator,
    Widget? suffixIcon,
    void Function(String)? onChanged,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: isReadOnly,
          validator: validator,
          onChanged: onChanged,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            fillColor: isReadOnly ? Colors.grey[100] : Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: primaryColor, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            suffixIcon: suffixIcon,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String title,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              );
            }).toList(),
            onChanged: onChanged,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCoverImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Country Cover Image',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _isLoading ? null : _pickCoverImage,
          child: Container(
            width: double.infinity,
            height: 320,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
              color: Colors.grey[50],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  Positioned.fill(child: _buildCoverImage()),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(8),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCoverImage() {
    if (_isConverting) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: primaryColor),
            SizedBox(height: 8),
            Text('Converting HEIC image...', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    // Priority 1: Show selected image bytes
    if (_coverImageBytes != null) {
      return Image.memory(_coverImageBytes!, fit: BoxFit.cover);
    }
    // Priority 2: Show existing country image from network
    else if (widget.country.image.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: widget.country.image,
        fit: BoxFit.cover,
        placeholder: (context, url) => Center(
          child: CircularProgressIndicator(color: primaryColor),
        ),
        errorWidget: (context, url, error) => const Center(
          child: Icon(Icons.image_not_supported, size: 48, color: Colors.grey),
        ),
      );
    }
    // Priority 3: Show placeholder
    else {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image, size: 48, color: Colors.grey),
            SizedBox(height: 8),
            Text('Tap to select image (HEIC supported)', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }
  }

  // Check if file is HEIC
  bool _isHeicFile(String fileName, String? mimeType) {
    final extension = fileName.toLowerCase().split('.').last;
    return extension == 'heic' ||
        extension == 'heif' ||
        mimeType?.contains('heic') == true ||
        mimeType?.contains('heif') == true;
  }

  // Convert HEIC to JPEG using browser-based conversion
  Future<Uint8List?> _convertHeicToJpeg(Uint8List heicBytes) async {
    try {
      // Use heic2any JavaScript library for conversion
      final convertedBytes = await _callHeicConverter(heicBytes);
      return convertedBytes;
    } catch (e) {
      debugPrint('HEIC conversion failed: $e');
      return null;
    }
  }

  // Call JavaScript HEIC converter
  Future<Uint8List?> _callHeicConverter(Uint8List heicBytes) async {
    try {
      // This requires adding heic2any.js to your web/index.html
      final result = await js.context.callMethod('convertHeicToJpeg', [heicBytes]);
      if (result != null) {
        return Uint8List.fromList(List<int>.from(result));
      }
    } catch (e) {
      debugPrint('JavaScript HEIC conversion error: $e');
    }
    return null;
  }

  void _clearForm() {
    _titleController.clear();
    _presidentController.clear();
    _capitalController.clear();
    _currencyController.clear();
    _populationController.clear();
    _demonymController.clear();
    _descriptionController.clear();
    _languageController.clear();
    _timeZoneController.clear();
    _linkController.clear();
    _artCraftController.clear();
    _culturalDanceController.clear();

    setState(() {
      _selectedCountry = "Select Country";
      _coverImage = null;
      _coverImageBytes = null;
      _latitude = "";
      _longitude = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 900, maxHeight: 700),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.isEditing ? 'Edit Country' : 'Create Country',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          // Form Content
          Expanded(
            child: Form(
              key: _formKey,
              child: Scrollbar(
                controller: _scrollController,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    spacing: defaultPadding,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Basic Information
                      Text(
                        'Basic Information',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      Row(
                        spacing: defaultPadding,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                               _buildDropdownField(
                                    title: "Country Title",
                                    value: _selectedCountry,
                                    items: _africanCountries,
                                    onChanged: (value) => setState(() => _selectedCountry = value),
                                  ),

                                const SizedBox(height: 16),

                                _buildInputField(
                                  title: "President",
                                  hintText: "Enter current president name",
                                  controller: _presidentController,
                                  validator: (value) => value?.trim().isEmpty == true ? "Required" : null,
                                ),
                                const SizedBox(height: 16),

                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildInputField(
                                        title: "Capital",
                                        hintText: "Enter capital city",
                                        controller: _capitalController,
                                        validator: (value) => value?.trim().isEmpty == true ? "Required" : null,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: _buildInputField(
                                        title: "Currency",
                                        hintText: "Enter currency",
                                        controller: _currencyController,
                                        validator: (value) => value?.trim().isEmpty == true ? "Required" : null,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),

                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildInputField(
                                        title: "Population",
                                        hintText: "Enter population",
                                        controller: _populationController,
                                        validator: (value) => value?.trim().isEmpty == true ? "Required" : null,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: _buildInputField(
                                        title: "Demonym",
                                        hintText: "Enter demonym (e.g., Nigerian)",
                                        controller: _demonymController,
                                        validator: (value) => value?.trim().isEmpty == true ? "Required" : null,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),

                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildInputField(
                                        title: "Time Zone",
                                        hintText: "Enter time zone (e.g., WAT)",
                                        controller: _timeZoneController,
                                        validator: (value) => value?.trim().isEmpty == true ? "Required" : null,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: _buildInputField(
                                        title: "Language",
                                        hintText: "Enter official language(s)",
                                        controller: _languageController,
                                        validator: (value) => value?.trim().isEmpty == true ? "Required" : null,
                                      )
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child:  _buildInputField(
                                        title: "Cultural Dance",
                                        hintText: "https://example.com/cultural-dance",
                                        controller: _culturalDanceController,
                                      )
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildCoverImageSection(),
                                const SizedBox(height: 20),
                                Row(
                                  children: [
                                    Expanded(child:_buildInputField(
                                  title: "Cousine",
                                  hintText: "https://example.com",
                                  controller: _linkController,
                                )),
                                                          const SizedBox(width: 8),

                                Expanded(child: _buildInputField(
                              title: "Arts & Crafts",
                              hintText: "https://example.com/art-craft",
                              controller: _artCraftController,
                            ))
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      // Description
                      _buildInputField(
                        title: "Country Description",
                        hintText: "Enter country description...",
                        controller: _descriptionController,
                        maxLines: 10,
                        validator: (value) => value?.trim().isEmpty == true ? "Required" : null,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Footer with Action Buttons
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              border: Border(
                top: BorderSide(color: Colors.grey[200]!),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _isLoading ? null : _clearForm,
                  child: const Text('Clear Form'),
                ),
                const SizedBox(width: 16),
                TextButton(
                  onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _isLoading ? null : widget.isEditing ? _submitUpdateCountryForm:_submitCreateCountryForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                      : Text(widget.isEditing ? 'Update Country' : 'Create Country'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _presidentController.dispose();
    _capitalController.dispose();
    _currencyController.dispose();
    _populationController.dispose();
    _demonymController.dispose();
    _descriptionController.dispose();
    _languageController.dispose();
    _timeZoneController.dispose();
    _linkController.dispose();
    _artCraftController.dispose();
    _culturalDanceController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}