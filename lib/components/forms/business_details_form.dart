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

import '../../api/api_post.dart';
import '../../api/api_update.dart';
import '../../constants.dart';
import '../../models/class_business.dart';
import '../input/input_drop_down.dart';

class BusinessDetailsForm extends StatefulWidget {
  final Business business;
  final bool isEditing;
  final Function() onSave;

  const BusinessDetailsForm({
    super.key,
    required this.business,
    required this.isEditing,
    required this.onSave,
  });

  @override
  State<BusinessDetailsForm> createState() => _BusinessDetailsFormState();
}

class _BusinessDetailsFormState extends State<BusinessDetailsForm> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  // State variables

  List<Uint8List> _selectedMediaFiles = [];
  List<String> _selectedMediaFileNames = [];
  bool _isLoading = false;
  bool _isConverting = false;

  // Text controllers
  late final TextEditingController _businessTitleController;
  late final TextEditingController _businessDescriptionController;
  late final TextEditingController _emailAddressController;
  late final TextEditingController _twitterController;
  late final TextEditingController _facebookController;
  late final TextEditingController _instagramController;
  late final TextEditingController _webAddressController;
  late final TextEditingController _linkedInController;
  late final TextEditingController _whatsappController;
  late final TextEditingController _businessCategory;

  // Dropdown values
  String? _selectedBusinessLocation;


  static const List<String> countries = [
    "Select Country","World Wide",
    'Afghanistan', 'Albania', 'Algeria', 'Andorra', 'Angola', 'Antigua and Barbuda',
    'Argentina', 'Armenia', 'Australia', 'Austria', 'Azerbaijan', 'Bahamas',
    'Bahrain', 'Bangladesh', 'Barbados', 'Belarus', 'Belgium', 'Belize', 'Benin',
    'Bhutan', 'Bolivia', 'Bosnia and Herzegovina', 'Botswana', 'Brazil', 'Brunei',
    'Bulgaria', 'Burkina Faso', 'Burundi', 'Cabo Verde', 'Cambodia', 'Cameroon',
    'Canada', 'Central African Republic', 'Chad', 'Chile', 'China', 'Colombia',
    'Comoros', 'Congo (Congo-Brazzaville)', 'Costa Rica', 'Croatia', 'Cuba',
    'Cyprus', 'Czech Republic (Czechia)', 'Democratic Republic of the Congo',
    'Denmark', 'Djibouti', 'Dominica', 'Dominican Republic', 'Ecuador', 'Egypt',
    'El Salvador', 'Equatorial Guinea', 'Eritrea', 'Estonia', 'Eswatini (fmr. "Swaziland")',
    'Ethiopia', 'Fiji', 'Finland', 'France', 'Gabon', 'Gambia', 'Georgia', 'Germany',
    'Ghana', 'Greece', 'Grenada', 'Guatemala', 'Guinea', 'Guinea-Bissau', 'Guyana',
    'Haiti', 'Honduras', 'Hungary', 'Iceland', 'India', 'Indonesia', 'Iran', 'Iraq',
    'Ireland', 'Israel', 'Italy', 'Jamaica', 'Japan', 'Jordan', 'Kazakhstan', 'Kenya',
    'Kiribati', 'Kuwait', 'Kyrgyzstan', 'Laos', 'Latvia', 'Lebanon', 'Lesotho',
    'Liberia', 'Libya', 'Liechtenstein', 'Lithuania', 'Luxembourg', 'Madagascar',
    'Malawi', 'Malaysia', 'Maldives', 'Mali', 'Malta', 'Marshall Islands', 'Mauritania',
    'Mauritius', 'Mexico', 'Micronesia', 'Moldova', 'Monaco', 'Mongolia', 'Montenegro',
    'Morocco', 'Mozambique', 'Myanmar (formerly Burma)', 'Namibia', 'Nauru', 'Nepal',
    'Netherlands', 'New Zealand', 'Nicaragua', 'Niger', 'Nigeria', 'North Korea',
    'North Macedonia', 'Norway', 'Oman', 'Pakistan', 'Palau', 'Palestine State',
    'Panama', 'Papua New Guinea', 'Paraguay', 'Peru', 'Philippines', 'Poland',
    'Portugal', 'Qatar', 'Romania', 'Russia', 'Rwanda', 'Saint Kitts and Nevis',
    'Saint Lucia', 'Saint Vincent and the Grenadines', 'Samoa', 'San Marino',
    'Sao Tome and Principe', 'Saudi Arabia', 'Senegal', 'Serbia', 'Seychelles',
    'Sierra Leone', 'Singapore', 'Slovakia', 'Slovenia', 'Solomon Islands', 'Somalia',
    'South Africa', 'South Korea', 'South Sudan', 'Spain', 'Sri Lanka', 'Sudan',
    'Suriname', 'Sweden', 'Switzerland', 'Syria', 'Tajikistan', 'Tanzania', 'Thailand',
    'Timor-Leste', 'Togo', 'Tonga', 'Trinidad and Tobago', 'Tunisia', 'Turkey',
    'Turkmenistan', 'Tuvalu', 'Uganda', 'Ukraine', 'United Arab Emirates',
    'United Kingdom', 'United States of America', 'Uruguay', 'Uzbekistan', 'Vanuatu',
    'Vatican City', 'Venezuela', 'Vietnam', 'Yemen', 'Zambia', 'Zimbabwe',
  ];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeFields();
  }

  void _initializeControllers() {
    _businessTitleController = TextEditingController();
    _businessDescriptionController = TextEditingController();
    _emailAddressController = TextEditingController();
    _twitterController = TextEditingController();
    _facebookController = TextEditingController();
    _instagramController = TextEditingController();
    _webAddressController = TextEditingController();
    _linkedInController = TextEditingController();
    _whatsappController = TextEditingController();
    _businessCategory = TextEditingController();
  }

  void _initializeFields() {
    _businessTitleController.text = widget.business.businessTitle;
    _businessDescriptionController.text = widget.business.businessDescription;
    _emailAddressController.text = widget.business.businessAddress;
    _twitterController.text = widget.business.twitter;
    _facebookController.text = widget.business.facebook;
    _instagramController.text = widget.business.instagram;
    _webAddressController.text = widget.business.webAddress;
    _linkedInController.text = widget.business.linkedIn;
    _whatsappController.text = widget.business.whatsapp;
    _businessCategory.text = widget.business.businessCategory;

    // Set dropdown values
    _selectedBusinessLocation = countries.contains(widget.business.businessLocation)
        ? widget.business.businessLocation
        : "Select Country";
  }

  Future<void> _pickMediaFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'gif', 'heic', 'heif'],
        allowMultiple: true,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _isConverting = true;
        });

        List<Uint8List> newFiles = [];
        List<String> newFileNames = [];

        for (var file in result.files) {
          if (file.bytes != null) {
            String fileName = file.name;

            // Check if it's a HEIC file
            if (_isHeicFile(file.name, file.extension)) {
              // Convert HEIC to JPEG
              final convertedBytes = await _convertHeicToJpeg(file.bytes!);
              if (convertedBytes != null) {
                newFiles.add(convertedBytes);
                // Change extension to jpg for converted files
                fileName = fileName.replaceAll(RegExp(r'\.(heic|heif)$', caseSensitive: false), '.jpg');
                newFileNames.add(fileName);
              } else {
                // Handle conversion failure
                debugPrint('Failed to convert HEIC file: ${file.name}');
                continue; // Skip this file
              }
            } else {
              // Regular image format
              newFiles.add(file.bytes!);
              newFileNames.add(fileName);
            }
          }
        }

        setState(() {
          _isConverting = false;
          _selectedMediaFiles.addAll(newFiles);
          _selectedMediaFileNames.addAll(newFileNames);
        });
      }
    } catch (e) {
      setState(() {
        _isConverting = false;
      });
      debugPrint('Error picking images: $e');
      _showErrorSnackBar('Error selecting images: $e');
    }
  }

// FIXED: Convert multiple media files to MultipartFile list
  Future<List<http.MultipartFile>> _getImageMultipartFiles() async {
    List<http.MultipartFile> multipartFiles = [];

    for (int i = 0; i < _selectedMediaFiles.length; i++) {
      final bytes = _selectedMediaFiles[i];
      final fileName = _selectedMediaFileNames[i];

      // Determine content type based on file extension
      MediaType contentType = _getMediaTypeFromFileName(fileName);

      final multipartFile = http.MultipartFile.fromBytes(
        'gallery', // Field name expected by API
        bytes,
        filename: fileName,
        contentType: contentType,
      );

      multipartFiles.add(multipartFile);
    }

    return multipartFiles;
  }

// Helper method to determine MediaType from filename
  MediaType _getMediaTypeFromFileName(String fileName) {
    final extension = fileName.toLowerCase().split('.').last;

    switch (extension) {
      case 'png':
        return MediaType('image', 'png');
      case 'gif':
        return MediaType('image', 'gif');
      case 'jpg':
      case 'jpeg':
        return MediaType('image', 'jpeg');
      case 'heic':
      case 'heif':
        return MediaType('image', 'jpeg');
      default:
      // Default fallback
        return MediaType('image', 'jpeg');
    }
  }

// Additional helper method to validate file before processing
  bool _isValidImageFile(String fileName) {
    final extension = fileName.toLowerCase().split('.').last;
    const validExtensions = ['jpg', 'jpeg', 'png', 'gif', 'heic', 'heif'];
    return validExtensions.contains(extension);
  }

// Enhanced error handling version of _pickMediaFiles
  Future<void> _pickMediaFilesWithValidation() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'gif', 'heic', 'heif'],
        allowMultiple: true,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _isConverting = true;
        });

        List<Uint8List> newFiles = [];
        List<String> newFileNames = [];
        List<String> failedFiles = [];

        for (var file in result.files) {
          if (file.bytes != null && _isValidImageFile(file.name)) {
            String fileName = file.name;

            // Check if it's a HEIC file
            if (_isHeicFile(file.name, file.extension)) {
              // Convert HEIC to JPEG
              final convertedBytes = await _convertHeicToJpeg(file.bytes!);
              if (convertedBytes != null) {
                newFiles.add(convertedBytes);
                // Change extension to jpg for converted files
                fileName = fileName.replaceAll(RegExp(r'\.(heic|heif)$', caseSensitive: false), '.jpg');
                newFileNames.add(fileName);
              } else {
                failedFiles.add(fileName);
              }
            } else {
              // Regular image format
              newFiles.add(file.bytes!);
              newFileNames.add(fileName);
            }
          } else {
            failedFiles.add(file.name);
          }
        }

        setState(() {
          _isConverting = false;
          _selectedMediaFiles.addAll(newFiles);
          _selectedMediaFileNames.addAll(newFileNames);
        });

        // Show warning if some files failed
        if (failedFiles.isNotEmpty) {
          _showErrorSnackBar('Some files could not be processed: ${failedFiles.join(', ')}');
        }
      }
    } catch (e) {
      setState(() {
        _isConverting = false;
      });
      debugPrint('Error picking images: $e');
      _showErrorSnackBar('Error selecting images: $e');
    }
  }

  void _removeMediaFile(int index) {
    setState(() {
      _selectedMediaFiles.removeAt(index);
      _selectedMediaFileNames.removeAt(index);
    });
  }


  bool _validateForm() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return false;
    }

    if (_selectedBusinessLocation == null || _selectedBusinessLocation == "Select Country") {
      _showErrorSnackBar('Please select a business location');
      return false;
    }

    return true;
  }



  Future<void> _submitCreateBusinessForm() async {
    if (!_validateForm()) return;

    setState(() => _isLoading = true);

    try {
      // Get images as MultipartFile
      final imageFiles = await _getImageMultipartFiles();

      await createBusiness(
          context: context,
          mediaFiles: (imageFiles.length < 1 || imageFiles.isEmpty) ? null : imageFiles,
        businessTitle: _businessTitleController.text.trim(),
        businessDescription: _businessDescriptionController.text.trim(),
        businessLocation: _selectedBusinessLocation!,
        email: _emailAddressController.text.trim(),
        businessCategory: _businessCategory.text.trim(),
        facebook: _facebookController.text.trim(),
        twitter: _twitterController.text.trim(),
        instagram: _instagramController.text.trim(),
        linkedIn: _linkedInController.text.trim(),
        whatsapp: _whatsappController.text.trim(),
        webAddress: _webAddressController.text.trim(),
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

  Future<void> _submitUpdateBusinessForm() async {
    if (!_validateForm()) return;

    setState(() => _isLoading = true);

    try {

      // Get images as MultipartFile
      final imageFiles = await _getImageMultipartFiles();

      await updateBusiness(
          context: context,
          mediaFiles: (imageFiles.length < 1 || imageFiles.isEmpty) ? null : imageFiles,
        businessID: widget.business.id, 
        businessTitle: _businessTitleController.text.trim(),
        businessDescription: _businessDescriptionController.text.trim(),
        businessLocation: _selectedBusinessLocation!,
        email: _emailAddressController.text.trim(), 
        businessCategory: _businessCategory.text.trim(), 
        facebook: _facebookController.text.trim(), 
        twitter: _twitterController.text.trim(), 
        instagram: _instagramController.text.trim(), 
        linkedIn: _linkedInController.text.trim(), 
        whatsapp: _whatsappController.text.trim(), 
        webAddress: _webAddressController.text.trim(),
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
          child: InputDropDown(
            value: value ?? items.first,
            items: items,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildMediaFilesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Media Files',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _pickMediaFiles,
              icon: const Icon(Icons.add_photo_alternate),
              label: const Text('Add Media'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor.withOpacity(0.1),
                foregroundColor: primaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        if (_isConverting)
          Center(
            child: Column(
              children: [
                CircularProgressIndicator(color: primaryColor),
                const SizedBox(height: 8),
                Text('Converting images...', style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),

        // Display existing media files
        if (widget.business.mediaFiles.isNotEmpty) ...[
          Text(
            'Existing Media Files',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: widget.business.mediaFiles.length,
              itemBuilder: (context, index) {
                final mediaUrl = widget.business.mediaFiles[index];
                return Container(
                  width: 120,
                  height: 120,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: mediaUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Center(
                        child: CircularProgressIndicator(color: primaryColor),
                      ),
                      errorWidget: (context, url, error) => const Center(
                        child: Icon(Icons.image_not_supported, color: Colors.grey),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Display selected media files
        if (_selectedMediaFiles.isNotEmpty) ...[
          Text(
            'Selected Media Files',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedMediaFiles.length,
              itemBuilder: (context, index) {
                return Container(
                  width: 120,
                  height: 120,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.memory(
                          _selectedMediaFiles[index],
                          fit: BoxFit.cover,
                          width: 120,
                          height: 120,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => _removeMediaFile(index),
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(4),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],

        if (widget.business.mediaFiles.isEmpty && _selectedMediaFiles.isEmpty)
          Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
              color: Colors.grey[50],
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.image, size: 48, color: Colors.grey),
                  SizedBox(height: 8),
                  Text('No media files selected', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ),
      ],
    );
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
    _businessTitleController.clear();
    _businessDescriptionController.clear();
    _emailAddressController.clear();
    _twitterController.clear();
    _facebookController.clear();
    _instagramController.clear();
    _webAddressController.clear();
    _linkedInController.clear();
    _whatsappController.clear();
    _businessCategory.clear();

    setState(() {
      _selectedBusinessLocation = "Select Country";
      _selectedMediaFiles.clear();
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
                  widget.isEditing ? 'Edit Business' : 'Create Business',
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


                      Row(
                        spacing: defaultPadding,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Basic Information
                                Text(
                                  'Basic Information',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _buildInputField(
                                  title: "Business Title",
                                  hintText: "Enter business title",
                                  controller: _businessTitleController,
                                  validator: (value) => value?.trim().isEmpty == true ? "Required" : null,
                                ),
                                const SizedBox(height: 16),

                                _buildInputField(
                                  title: "Business Description",
                                  hintText: "Enter business description...",
                                  controller: _businessDescriptionController,
                                  maxLines: 5,
                                  validator: (value) => value?.trim().isEmpty == true ? "Required" : null,
                                ),
                                const SizedBox(height: 16),

                                Row(children:[
                                 Expanded(child: _buildInputField(
                                  title: "Email Address",
                                  hintText: "username@server.com",
                                  controller: _emailAddressController,
                                  validator: (value) => value?.trim().isEmpty == true ? "Required" : null,
                                )),
                                  const SizedBox(width: 16),
                                  Expanded(child:_buildInputField(
                                    title: "WhatsApp Number",
                                    hintText: "+1234567890",
                                    controller: _whatsappController,
                                    keyboardType: TextInputType.phone,
                                  ))
                                ]),
                                const SizedBox(height: 16),

                                Row(
                                  children: [
                                    Expanded(
                                      child:
                                      _buildDropdownField(
                                        title: "Business Location",
                                        value: _selectedBusinessLocation,
                                        items: countries,
                                        onChanged: (value) => setState(() => _selectedBusinessLocation = value),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child:
                                      _buildInputField(
                                        title: "Business Category",
                                        hintText: "Enter Business Category...",
                                        controller: _businessCategory,
                                        validator: (value) => value?.trim().isEmpty == true ? "Required" : null,
                                      ),
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
                                Text(
                                  'Social Media & Web',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),

                                _buildInputField(
                                  title: "Website URL",
                                  hintText: "https://example.com",
                                  controller: _webAddressController,
                                  keyboardType: TextInputType.url,
                                ),
                                const SizedBox(height: 16),

                                _buildInputField(
                                  title: "Twitter Handle",
                                  hintText: "@username",
                                  controller: _twitterController,
                                ),
                                const SizedBox(height: 18),

                                _buildInputField(
                                  title: "Facebook Page",
                                  hintText: "facebook.com/username",
                                  controller: _facebookController,
                                ),
                                const SizedBox(height: 16),

                                _buildInputField(
                                  title: "Instagram Handle",
                                  hintText: "@username",
                                  controller: _instagramController,
                                ),
                                const SizedBox(height: 16),

                                _buildInputField(
                                  title: "LinkedIn Profile",
                                  hintText: "linkedin.com/in/username",
                                  controller: _linkedInController,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      // Media Files Section
                      _buildMediaFilesSection(),
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
                  onPressed: _isLoading ? null : widget.isEditing?_submitUpdateBusinessForm:_submitCreateBusinessForm,
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
                      : Text(widget.isEditing ? 'Update Business' : 'Create Business'),
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
    _businessTitleController.dispose();
    _businessDescriptionController.dispose();
    _emailAddressController.dispose();
    _twitterController.dispose();
    _facebookController.dispose();
    _instagramController.dispose();
    _webAddressController.dispose();
    _linkedInController.dispose();
    _whatsappController.dispose();
    _businessCategory.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}