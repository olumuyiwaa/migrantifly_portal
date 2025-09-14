import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../constants.dart';
import '../../models/project.dart';

class Calendar extends StatefulWidget {
  const Calendar({super.key,});

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  List<String> locations = ['Paris', 'London', 'New York', 'Tokyo'];
  late String selectedBranch = locations[0];
  int selectedYear = DateTime.now().year;
  DateTime selectedDate = DateTime.now();
  DateTime focusedDay = DateTime.now();

  late Map<int, Map<String, int>> monthlyStats;

  @override
  void initState() {
    super.initState();
    _updateMonthlyStats();
  }

  // Generate working and non-working days per month dynamically
  void _updateMonthlyStats() {
    monthlyStats = generateMonthlyStats(selectedYear);
  }

  Map<int, Map<String, int>> generateMonthlyStats(int year) {
    final Map<int, Map<String, int>> stats = {};
    for (int month = 1; month <= 12; month++) {
      int working = 0;
      int nonWorking = 0;
      final int daysInMonth = DateTime(year, month + 1, 0).day;
      for (int d = 1; d <= daysInMonth; d++) {
        final date = DateTime(year, month, d);
        if (date.weekday >= DateTime.monday &&
            date.weekday <= DateTime.friday) {
          working++;
        } else {
          nonWorking++;
        }
      }
      stats[month] = {'working': working, 'non-working': nonWorking};
    }
    return stats;
  }

  // Calculate total working and non-working days
  int get totalWorkingDays =>
      monthlyStats.values.fold(0, (sum, m) => sum + m['working']!);
  int get totalNonWorkingDays =>
      monthlyStats.values.fold(0, (sum, m) => sum + m['non-working']!);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              spacing: 36,
              children: [_buildControls(), _buildSummaryCards()],
            ),
            const SizedBox(height: 36),
            _buildCalendarGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildControls() {
    return SizedBox(
      width: 200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Select using calender',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(4)),
            child: IconButton(
              icon: const Icon(Icons.calendar_today, color: Colors.blue),
              onPressed: () => _showDatePicker(context),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Select the year',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Container(
            width: 160,
            decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(4)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () => setState(() {
                    selectedYear--;
                    _updateMonthlyStats();
                  }),
                ),
                SizedBox(
                  width: 52,
                  child: Center(
                      child: Text(selectedYear.toString(),
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500))),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () => setState(() {
                    selectedYear++;
                    _updateMonthlyStats();
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() => Container(
        decoration: BoxDecoration(
            border: Border.all(color: Colors.blue, width: 2),
            borderRadius: BorderRadius.circular(8)),
        child: Row(children: [
          _buildCard(totalWorkingDays.toString(), 'Working\ndays'),
          Container(width: 2, height: 80, color: Colors.blue),
          _buildCard(totalNonWorkingDays.toString(), 'Weekend\ndays',
              textColor: Colors.red),
        ]),
      );

  Widget _buildCard(String value, String label, {Color? textColor}) =>
      Container(
        width: 124,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: textColor)),
            Text(label,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: textColor)),
          ],
        ),
      );

  Widget _buildCalendarGrid() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.88,
      child: SingleChildScrollView(
        child: Column(
          spacing: defaultPadding,
          children: [
            _buildCalendarRow([1, 2, 3, 4]),
            _buildCalendarRow([5, 6, 7, 8]),
            _buildCalendarRow([9, 10, 11, 12]),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarRow(List<int> months) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: months
            .map((m) => Expanded(
                child: SizedBox(height: 272, child: _buildMonthCalendar(m))))
            .toList(),
      );

  Widget _buildMonthCalendar(int month) {
    final daysInMonth = DateTime(selectedYear, month + 1, 0).day;
    final firstWeekday = DateTime(selectedYear, month, 1).weekday;
    final monthName = DateFormat('MMMM').format(DateTime(selectedYear, month));
    final stats = monthlyStats[month]!;

    int dayNum = 1;
    List<Widget> colChildren = [
      Text(monthName,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          textAlign: TextAlign.center),
      const SizedBox(height: 4),
      Row(
          children: ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su']
              .map((d) => Expanded(
                  child: Text(d,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      textAlign: TextAlign.center)))
              .toList()),
    ];

    for (int week = 0; week < 6; week++) {
      if (dayNum > daysInMonth) break;
      List<Widget> weekRow = [];
      for (int wd = 1; wd <= 7; wd++) {
        if ((week == 0 && wd < firstWeekday) || dayNum > daysInMonth) {
          weekRow.add(const Expanded(child: SizedBox()));
        } else {
          final curr = DateTime(selectedYear, month, dayNum);
          final isWeekend = curr.weekday >= DateTime.saturday;
          final isSelected = curr.year == selectedDate.year &&
              curr.month == selectedDate.month &&
              curr.day == selectedDate.day;

          weekRow.add(
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => selectedDate = curr),
                child: Container(
                  margin: const EdgeInsets.all(1),
                  decoration: isSelected
                      ? BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(4))
                      : null,
                  height: 24,
                  child: Center(
                    child: Text(
                      '$dayNum',
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : isWeekend
                                ? Colors.red
                                : null,
                        fontWeight: isSelected ? FontWeight.bold : null,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
          dayNum++;
        }
      }
      colChildren.add(Row(children: weekRow));
    }

    colChildren.add(const Spacer());
    colChildren.add(
      Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(4)),
        child: Column(
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Working days:'),
              Text('${stats['working']}',
                  style: const TextStyle(fontWeight: FontWeight.bold))
            ]),
            const SizedBox(height: 4),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Weekend days:', style: const TextStyle(color: Colors.red)),
              Text('${stats['non-working']}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.red))
            ]),
          ],
        ),
      ),
    );

    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(children: colChildren));
  }

  void _showDatePicker(BuildContext context) {
    showDatePicker(
      context: context,
      initialDate: DateTime(selectedYear),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
              onSurface: Colors.black),
          textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: Colors.blue)),
          dialogTheme: const DialogThemeData(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
          ),
          datePickerTheme: const DatePickerThemeData(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)))),
        ),
        child: child!,
      ),
    ).then((picked) {
      if (picked != null) {
        setState(() {
          selectedDate = picked;
          selectedYear = picked.year;
          _updateMonthlyStats();
        });
      }
    });
  }
}
