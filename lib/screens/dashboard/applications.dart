import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../components/application_list_filter.dart';
import '../../components/application_list_table.dart';
import '../../constants.dart';
import '../../models/class_users.dart';
import '../../models/project.dart';


class Events extends StatefulWidget {

  const Events({
    super.key,
  });

  @override
  State<Events> createState() => _EventsState();
}

class _EventsState extends State<Events> {

  void _handleFilterChange(List<String> statuses, List<String> countries) {
   setState(() {
     selectedCountries = listEquals(countries, ["All"])?[]:countries;
     print('Selected countries: $selectedCountries');
   });
  }
  List<String> selectedCountries = [];
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Column(spacing: defaultPadding, children: [
          ApplicationListFilters(
        onFilterChanged: _handleFilterChange,
      ),
      SizedBox(
          height: 692,
          child: ApplicationListTable(
            userID: "", filter: selectedCountries,
          ))
    ]));
  }
}
