import 'package:flutter/material.dart';

import '../constants.dart';
import '../models/class_applications.dart';
import '../responsive.dart';
import 'forms/event_details_form.dart';

class EventListFilters extends StatefulWidget {
  final Function(List<String>, List<String>) onFilterChanged;

  const EventListFilters({
    super.key,
    required this.onFilterChanged,
  });

  @override
  State<EventListFilters> createState() => _EventListFiltersState();
}

class _EventListFiltersState extends State<EventListFilters> {
  // Industry options
  final List<String> countryOptions = [
    'All',
    "Algeria",
    "Angola",
    "Benin",
    "Botswana",
    "Burkina Faso",
    "Burundi",
    "Cabo Verde",
    "Cameroon",
    "Central African Republic",
    "Chad",
    "Comoros",
    "Congo",
    "Congo (DRC)",
    "Djibouti",
    "Egypt",
    "Equatorial Guinea",
    "Eritrea",
    "Eswatini",
    "Ethiopia",
    "Gabon",
    "Gambia",
    "Ghana",
    "Guinea",
    "Guinea-Bissau",
    "Ivory Coast",
    "Kenya",
    "Lesotho",
    "Liberia",
    "Libya",
    "Madagascar",
    "Malawi",
    "Mali",
    "Mauritania",
    "Mauritius",
    "Morocco",
    "Mozambique",
    "Namibia",
    "Niger",
    "Nigeria",
    "Rwanda",
    "Sao Tome and Principe",
    "Senegal",
    "Seychelles",
    "Sierra Leone",
    "Somalia",
    "South Africa",
    "South Sudan",
    "Sudan",
    "Tanzania",
    "Togo",
    "Tunisia",
    "Uganda",
    "Zambia",
    "Zimbabwe"
  ];

  // Status options with corresponding counts
  final Map<String, int> _statusCounts = {
    'Completed': 581,
    'Upcoming': 1000,
  };

  // Selected filters
  List<String> _selectedPractice = ['All'];
  List<String> _selectedStatuses = [];

  void _updateFilters() {
    widget.onFilterChanged(_selectedStatuses, _selectedPractice);
  }

  void _showEventFormModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(16.0),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.9,
            child: EventDetailsForm(
              event: Application.empty(), isEditing: false, onSave: () {  },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          color: secondaryColor,
          borderRadius: const BorderRadius.all(Radius.circular(10)),
        ),
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
             Padding(
              padding: EdgeInsets.only(bottom: 16.0),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Event list',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  if (!Responsive.isMobile(context))
                    ElevatedButton.icon(
                      icon: const Icon(
                        Icons.add,
                        color: Colors.white,
                      ),
                      label: const Text('Create Event'),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        _showEventFormModal(context);
                      },
                    ),
                ],
              ),
            ),

            // Industry filter
            Padding(
              padding: const EdgeInsets.only(bottom: defaultPadding),
              child: !Responsive.isMobile(context)
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          alignment: Alignment.centerLeft,
                          width: 80,
                          child: Text(
                            'Theme\n(Country)',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Wrap(
                            spacing: 8.0,
                            runSpacing: 8.0,
                            children: countryOptions.map((industry) {
                              return FilterChip(
                                label: Text(industry),
                                selected: _selectedPractice.contains(industry),
                                onSelected: (selected) {
                                  setState(() {
                                    if (selected) {
                                      // If "All" is selected, clear other selections
                                      if (industry == 'All') {
                                        _selectedPractice = ['All'];
                                      } else {
                                        // If another option is selected, remove "All"
                                        _selectedPractice.remove('All');
                                        // Add the selected industry
                                        _selectedPractice.add(industry);
                                      }
                                    } else {
                                      // Remove the industry if unselected
                                      _selectedPractice.remove(industry);
                                      // If nothing is selected, default to "All"
                                      if (_selectedPractice.isEmpty) {
                                        _selectedPractice = ['All'];
                                      }
                                    }
                                    _updateFilters();
                                  });
                                },
                                backgroundColor: Colors.white,
                                selectedColor: Colors.blue,
                                checkmarkColor: Colors.white,
                                labelStyle: TextStyle(
                                  color: _selectedPractice.contains(industry)
                                      ? Colors.white
                                      : Colors.black,
                                  fontWeight: FontWeight.w500,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: BorderSide(
                                    color: _selectedPractice.contains(industry)
                                        ? Colors.blue
                                        : Colors.grey.shade300,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          alignment: Alignment.centerLeft,
                          width: 80,
                          height: 34,
                          child: Text(
                            'Theme\n(Country)',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          children: countryOptions.map((industry) {
                            return FilterChip(
                              label: Text(industry),
                              selected: _selectedPractice.contains(industry),
                              onSelected: (selected) {
                                setState(() {
                                  if (selected) {
                                    // If "All" is selected, clear other selections
                                    if (industry == 'All') {
                                      _selectedPractice = ['All'];
                                    } else {
                                      // If another option is selected, remove "All"
                                      _selectedPractice.remove('All');
                                      // Add the selected industry
                                      _selectedPractice.add(industry);
                                    }
                                  } else {
                                    // Remove the industry if unselected
                                    _selectedPractice.remove(industry);
                                    // If nothing is selected, default to "All"
                                    if (_selectedPractice.isEmpty) {
                                      _selectedPractice = ['All'];
                                    }
                                  }
                                  _updateFilters();
                                });
                              },
                              backgroundColor: Colors.white,
                              selectedColor: Colors.blue,
                              checkmarkColor: Colors.white,
                              labelStyle: TextStyle(
                                color: _selectedPractice.contains(industry)
                                    ? Colors.white
                                    : Colors.black,
                                fontWeight: FontWeight.w500,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(
                                  color: _selectedPractice.contains(industry)
                                      ? Colors.blue
                                      : Colors.grey.shade300,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
            ),

            // Status filter
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: !Responsive.isMobile(context)
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          alignment: Alignment.centerLeft,
                          width: 80,
                          height: 34,
                          child: Text(
                            'Status',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Status checkboxes
                              Wrap(
                                spacing: 16.0,
                                children: _statusCounts.keys.map((status) {
                                  return Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Checkbox(
                                        value:
                                            _selectedStatuses.contains(status),
                                        onChanged: (value) {
                                          setState(() {
                                            if (value ?? false) {
                                              if (!_selectedStatuses
                                                  .contains(status)) {
                                                _selectedStatuses.add(status);
                                              }
                                            } else {
                                              _selectedStatuses.remove(status);
                                            }
                                            _updateFilters();
                                          });
                                        },
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(3),
                                        ),
                                        checkColor: Colors.white,
                                        activeColor: Colors.blue,
                                      ),
                                      Text(status),
                                    ],
                                  );
                                }).toList(),
                              ),

                              // Status count summary
                              const SizedBox(height: 16),
                              Wrap(
                                spacing: 16.0,
                                children: [
                                  ..._statusCounts.entries
                                      .where((entry) =>
                                          entry.value > 0 &&
                                          _selectedStatuses.contains(entry.key))
                                      .map((entry) {
                                    return Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          entry.key,
                                          style: const TextStyle(
                                            color: Colors.grey,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: entry.key == 'Completed'
                                                ? Colors.blue
                                                : Colors.orange,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            entry.value.toString(),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  }).toList(),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          alignment: Alignment.centerLeft,
                          width: 80,
                          height: 34,
                          child: Text(
                            'Status',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Status checkboxes
                            Wrap(
                              spacing: 16.0,
                              children: _statusCounts.keys.map((status) {
                                return Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Checkbox(
                                      value: _selectedStatuses.contains(status),
                                      onChanged: (value) {
                                        setState(() {
                                          if (value ?? false) {
                                            if (!_selectedStatuses
                                                .contains(status)) {
                                              _selectedStatuses.add(status);
                                            }
                                          } else {
                                            _selectedStatuses.remove(status);
                                          }
                                          _updateFilters();
                                        });
                                      },
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                      checkColor: Colors.white,
                                      activeColor: Colors.blue,
                                    ),
                                    Text(status),
                                  ],
                                );
                              }).toList(),
                            ),

                            // Status count summary
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 16.0,
                              children: [
                                ..._statusCounts.entries
                                    .where((entry) =>
                                        entry.value > 0 &&
                                        _selectedStatuses.contains(entry.key))
                                    .map((entry) {
                                  return Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        entry.key,
                                        style: const TextStyle(
                                          color: Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: entry.key == 'Completed'
                                              ? Colors.blue
                                              : Colors.orange,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          entry.value.toString(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
            ),
          ],
        ));
  }
}
