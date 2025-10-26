import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

class BookConsultationModal extends StatefulWidget {
  final VoidCallback onClose;

  const BookConsultationModal({Key? key, required this.onClose}) : super(key: key);

  @override
  State<BookConsultationModal> createState() => _BookConsultationModalState();
}

class _BookConsultationModalState extends State<BookConsultationModal> {
  int step = 1;
  bool loading = false;
  bool slotsLoading = false;
  String? error;
  String? success;
  @override
  void initState() {
    super.initState();
    getUserInfo();
  }
  Future<void> getUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      emailController.text = prefs.getString('email') ?? '';
      nameController.text = "${prefs.getString('first_name')} ${prefs.getString('last_name')}";
      phoneController.text = prefs.getString('phone') ?? '';
    });
  }
  // Form data
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController messageController = TextEditingController();

  String selectedMethod = 'zoom';
  DateTime? selectedDate;
  String? selectedTime;
  List<int> availableSlots = [];

  Map<String, dynamic>? consultationData;

  static const double consultationFee = 50.0;
  static const String apiBase = 'https://migrantifly-backend.onrender.com/api';

  final List<Map<String, String>> methods = [
    {'value': 'zoom', 'label': 'Zoom (Online)', 'icon': '🎥'},
    {'value': 'phone', 'label': 'Phone Call', 'icon': '☎️'},
    {'value': 'in-person', 'label': 'In-Person', 'icon': '👤'},
    {'value': 'google-meet', 'label': 'Google Meet', 'icon': '📹'},
  ];

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    messageController.dispose();
    super.dispose();
  }

  Future<void> fetchAvailableSlots(DateTime date) async {
    setState(() {
      slotsLoading = true;
      error = null;
    });

    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      final response = await http.get(
        Uri.parse('$apiBase/consultation/available-slots?date=$dateStr'),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          availableSlots = List<int>.from(data['data']['availableSlots']);
          selectedTime = null;
        });
      } else {
        throw Exception(data['message'] ?? 'Failed to fetch slots');
      }
    } catch (e) {
      setState(() {
        error = e.toString();
        availableSlots = [];
      });
    } finally {
      setState(() => slotsLoading = false);
    }
  }

  bool validateStep1() {
    if (nameController.text.trim().isEmpty) {
      setState(() => error = 'Full name is required');
      return false;
    }
    if (emailController.text.trim().isEmpty) {
      setState(() => error = 'Email is required');
      return false;
    }
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(emailController.text)) {
      setState(() => error = 'Please enter a valid email');
      return false;
    }
    if (phoneController.text.trim().isEmpty) {
      setState(() => error = 'Phone number is required');
      return false;
    }
    return true;
  }

  bool validateStep2() {
    if (selectedDate == null) {
      setState(() => error = 'Please select a date');
      return false;
    }
    if (selectedTime == null) {
      setState(() => error = 'Please select a time');
      return false;
    }
    return true;
  }

  Future<void> handleNextStep() async {
    setState(() => error = null);

    if (step == 1) {
      if (validateStep1()) {
        setState(() => step = 2);
      }
    } else if (step == 2) {
      if (validateStep2()) {
        setState(() => step = 3);
      }
    } else if (step == 3) {
      await handleBooking();
    }
  }

  Future<void> handleBooking() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final response = await http.post(
        Uri.parse('$apiBase/consultation/book'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'clientName': nameController.text,
          'clientEmail': emailController.text,
          'clientPhone': phoneController.text,
          'preferredDate': DateFormat('yyyy-MM-dd').format(selectedDate!),
          'preferredTime': selectedTime,
          'method': selectedMethod,
          'message': messageController.text,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          consultationData = data['data'];
          step = 4;
        });
      } else {
        throw Exception(data['message'] ?? 'Booking failed');
      }
    } catch (e) {
      setState(() => error = e.toString());
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> handlePayment() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final response = await http.post(
        Uri.parse('$apiBase/payments/create-consultation-payment'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'consultationId': consultationData!['consultationId'],
          'paymentId': consultationData!['paymentId'],
          'amount': consultationFee,
          'email': emailController.text,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final checkoutUrl = data['data']['checkoutUrl'] ??
            data['data']['url'] ??
            data['data']['sessionUrl'];

        if (checkoutUrl == null) {
          throw Exception('Checkout URL was not returned by the server.');
        }

        // Launch the Stripe checkout URL
        final Uri url = Uri.parse(checkoutUrl);
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        } else {
          throw Exception('Could not launch payment URL');
        }
      } else {
        throw Exception(data['message'] ?? 'Failed to initialize payment');
      }
    } catch (e) {
      setState(() => error = e.toString());
    } finally {
      setState(() => loading = false);
    }
  }

  void resetModal() {
    nameController.clear();
    emailController.clear();
    phoneController.clear();
    messageController.clear();
    setState(() {
      step = 1;
      selectedMethod = 'zoom';
      selectedDate = null;
      selectedTime = null;
      error = null;
      success = null;
      consultationData = null;
      availableSlots = [];
    });
    widget.onClose();
  }

  String getMethodLabel(String value) {
    final method = methods.firstWhere((m) => m['value'] == value);
    return method['label']!;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        clipBehavior: Clip.hardEdge,
        constraints: const BoxConstraints(maxWidth: 700, maxHeight: 700),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF0F172A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.blue.withOpacity(0.2),
                    Colors.purple.withOpacity(0.2)
                  ],
                ),
                border: Border(
                  bottom: BorderSide(color: Colors.white.withOpacity(0.1)),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Book a Consultation',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Step $step of 4',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue[200],
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: resetModal,
                    icon: const Icon(Icons.close, color: Colors.white),
                    iconSize: 28,
                  ),
                ],
              ),
            ),

            // Progress Bar
            LinearProgressIndicator(
              value: step / 4,
              backgroundColor: const Color(0xFF334155),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    if (error != null) _buildErrorMessage(),
                    if (success != null) _buildSuccessMessage(),
                    const SizedBox(height: 16),
                    if (step == 1) _buildStep1(),
                    if (step == 2) _buildStep2(),
                    if (step == 3) _buildStep3(),
                    if (step == 4) _buildStep4(),
                  ],
                ),
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A).withOpacity(0.5),
                border: Border(
                  top: BorderSide(color: Colors.white.withOpacity(0.1)),
                ),
              ),
              child: Row(
                children: [
                  if (step > 1 && step < 4)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => setState(() => step--),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.white.withOpacity(0.2)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          'Back',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                  if (step > 1 && step < 4) const SizedBox(width: 16),
                  if (step < 4)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: loading ? null : handleNextStep,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: loading
                            ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                            : Text(
                          step == 3 ? 'Book Consultation' : 'Next',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  if (step == 4) ...[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: resetModal,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.white.withOpacity(0.2)),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          'Close',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: handlePayment,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          'Proceed to Payment',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        border: Border.all(color: Colors.red.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red[300]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              error!,
              style: TextStyle(color: Colors.red[200]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessMessage() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        border: Border.all(color: Colors.green.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline, color: Colors.green[300]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              success!,
              style: TextStyle(color: Colors.green[200]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          unEditable: true,
          label: 'Full Name *',
          controller: nameController,
          hint: 'John Doe',
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                unEditable: true,
                label: 'Email Address *',
                controller: emailController,
                hint: 'you@example.com',
                keyboardType: TextInputType.emailAddress,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                unEditable: true,
                label: 'Phone Number *',
                controller: phoneController,
                hint: '+1 (555) 123-4567',
                keyboardType: TextInputType.phone,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const Text(
          'Consultation Method *',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.5,
          ),
          itemCount: methods.length,
          itemBuilder: (context, index) {
            final method = methods[index];
            final isSelected = selectedMethod == method['value'];
            return InkWell(
              onTap: () => setState(() {
                selectedMethod = method['value']!;
                error = null;
              }),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.blue.withOpacity(0.2)
                      : Colors.white.withOpacity(0.05),
                  border: Border.all(
                    color: isSelected
                        ? Colors.blue
                        : Colors.white.withOpacity(0.2),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(method['icon']!, style: const TextStyle(fontSize: 18)),
                    const SizedBox(height: 4),
                    Text(
                      method['label']!,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey[300],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Preferred Date *',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: selectedDate ?? DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (date != null) {
              setState(() => selectedDate = date);
              await fetchAvailableSlots(date);
            }
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedDate == null
                      ? 'Select a date'
                      : DateFormat('EEEE, MMMM d, yyyy').format(selectedDate!),
                  style: TextStyle(
                    color: selectedDate == null ? Colors.grey : Colors.white,
                  ),
                ),
                const Icon(Icons.calendar_today, color: Colors.white),
              ],
            ),
          ),
        ),
        if (selectedDate != null) ...[
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Available Times *',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              if (slotsLoading)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (availableSlots.isNotEmpty)
            Container(
              constraints: const BoxConstraints(maxHeight: 250),
              child: GridView.builder(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 2,
                ),
                itemCount: availableSlots.length,
                itemBuilder: (context, index) {
                  final hour = availableSlots[index];
                  final timeStr = '${hour.toString().padLeft(2, '0')}:00';
                  final isSelected = selectedTime == timeStr;
                  return InkWell(
                    onTap: () => setState(() {
                      selectedTime = timeStr;
                      error = null;
                    }),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.blue.withOpacity(0.2)
                            : Colors.white.withOpacity(0.05),
                        border: Border.all(
                          color: isSelected
                              ? Colors.blue
                              : Colors.white.withOpacity(0.2),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          timeStr,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.grey[300],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.yellow.withOpacity(0.1),
                border: Border.all(color: Colors.yellow.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'No available slots for this date. Please select another date.',
                style: TextStyle(color: Colors.yellow[200], fontSize: 14),
              ),
            ),
        ],
        const SizedBox(height: 20),
        _buildTextField(
          label: 'Additional Message',
          controller: messageController,
          hint: 'Tell us about your migration goals and any specific questions...',
          maxLines: 4,
        ),
      ],
    );
  }

  Widget _buildStep3() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Booking Summary',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: _buildInfoRow('Name', nameController.text)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildInfoRow('Email', emailController.text)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildInfoRow('Phone', phoneController.text)),
                  const SizedBox(width: 16),
                  Expanded(
                      child: _buildInfoRow('Method', getMethodLabel(selectedMethod))),
                ],
              ),
              const Divider(color: Colors.white24, height: 32),
              Row(
                children: [
                  const Icon(Icons.access_time, color: Colors.blue, size: 20),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Scheduled for',
                        style: TextStyle(color: Colors.grey[400], fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${DateFormat('EEEE, MMMM d, yyyy').format(selectedDate!)} at $selectedTime',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (messageController.text.isNotEmpty) ...[
                const Divider(color: Colors.white24, height: 32),
                Text(
                  'Message',
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
                const SizedBox(height: 8),
                Text(
                  messageController.text,
                  style: TextStyle(
                    color: Colors.grey[200],
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.blue.withOpacity(0.2),
                Colors.purple.withOpacity(0.2)
              ],
            ),
            border: Border.all(color: Colors.blue.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              const Text(
                'Consultation Fee',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Service Fee',
                    style: TextStyle(color: Colors.grey[300]),
                  ),
                  Text(
                    '\$${consultationFee.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Divider(color: Colors.white24, height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '\$${consultationFee.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.lightBlueAccent,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'By proceeding, you agree to pay the consultation fee. You will receive a confirmation email with meeting details.',
          style: TextStyle(color: Colors.grey[400], fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildStep4() {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.2),
            border: Border.all(color: Colors.green, width: 2),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_circle, color: Colors.green, size: 32),
        ),
        const SizedBox(height: 24),
        const Text(
          'Slot Reserved!',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Your consultation slot has been reserved. Complete payment to confirm your booking.',
          style: TextStyle(color: Colors.grey[300]),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Booking Details',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              _buildPaymentRow('Consultation ID',
                  consultationData!['consultationId'].toString().substring(consultationData!['consultationId'].toString().length - 8)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Status', style: TextStyle(color: Colors.grey[400])),
                  const Text(
                    'Pending Payment',
                    style: TextStyle(
                      color: Colors.yellow,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const Divider(color: Colors.white24, height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Amount Due',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '\$${consultationFee.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.lightBlueAccent,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    bool unEditable = false,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          readOnly: unEditable,
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400]),
            filled: true,
            fillColor: Colors.white.withOpacity(0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.blue, width: 2),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey[400], fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[400])),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }}