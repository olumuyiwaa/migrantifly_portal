// dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../constants.dart';
import '../../models/class_applications.dart';

class EventDetailsForm extends StatefulWidget {
  final Application event; // Application instance
  final bool isEditing;
  final Function() onSave;

  const EventDetailsForm({
    super.key,
    required this.event,
    required this.isEditing,
    required this.onSave,
  });

  @override
  State<EventDetailsForm> createState() => _EventDetailsFormState();
}

class _EventDetailsFormState extends State<EventDetailsForm> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  bool _isLoading = false;

  // Controllers for Application fields
  late final TextEditingController _visaTypeController;
  late final TextEditingController _stageController;
  late final TextEditingController _consultationIdController;

  // Read-only date strings
  String _createdAtText = '';
  String _updatedAtText = '';

  // Progress slider (0-100)
  double _progress = 0;

  @override
  void initState() {
    super.initState();
    _visaTypeController = TextEditingController();
    _stageController = TextEditingController();
    _consultationIdController = TextEditingController();

    _initializeFields();
  }

  void _initializeFields() {
    final app = widget.event;

    _visaTypeController.text = app.visaType;
    _stageController.text = app.stage;
    _consultationIdController.text = app.consultationId;

    _progress = (app.progress).toDouble().clamp(0, 100);

    _createdAtText = _formatDateTime(app.createdAt);
    _updatedAtText = _formatDateTime(app.updatedAt);
  }

  String _formatDateTime(DateTime? dt) {
    if (dt == null) return '';
    return DateFormat('yyyy-MM-dd HH:mm').format(dt.toLocal());
    // Adjust the format to your preference
  }

  bool _validateForm() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return false;
    }
    return true;
  }

  Future<void> _submitSave() async {
    if (!_validateForm()) return;

    setState(() => _isLoading = true);
    try {
      // TODO: call your Application create/update API here.
      // Example payload (if needed):
      // final updated = Application(
      //   id: widget.event.id,
      //   client: widget.event.client,
      //   adviser: widget.event.adviser,
      //   consultationId: _consultationIdController.text.trim(),
      //   visaType: _visaTypeController.text.trim(),
      //   stage: _stageController.text.trim(),
      //   progress: _progress.round(),
      //   timeline: widget.event.timeline,
      //   deadlines: widget.event.deadlines,
      //   createdAt: widget.event.createdAt,
      //   updatedAt: DateTime.now(),
      // );

      // await updateApplication(updated); // replace with your API
      widget.onSave();
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      _showSnackBar('Error saving application: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
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
            errorBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              borderSide: BorderSide(color: Colors.red, width: 1),
            ),
            focusedErrorBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              borderSide: BorderSide(color: Colors.red, width: 2),
            ),
            suffixIcon: suffixIcon,
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarCard() {
    final app = widget.event;
    final imageUrl = app.client.image;
    final title = app.client.fullName.isNotEmpty
        ? app.client.fullName
        : (app.client.email.isNotEmpty ? app.client.email : 'Client');
    final subtitle = app.displayVisaTypeTitle;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Client',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: 280,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
            color: Colors.grey[50],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                Positioned.fill(
                  child: imageUrl.isNotEmpty
                      ? CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Center(
                      child: CircularProgressIndicator(
                        color: primaryColor,
                      ),
                    ),
                    errorWidget: (context, url, error) => const Center(
                      child: Icon(Icons.person, size: 48, color: Colors.grey),
                    ),
                  )
                      : const Center(
                    child: Icon(Icons.person, size: 48, color: Colors.grey),
                  ),
                ),
                Positioned(
                  left: 12,
                  right: 12,
                  bottom: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.55),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          subtitle,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = widget.event;

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
                  widget.isEditing ? 'Edit Application' : 'Create Application',
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
                      // Top row: fields + avatar
                      Row(
                        spacing: defaultPadding,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildInputField(
                                  title: "Visa Type",
                                  hintText: "e.g. Student",
                                  controller: _visaTypeController,
                                  validator: (v) =>
                                  v?.trim().isEmpty == true ? "Required" : null,
                                ),
                                const SizedBox(height: 16),
                                _buildInputField(
                                  title: "Stage",
                                  hintText: "e.g. Submitted",
                                  controller: _stageController,
                                  validator: (v) =>
                                  v?.trim().isEmpty == true ? "Required" : null,
                                ),
                                const SizedBox(height: 16),
                                _buildInputField(
                                  title: "Consultation ID",
                                  hintText: "Enter consultation reference",
                                  controller: _consultationIdController,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Progress',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Slider(
                                        value: _progress,
                                        min: 0,
                                        max: 100,
                                        divisions: 100,
                                        label: "${_progress.round()}%",
                                        onChanged: (val) =>
                                            setState(() => _progress = val),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 56,
                                      child: Text(
                                        "${_progress.round()}%",
                                        textAlign: TextAlign.end,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Key Dates',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildInputField(
                                        title: "Created",
                                        hintText: "",
                                        controller: TextEditingController(
                                            text: _createdAtText),
                                        isReadOnly: true,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: _buildInputField(
                                        title: "Updated",
                                        hintText: "",
                                        controller: TextEditingController(
                                            text: _updatedAtText),
                                        isReadOnly: true,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Client & Adviser',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildInputField(
                                        title: "Client",
                                        hintText: "",
                                        controller: TextEditingController(
                                          text: app.client.fullName.isNotEmpty
                                              ? app.client.fullName
                                              : (app.client.email.isNotEmpty
                                              ? app.client.email
                                              : 'Client'),
                                        ),
                                        isReadOnly: true,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: _buildInputField(
                                        title: "Adviser",
                                        hintText: "",
                                        controller: TextEditingController(
                                          text: app.adviser.fullName.isNotEmpty
                                              ? app.adviser.fullName
                                              : (app.adviser.email.isNotEmpty
                                              ? app.adviser.email
                                              : 'Adviser'),
                                        ),
                                        isReadOnly: true,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Avatar / image card
                          Expanded(flex: 2, child: _buildAvatarCard()),
                        ],
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
                  onPressed: _isLoading
                      ? null
                      : () {
                    // Reset to original values
                    setState(() {
                      _initializeFields();
                    });
                  },
                  child: const Text('Reset'),
                ),
                const SizedBox(width: 16),
                TextButton(
                  onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _isLoading ? null : _submitSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
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
                      valueColor:
                      AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                      : Text(widget.isEditing ? 'Update' : 'Create'),
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
    _visaTypeController.dispose();
    _stageController.dispose();
    _consultationIdController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}