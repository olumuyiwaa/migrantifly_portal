import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../api/api_get.dart';
import '../../constants.dart';
import '../../models/class_deadlines.dart';
import '../../models/project.dart';
import '../../responsive.dart';

class Calendar extends StatefulWidget {
  const Calendar({super.key,});

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  int selectedYear = DateTime.now().year;
  DateTime selectedDate = DateTime.now();
  DateTime focusedDay = DateTime.now();
  List<DueDeadline> _deadlines =[];
  DeadlinesSummary? _summary;

  @override
  void initState() {
    super.initState();
    loadDeadlines();
  }

  Future<void> loadDeadlines() async {
    try {
      final deadlines = await fetchDeadlines();
      setState(() {
        _deadlines = deadlines.deadlines;
        _summary = deadlines.summary;
      });

      // Optionally, force refresh in background
      fetchDeadlines(forceRefresh: true).then((fresh) {
        setState(() {
          _deadlines = fresh.deadlines;
          _summary = fresh.summary;
        });
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  List<DueDeadline> _getDeadlinesForDate(DateTime date) {
    return _deadlines.where((d) {
      return d.deadline.dueDate.year == date.year &&
          d.deadline.dueDate.month == date.month &&
          d.deadline.dueDate.day == date.day;
    }).toList();
  }

  // Get deadline statistics for a specific month
  Map<String, int> _getMonthDeadlineStats(int month) {
    final monthDeadlines = _deadlines.where((d) {
      return d.deadline.dueDate.year == selectedYear &&
          d.deadline.dueDate.month == month;
    }).toList();

    int total = monthDeadlines.length;
    int overdue = monthDeadlines.where((d) => d.overdue).length;
    int upcoming = total - overdue;

    return {
      'total': total,
      'overdue': overdue,
      'upcoming': upcoming,
    };
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(12),
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.end,
              spacing: 16,runSpacing: 16,
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
      width: 374,
      child: !Responsive.isMobile(context)?Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: [
          Column(
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
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                      }),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ):Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
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
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                      }),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() => Container(
    width: 374,
    decoration: BoxDecoration(
        border: Border.all(color: Colors.blue, width: 2),
        borderRadius: BorderRadius.circular(8)),
    child: Row(children: [
      _buildCard("${_summary?.total ?? 0}", 'Total\nDeadlines'),
      Container(width: 2, height: 80, color: Colors.blue),
      _buildCard("${_summary?.overdue ?? 0}", 'Overdue\nAlready', textColor: Colors.red),
      Container(width: 2, height: 80, color: Colors.blue),
      _buildCard("${_summary?.dueSoon ?? 0}", 'Due\nSoon'),
      Container(width: 2, height: 80, color: Colors.blue),
      _buildCard("${_summary?.dueToday ?? 0}", 'Due\nToday'),
    ]),
  );

  Widget _buildCard(String value, String label, {Color? textColor}) =>
      Expanded(
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Text(value,
                  style: TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.bold,
                      color: textColor)),
              Text(label,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: textColor)),
            ],
          ),
        ),
      );

  Widget _buildCalendarGrid() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.88,
      child: SingleChildScrollView(
        child:  !Responsive.isMobile(context)? Column(
          spacing: defaultPadding,
          children: [
            _buildCalendarRow([1, 2, 3, 4]),
            _buildCalendarRow([5, 6, 7, 8]),
            _buildCalendarRow([9, 10, 11, 12]),
          ],
        ):Column(
          spacing: defaultPadding,
          children: [
            _buildCalendarRow([1, 2]),
            _buildCalendarRow([3, 4]),
            _buildCalendarRow([5, 6]),
            _buildCalendarRow([7, 8]),
            _buildCalendarRow([9, 10]),
            _buildCalendarRow([11, 12]),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarRow(List<int> months) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: months
        .map((m) => Expanded(
        child: SizedBox(height: 292, child: _buildMonthCalendar(m))))
        .toList(),
  );

  Widget _buildMonthCalendar(int month) {
    final daysInMonth = DateTime(selectedYear, month + 1, 0).day;
    final firstWeekday = DateTime(selectedYear, month, 1).weekday;
    final monthName = DateFormat('MMMM').format(DateTime(selectedYear, month));
    final deadlineStats = _getMonthDeadlineStats(month);

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

          // Get deadlines for this day
          final deadlinesForDay = _getDeadlinesForDate(curr);
          final hasDeadline = deadlinesForDay.isNotEmpty;

          weekRow.add(
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() => selectedDate = curr);

                  if (deadlinesForDay.isNotEmpty) {
                    showModalBottomSheet(
                      context: context,
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
                      builder: (context) {
                        return Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(DateFormat.yMMMMd().format(curr),
                                  style: const TextStyle(
                                      fontSize: 18, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 12),
                              ...deadlinesForDay.map((d) => ListTile(
                                leading: Icon(
                                  d.overdue ? Icons.warning : Icons.event,
                                  color: d.overdue ? Colors.red : Colors.blue,
                                ),
                                title: Text(d.deadline.description),
                                subtitle: Text("Visa: ${d.visaType} | Stage: ${d.stage}"),
                                trailing: Text(
                                  DateFormat('dd/MM').format(d.deadline.dueDate),
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              )),
                            ],
                          ),
                        );
                      },
                    );
                  }
                },

                child: Container(
                  margin: const EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.blue : null,
                    borderRadius: BorderRadius.circular(4),
                    border: hasDeadline ? Border.all(color: Colors.orange, width: 2) : null,
                  ),
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
    // Replace working/non-working days stats with deadline stats
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
              Text('Total:', style: TextStyle(fontSize: 12)),
              Text('${deadlineStats['total']}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))
            ]),
            const SizedBox(height: 4),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Overdue:', style: const TextStyle(color: Colors.red, fontSize: 12)),
              Text('${deadlineStats['overdue']}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.red, fontSize: 12))
            ]),
            const SizedBox(height: 4),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Upcoming:', style: const TextStyle(color: Colors.green, fontSize: 12)),
              Text('${deadlineStats['upcoming']}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.green, fontSize: 12))
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
        });
      }
    });
  }
}