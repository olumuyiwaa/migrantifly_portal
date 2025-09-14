// pages/transactions.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import '../../api/api_get.dart';
import '../../components/transaction_details_page.dart';
import '../../constants.dart';
import '../../models/class_transactions.dart';


class Transactions extends StatefulWidget {
  const Transactions({super.key});

  @override
  State<Transactions> createState() => _TransactionsState();
}

class _TransactionsState extends State<Transactions> {
  int _selectedIndex = -1;
  bool _isWideScreen = true;
  bool _isLoadingTransactions = true;
  List<Transaction> transactions = [];
  List<Transaction> filteredTransactions = [];
  TextEditingController searchController = TextEditingController();
  String selectedStatus = "All";
  String selectedPaymentStatus = "All";

  @override
  void initState() {
    super.initState();
    _fetchAllTransactions();
    _updateScreenSize();
    searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _filterTransactions();
  }

  Future<void> _fetchAllTransactions() async {
    if (mounted) setState(() => _isLoadingTransactions = true);
    try {
      // Load cached data first
      transactions = await loadCachedTransactions();
      if (mounted && transactions.isNotEmpty) {
        filteredTransactions = transactions;
        setState(() {});
      }

      // Fetch fresh data
      final freshTransactions = await TransactionApi.fetchTransactions();
      await cacheTransactions(freshTransactions);

      if (mounted) {
        setState(() {
          transactions = freshTransactions;
          filteredTransactions = freshTransactions;
          // Auto-select first transaction if available and none selected
          if (transactions.isNotEmpty && _selectedIndex == -1) {
            _selectedIndex = 0;
          }
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

  void _filterTransactions() {
    String query = searchController.text.toLowerCase();
    setState(() {
      filteredTransactions = transactions.where((transaction) {
        bool matchesSearch = transaction.transactionId.toLowerCase().contains(query) ||
            (transaction.ticketId?.title.toLowerCase().contains(query) ?? false) ||
            transaction.paymentStatus.toLowerCase().contains(query);

        bool matchesStatus = selectedStatus == "All" ||
            (transaction.status?.toLowerCase() == selectedStatus.toLowerCase());

        bool matchesPaymentStatus = selectedPaymentStatus == "All" ||
            transaction.paymentStatus.toLowerCase() == selectedPaymentStatus.toLowerCase();

        return matchesSearch && matchesStatus && matchesPaymentStatus;
      }).toList();

      // Reset selection if filtered list changes
      if (_selectedIndex >= filteredTransactions.length) {
        _selectedIndex = filteredTransactions.isNotEmpty ? 0 : -1;
      }
    });
  }

  void _updateScreenSize() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final width = MediaQuery.of(context).size.width;
      setState(() {
        _isWideScreen = width > 900;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    _updateScreenSize();

    return SizedBox(
      height: MediaQuery.of(context).size.height - 100,
      child: Column(
        children: [
          // Filters and Search Bar
          _buildFiltersAndSearch(),
          const SizedBox(height: defaultPadding),
          // Main Content
          Expanded(
            child: Row(
              spacing: defaultPadding,
              children: [
                if (_isWideScreen || !_isWideScreen && _selectedIndex == -1)
                  Expanded(
                    flex: 1,
                    child: buildTransactionsList(),
                  ),
                if (_isWideScreen || !_isWideScreen && _selectedIndex != -1)
                  Expanded(
                    flex: 3,
                    child: buildTransactionDetails(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersAndSearch() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: Column(
        children: [
          // Search Bar
          TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: "Search by transaction ID, event name, or status...",
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: primaryColor),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Filter Dropdowns
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: selectedStatus,
                  decoration: InputDecoration(
                    labelText: "Transaction Status",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items: ["All", "PENDING", "COMPLETED", "FAILED"]
                      .map((status) => DropdownMenuItem(
                    value: status,
                    child: Text(status),
                  ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedStatus = value!;
                    });
                    _filterTransactions();
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: selectedPaymentStatus,
                  decoration: InputDecoration(
                    labelText: "Payment Status",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items: ["All", "paid", "unpaid"]
                      .map((status) => DropdownMenuItem(
                    value: status,
                    child: Text(status.toUpperCase()),
                  ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedPaymentStatus = value!;
                    });
                    _filterTransactions();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildTransactionsList() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: _isLoadingTransactions
          ? const Center(
        child: CircularProgressIndicator(color: primaryColor),
      )
          : filteredTransactions.isEmpty
          ? const Center(
        child: Text("No transactions found"),
      )
          : ListView.builder(
        itemCount: filteredTransactions.length,
        itemBuilder: (context, index) {
          return _buildTransactionListItem(filteredTransactions[index], index);
        },
      ),
    );
  }

  Widget _buildTransactionListItem(Transaction transaction, int index) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: _selectedIndex == index
              ? Colors.blue.withOpacity(0.09)
              : Colors.white,
          border: Border(
            bottom: BorderSide(color: Colors.grey.withOpacity(0.2), width: 1),
          ),
        ),
        child: Row(
          children: [
            _buildTransactionAvatar(transaction),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          transaction.ticketId?.title ?? "Unknown Event",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      _buildStatusChip(transaction.paymentStatus),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "\$${transaction.amount.toStringAsFixed(2)}",
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        DateFormat('MMM dd, yyyy').format(transaction.createdAt),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "ID: ${transaction.transactionId.substring(0, 16)}...",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionAvatar(Transaction transaction) {
    if (transaction.ticketId?.image.isNotEmpty ?? false) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.network(
          transaction.ticketId!.image,
          width: 52,
          height: 52,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildInitialsAvatar(transaction);
          },
        ),
      );
    } else {
      return _buildInitialsAvatar(transaction);
    }
  }

  Widget _buildInitialsAvatar(Transaction transaction) {
    String initial = transaction.ticketId?.title.isNotEmpty ?? false
        ? transaction.ticketId!.title[0]
        : 'T';

    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: _getStatusColor(transaction.paymentStatus).withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: TextStyle(
          color: _getStatusColor(transaction.paymentStatus),
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getStatusColor(status).withOpacity(0.3)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: _getStatusColor(status),
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'unpaid':
      case 'failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget buildTransactionDetails() {
    if (filteredTransactions.isEmpty || _selectedIndex == -1 || _selectedIndex >= filteredTransactions.length) {
      return const Center(
        child: Text("Select a transaction to view details"),
      );
    }

    final selectedTransaction = filteredTransactions[_selectedIndex];
    return TransactionDetailsPage(transaction: selectedTransaction);
  }
}