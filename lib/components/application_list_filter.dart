import 'package:flutter/material.dart';

import '../api/api_get.dart';
import '../constants.dart';
import '../models/class_applications.dart';
import '../responsive.dart';
import 'forms/event_details_form.dart';

class ApplicationListFilters extends StatefulWidget {
  final Function(List<String>, List<String>) onFilterChanged;

  const ApplicationListFilters({
    super.key,
    required this.onFilterChanged,
  });

  @override
  State<ApplicationListFilters> createState() => _ApplicationListFiltersState();
}

class _ApplicationListFiltersState extends State<ApplicationListFilters> {
  // stage options
  final List<String> stageOptions = [
    'All',
    'consultation',
    'deposit_paid',
    'documents_completed',
    'additional_docs_required',
    'submitted_to_inz',
    'inz_processing',
    'rfi_received',
    'ppi_received',
    'decision'
  ];
  @override
  void initState() {
    super.initState();
    _loadApplications();
  }
  bool isLoading = false;
  List<Application> applications= [];
  Future<void> _loadApplications() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Cached first
      final cached = await loadCachedApplications();
      if (cached.isNotEmpty && mounted) {
        setState(() {
          applications = cached;
        });
      }

      // Fresh data
      final fresh = await getFeaturedApplications();
      if (!mounted) return;

      await cacheApplications(fresh);

      if (!mounted) return;

      setState(() {
        applications = fresh;
        isLoading = false;
      });
    } catch (error) {
      debugPrint("Error loading applications: $error");
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }



  // Selected filters
  List<String> selectedOption = ['All'];
  List<String> _selectedStatuses = [];

  void _updateFilters() {
    widget.onFilterChanged(_selectedStatuses, selectedOption);
  }

  @override
  Widget build(BuildContext context) {
    // Status options with corresponding counts
    final Map<String, int> _statusCounts = {
      'Completed': applications.where((a) => a.stage == "decision").length,
      'Ongoing': applications.where((a) => a.stage != "decision").length,
    };
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
              child: Text(
                'Application List Filter',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // stage filter
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
                            'Stage',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Wrap(
                            spacing: 8.0,
                            runSpacing: 8.0,
                            children: stageOptions.map((stage) {
                              return FilterChip(
                                label: Text(stage.replaceAll("_", " ")),
                                selected: selectedOption.contains(stage),
                                onSelected: (selected) {
                                  setState(() {
                                    if (selected) {
                                      // If "All" is selected, clear other selections
                                      if (stage == 'All') {
                                        selectedOption = ['All'];
                                      } else {
                                        // If another option is selected, remove "All"
                                        selectedOption.remove('All');
                                        // Add the selected stage
                                        selectedOption.add(stage);
                                      }
                                    } else {
                                      // Remove the stage if unselected
                                      selectedOption.remove(stage);
                                      // If nothing is selected, default to "All"
                                      if (selectedOption.isEmpty) {
                                        selectedOption = ['All'];
                                      }
                                    }
                                    _updateFilters();
                                  });
                                },
                                backgroundColor: Colors.white,
                                selectedColor: Colors.blue,
                                checkmarkColor: Colors.white,
                                labelStyle: TextStyle(
                                  color: selectedOption.contains(stage)
                                      ? Colors.white
                                      : Colors.black,
                                  fontWeight: FontWeight.w500,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: BorderSide(
                                    color: selectedOption.contains(stage)
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
                            'Stage',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          children: stageOptions.map((stage) {
                            return FilterChip(
                              label: Text(stage),
                              selected: selectedOption.contains(stage),
                              onSelected: (selected) {
                                setState(() {
                                  if (selected) {
                                    // If "All" is selected, clear other selections
                                    if (stage == 'All') {
                                      selectedOption = ['All'];
                                    } else {
                                      // If another option is selected, remove "All"
                                      selectedOption.remove('All');
                                      // Add the selected stage
                                      selectedOption.add(stage);
                                    }
                                  } else {
                                    // Remove the stage if unselected
                                    selectedOption.remove(stage);
                                    // If nothing is selected, default to "All"
                                    if (selectedOption.isEmpty) {
                                      selectedOption = ['All'];
                                    }
                                  }
                                  _updateFilters();
                                });
                              },
                              backgroundColor: Colors.white,
                              selectedColor: Colors.blue,
                              checkmarkColor: Colors.white,
                              labelStyle: TextStyle(
                                color: selectedOption.contains(stage)
                                    ? Colors.white
                                    : Colors.black,
                                fontWeight: FontWeight.w500,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(
                                  color: selectedOption.contains(stage)
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
