import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../api/api_get.dart';
import '../models/class_transactions.dart';
import '../responsive.dart';

class AnalyticsDashboard extends StatefulWidget {
  const AnalyticsDashboard({super.key});

  @override
  State<AnalyticsDashboard> createState() => _AnalyticsDashboardState();
}

class _AnalyticsDashboardState extends State<AnalyticsDashboard> {
  String _selectedYear = DateTime.now().year.toString();
  String _selectedFilter = 'Completed'; // Track selected filter
  List<String> years = [
    DateTime.now().year.toString(),
    (DateTime.now().year - 1).toString(),
    (DateTime.now().year - 2).toString(),
    (DateTime.now().year - 3).toString(),
    (DateTime.now().year - 4).toString(),
  ];
  List<Transaction> transactions = [];
  bool _isLoadingTransactions = false;

  @override
  void initState() {
    super.initState();
    _fetchAllTransactions();
  }

  Future<void> _fetchAllTransactions() async {
    if (mounted) setState(() => _isLoadingTransactions = true);
    try {
      // Load cached data first
      transactions = await loadCachedTransactions();
      if (mounted && transactions.isNotEmpty) {
        setState(() {});
      }

      // Fetch fresh data
      final freshTransactions = await TransactionApi.fetchTransactions();
      await cacheTransactions(freshTransactions);

      if (mounted) {
        setState(() {
          transactions = freshTransactions;
          _isLoadingTransactions = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching transactions: $e');
      if (mounted) {
        setState(() => _isLoadingTransactions = false);
      }
    }
  }

  // Calculate monthly transaction amounts
  List<double> _calculateMonthlyAmounts(bool completedOnly) {
    List<double> monthlyAmounts = List.filled(12, 0.0);

    for (Transaction transaction in transactions) {
      // Filter by selected year
      if (transaction.createdAt.year.toString() != _selectedYear) {
        continue;
      }

      // Filter by completion status if needed
      if (completedOnly && !_isTransactionCompleted(transaction)) {
        continue;
      }

      int monthIndex = transaction.createdAt.month - 1; // Convert to 0-based index
      monthlyAmounts[monthIndex] += transaction.amount;
    }

    return monthlyAmounts;
  }

  // Check if transaction is completed (paid)
  bool _isTransactionCompleted(Transaction transaction) {
    return transaction.paymentStatus.toLowerCase() == 'paid' ||
        transaction.paymentStatus.toLowerCase() == 'completed' ||
        transaction.paymentStatus.toLowerCase() == 'success';
  }

  // Check if there are any transactions for the selected year
  bool _hasTransactionsForYear() {
    return transactions.any((transaction) =>
    transaction.createdAt.year.toString() == _selectedYear);
  }

  // Check if there are any transactions matching the current filter
  bool _hasTransactionsForFilter() {
    for (Transaction transaction in transactions) {
      if (transaction.createdAt.year.toString() != _selectedYear) {
        continue;
      }

      if (_selectedFilter == 'All') {
        return true;
      } else if (_selectedFilter == 'Completed' && _isTransactionCompleted(transaction)) {
        return true;
      }
    }
    return false;
  }

  // Get maximum value for chart scaling
  double _getMaxValue() {
    List<double> allAmounts = _calculateMonthlyAmounts(false);
    double maxAmount = allAmounts.isEmpty ? 1000 : allAmounts.reduce((a, b) => a > b ? a : b);
    // Round up to nearest 10000 for better chart appearance
    return ((maxAmount / 10000).ceil() * 10000).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(Responsive.isMobile(context) ? 8 : 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 32),
            _isLoadingTransactions
                ? const Center(child: CircularProgressIndicator())
                : _buildContentSection(),
          ],
        ));
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          spacing: 8,
          children: [
            Icon(
              Icons.analytics_rounded,
              size: 32,
              color: Colors.grey,
            ),
            const Text(
              'Analytics',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Row(
          spacing: 8,
          children: [
            _buildFilterButton('Completed'),
            _buildFilterButton('All'),
            _buildYearDropdown(),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterButton(String filter) {
    bool isSelected = _selectedFilter == filter;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = filter;
        });
      },
      child: Container(
        constraints: BoxConstraints(minWidth: 56),
        padding: EdgeInsets.symmetric(horizontal: 8),
        alignment: Alignment.center,
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              width: 1,
              color: isSelected ? Colors.blue : Colors.grey.shade300
          ),
          color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.transparent,
        ),
        child: Row(
          spacing: 4,
          children: [
            Container(
              height: 20,
              width: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? Colors.blue : Colors.blue.withOpacity(.2),
              ),
            ),
            Text(
              filter,
              style: TextStyle(
                color: isSelected ? Colors.blue : Colors.black,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildYearDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(5),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedYear,
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedYear = newValue;
              });
            }
          },
          items: years.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildContentSection() {
    if (!_hasTransactionsForYear()) {
      return _buildEmptyState(
        title: 'No Data for $_selectedYear',
        message: 'There are no transactions recorded for this year.',
        icon: Icons.calendar_today_outlined,
      );
    }

    if (!_hasTransactionsForFilter()) {
      return _buildEmptyState(
        title: 'No ${_selectedFilter} Transactions',
        message: 'There are no ${_selectedFilter.toLowerCase()} transactions for $_selectedYear.',
        icon: Icons.filter_list_off_outlined,
      );
    }

    return _buildChartSection();
  }

  Widget _buildEmptyState({
    required String title,
    required String message,
    required IconData icon,
  }) {
    return Container(
      height: 420,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            OutlinedButton.icon(
              onPressed: _fetchAllTransactions,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh Data'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.blue,
                side: const BorderSide(color: Colors.blue),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartSection() {
    List<double> allTransactionAmounts = _calculateMonthlyAmounts(false);
    List<double> completedTransactionAmounts = _calculateMonthlyAmounts(true);
    double maxY = _getMaxValue();

    return SizedBox(
      height: 420,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              tooltipBgColor: Colors.blueGrey.shade800,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                String month = getMonthName(groupIndex);
                String amount = '\$${rod.toY.toStringAsFixed(0)}';
                String type = _selectedFilter == 'All' ? 'All' : 'Completed';
                return BarTooltipItem(
                  '$month ($type): $amount',
                  const TextStyle(color: Colors.white),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) {
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(getMonthName(value.toInt(), short: true)),
                  );
                },
                reservedSize: 30,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) {
                  if (value == 0) return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text('0', style: const TextStyle(fontSize: 12)),
                  );

                  // Dynamic scaling for Y-axis labels
                  String text = '';
                  if (value >= 1000000) {
                    text = '${(value / 1000000).toStringAsFixed(1)}M';
                  } else if (value >= 1000) {
                    text = '${(value / 1000).toStringAsFixed(0)}K';
                  } else {
                    text = value.toStringAsFixed(0);
                  }

                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(text, style: const TextStyle(fontSize: 12)),
                  );
                },
                reservedSize: 40,
                interval: maxY / 4, // Show 4 intervals
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: FlGridData(
            show: true,
            horizontalInterval: maxY / 4,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey.shade300,
                strokeWidth: 1,
                dashArray: [5, 5],
              );
            },
            getDrawingVerticalLine: (value) {
              return FlLine(
                color: Colors.transparent,
                strokeWidth: 0,
              );
            },
          ),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(12, (index) {
            double backgroundValue = allTransactionAmounts[index];
            double foregroundValue = _selectedFilter == 'All'
                ? allTransactionAmounts[index]
                : completedTransactionAmounts[index];

            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: foregroundValue,
                  color: Colors.blue,
                  width: 24,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: backgroundValue,
                    color: Colors.blue.withOpacity(0.1), // Light blue background
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  String getMonthName(int monthIndex, {bool short = false}) {
    final List<String> monthsLong = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    final List<String> monthsShort = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];

    if (monthIndex >= 0 && monthIndex < 12) {
      return short ? monthsShort[monthIndex] : monthsLong[monthIndex];
    }
    return '';
  }
}