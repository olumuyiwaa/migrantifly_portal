import 'package:flutter/material.dart';

import '../../components/input/input_field.dart';
import '../../constants.dart';
import '../../responsive.dart';

class Administration extends StatefulWidget {
  const Administration({super.key});

  @override
  State<Administration> createState() => _AdministrationState();
}

class _AdministrationState extends State<Administration> {
  // Controllers for text fields
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _loginController = TextEditingController();
  final _insuranceController = TextEditingController();
  final _division = TextEditingController();
  final _status = TextEditingController();
  final _date = TextEditingController();
  final _practice = TextEditingController();
  final _plan = TextEditingController();
  final _location = TextEditingController();
  final _practiceInputController = TextEditingController();

  // Bank and Paypal Controllers
  final _bankNameController = TextEditingController();
  final _accountName = TextEditingController();
  final _sortCode = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _paypalUserIdController = TextEditingController();
  final _paypalUserEmailController = TextEditingController();
  final _numberOfEmployeesController = TextEditingController();

  List<String> selectedPractices = [
    'Deep Cleaning',
    'Event Cleaning',
    'Post-Construction Cleaning',
  ];
  List<String> selectedLocation = ['Paris', 'London', 'New York', 'Tokyo'];
  List<String> practices = [
    'Commercial Cleaning',
    'Residential Cleaning',
    'Industrial Cleaning',
    'Deep Cleaning',
    'Event Cleaning',
    'Post-Construction Cleaning',
    'Green Cleaning',
    'Medical Facility Cleaning',
    'Hazardous Waste Cleanup',
    'Janitorial Services',
    'Window Cleaning',
    'Hotel Cleaning',
    'Office Cleaning',
    'School Cleaning',
    'Residential',
    'Commercial',
    'Post-Construction',
    'Seasonal',
    'Industrial',
    'Healthcare',
    'Retail',
    'Educational',
    'Hospitality',
    'Government',
    'Outdoor',
    'Special Event',
    'Move-Out',
    'Renovation Cleanup',
    'Eco-Friendly',
    'Emergency Cleaning'
  ];
  List<String> _filteredPractices = [];
  bool _isSearching = false;
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        spacing: defaultPadding,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.all(16.0),
              child: Column(spacing: 32, children: [
                if (!Responsive.isDesktop(context))
                  Stack(
                    children: [
                      Container(
                        height: 320,
                        width: 320,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.blue.withOpacity(.2)),
                      ),
                      Positioned(
                          bottom: 10,
                          right: 10,
                          child: IconButton(
                              onPressed: () {},
                              icon: Icon(
                                Icons.camera_alt,
                                size: 32,
                              )))
                    ],
                  ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  spacing: defaultPadding,
                  children: [
                    Expanded(child: _buildAdministrationSection()),
                    if (Responsive.isDesktop(context))
                      Column(
                        spacing: 32,
                        children: [
                          Stack(
                            children: [
                              Container(
                                height: 320,
                                width: 320,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.blue.withOpacity(.2)),
                              ),
                              Positioned(
                                  bottom: 10,
                                  right: 24,
                                  child: IconButton(
                                      style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all(
                                                Colors.blue),
                                        foregroundColor:
                                            MaterialStateProperty.all(
                                                Colors.white),
                                      ),
                                      onPressed: () {},
                                      icon: Icon(
                                        Icons.camera_alt,
                                        size: 32,
                                      )))
                            ],
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: _buildSubmitButton(),
                          )
                        ],
                      )
                  ],
                ),
                if (!Responsive.isDesktop(context))
                  Align(
                    alignment: Alignment.centerRight,
                    child: _buildSubmitButton(),
                  )
              ])),
          !Responsive.isMobile(context)
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: defaultPadding,
                  children: [
                    Expanded(flex: 3, child: _buildLocationListSection()),
                    Expanded(flex: 3, child: _buildPracticeDetailsSection())
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: defaultPadding,
                  children: [
                    _buildLocationListSection(),
                    _buildPracticeDetailsSection()
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildAdministrationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Details',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        Row(
          spacing: 16,
          children: [
            Expanded(
                child: Inputfield(
              inputHintText: 'Organisation Name',
              inputTitle: 'Organisation Name',
              textObscure: false,
              textController: _nameController,
              isreadOnly: false,
            )),
            Expanded(
                child: Inputfield(
              inputHintText: 'server@email.com',
              inputTitle: 'Email',
              textObscure: false,
              textController: _emailController,
              isreadOnly: false,
            )),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          spacing: defaultPadding,
          children: [
            Expanded(
                child: Inputfield(
              inputHintText: 'Premium',
              inputTitle: 'Plan',
              textObscure: false,
              textController: _plan,
              isreadOnly: true,
            )),
            Expanded(
                child: Inputfield(
              inputHintText: '300',
              inputTitle: 'No. of Employees',
              textObscure: false,
              textController: _numberOfEmployeesController,
              isreadOnly: false,
              keyboardType: TextInputType.number,
            )),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          spacing: 16,
          children: [
            Expanded(
                child: Inputfield(
              inputHintText: 'Division',
              inputTitle: 'Division',
              textObscure: false,
              textController: _division,
              isreadOnly: false,
            )),
            Expanded(
                child: Inputfield(
              inputHintText: 'Insurance Details',
              inputTitle: 'Insurance Details',
              textObscure: false,
              textController: _insuranceController,
              isreadOnly: false,
            )),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          spacing: 16,
          children: [
            Expanded(
                flex: 2,
                child: Inputfield(
                  inputHintText: '12345xyz**',
                  inputTitle: 'Login',
                  textObscure: false,
                  textController: _loginController,
                  isreadOnly: false,
                )),
            Expanded(
                flex: 2,
                child: Row(
                  spacing: 16,
                  children: [
                    Expanded(
                        child: Inputfield(
                      inputHintText: 'Activated',
                      inputTitle: 'Status',
                      textObscure: false,
                      textController: _status,
                      isreadOnly: true,
                    )),
                    Expanded(
                        child: Inputfield(
                      inputHintText: '13/05/2025',
                      inputTitle: '',
                      textObscure: false,
                      textController: _date,
                      isreadOnly: true,
                    ))
                  ],
                )),
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentDetailsSection() {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Details',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Text(
            'Bank Transfer',
            style: Theme.of(context).textTheme.labelMedium,
          ),
          Row(
            spacing: 16,
            children: [
              Expanded(
                  child: Inputfield(
                inputHintText: 'Bank Name',
                inputTitle: 'Bank Name',
                textObscure: false,
                textController: _bankNameController,
                isreadOnly: false,
              )),
              Expanded(
                  child: Inputfield(
                inputHintText: '1234567890',
                inputTitle: 'Account Number',
                textObscure: false,
                textController: _accountNumberController,
                isreadOnly: false,
                keyboardType: TextInputType.number,
              )),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: 384,
            child: Row(
              spacing: 16,
              children: [
                Expanded(
                    child: Inputfield(
                  inputHintText: 'Account Name',
                  inputTitle: 'Account Name',
                  textObscure: false,
                  textController: _accountName,
                  isreadOnly: false,
                )),
                Expanded(
                    child: Inputfield(
                  inputHintText: 'Sort Code',
                  inputTitle: 'Sort Code',
                  textObscure: false,
                  textController: _sortCode,
                  isreadOnly: false,
                )),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Paypal',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Row(
            spacing: defaultPadding,
            children: [
              Expanded(
                  child: Inputfield(
                inputHintText: '12345xyz**',
                inputTitle: 'Paypal User ID',
                textObscure: false,
                textController: _paypalUserIdController,
                isreadOnly: false,
              )),
              Expanded(
                  child: Inputfield(
                inputHintText: '12345xyz**',
                inputTitle: 'Paypal User Email',
                textObscure: false,
                textController: _paypalUserEmailController,
                isreadOnly: false,
              ))
            ],
          ),
          SizedBox(
            height: 24,
          ),
          Align(
            alignment: Alignment.centerRight,
            child: _buildSubmitButton(),
          )
        ],
      ),
    );
  }

  Widget _buildLocationListSection() {
    final TextEditingController locationInputController =
        TextEditingController();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Location Details',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Text(
            'Add Location',
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(height: 12),

          // Simple text input with add button
          Row(
            children: [
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    controller: locationInputController,
                    decoration: InputDecoration(
                      hintText: 'Enter location name...',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 8),
                    ),
                    onSubmitted: (value) {
                      if (value.trim().isNotEmpty) {
                        setState(() {
                          selectedLocation.add(value.trim());
                          locationInputController.clear();
                        });
                      }
                    },
                  ),
                ),
              ),
              SizedBox(width: 8),
              InkWell(
                  onTap: () {
                    final value = locationInputController.text;
                    if (value.trim().isNotEmpty) {
                      setState(() {
                        selectedLocation.add(value.trim());
                        locationInputController.clear();
                      });
                    }
                  },
                  child: Container(
                    height: 62,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 5,
                        )
                      ],
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Text(
                      'Add',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  )),
            ],
          ),

          const SizedBox(height: 16),
          Text(
            'Selected Locations',
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(height: 8),

          // Display selected practices
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: selectedLocation
                .map((practice) => Chip(
                      label: Text(practice),
                      deleteIcon: Icon(Icons.close, size: 18),
                      onDeleted: () {
                        setState(() {
                          selectedLocation.remove(practice);
                        });
                      },
                    ))
                .toList(),
          ),
          const SizedBox(height: 24),
          Align(
            alignment: Alignment.centerRight,
            child: _buildSubmitButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildPracticeDetailsSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Practice Details',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Text(
            'Add Practices',
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(height: 12),

          // Searchable Practice Dropdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _practiceInputController,
                  decoration: InputDecoration(
                    hintText: 'Search practices...',
                    prefixIcon: Icon(Icons.search),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 8),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _isSearching = value.isNotEmpty;
                      _filteredPractices = practices
                          .where((practice) => practice
                              .toLowerCase()
                              .contains(value.toLowerCase()))
                          .toList();
                    });
                  },
                ),
                if (_isSearching && _filteredPractices.isNotEmpty)
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 5,
                        )
                      ],
                    ),
                    margin: EdgeInsets.only(top: 8),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _filteredPractices.length,
                      itemBuilder: (context, index) {
                        final practice = _filteredPractices[index];
                        final isSelected = selectedPractices.contains(practice);

                        return ListTile(
                          dense: true,
                          title: Text(practice),
                          trailing: isSelected
                              ? Icon(Icons.check_circle, color: Colors.green)
                              : null,
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                selectedPractices.remove(practice);
                              } else {
                                selectedPractices.add(practice);
                              }
                              _practiceInputController.clear();
                              _isSearching = false;
                            });
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          Text(
            'Selected Practices',
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(height: 8),

          // Display selected practices
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: selectedPractices
                .map((practice) => Chip(
                      label: Text(practice),
                      deleteIcon: Icon(Icons.close, size: 18),
                      onDeleted: () {
                        setState(() {
                          selectedPractices.remove(practice);
                        });
                      },
                    ))
                .toList(),
          ),
          const SizedBox(height: 24),
          Align(
            alignment: Alignment.centerRight,
            child: _buildSubmitButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: 200,
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: _submitForm,
        child: const Text(
          'Submit',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void _submitForm() {
    // TODO: Implement form submission logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Form Submitted')),
    );
  }

  @override
  void dispose() {
    // Dispose controllers to prevent memory leaks
    _nameController.dispose();
    _emailController.dispose();
    _loginController.dispose();
    _insuranceController.dispose();
    _bankNameController.dispose();
    _accountNumberController.dispose();
    _paypalUserIdController.dispose();
    _paypalUserEmailController.dispose();
    _numberOfEmployeesController.dispose();
    super.dispose();
  }
}
