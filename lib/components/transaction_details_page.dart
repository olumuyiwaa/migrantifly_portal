// components/transaction_details_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/class_transactions.dart';


class TransactionDetailsPage extends StatefulWidget {
  final Transaction transaction;

  const TransactionDetailsPage({
    super.key,
    required this.transaction,
  });

  @override
  State<TransactionDetailsPage> createState() => _TransactionDetailsPageState();
}

class _TransactionDetailsPageState extends State<TransactionDetailsPage> {
  bool _isLoading = false;


  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("$label copied to clipboard")),
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
      case 'refunded':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.blue))
          : Column(
        children: [
          // Wiki-style header
          WikiTransactionHeader(
            transaction: widget.transaction,

          ),
          Expanded(
            child: SingleChildScrollView(
              child: WikiTransactionContent(
                transaction: widget.transaction,
                onCopy: _copyToClipboard,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WikiTransactionHeader extends StatelessWidget {
  final Transaction transaction;

  const WikiTransactionHeader({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!, width: 1),
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            // Title and actions
            Row(
              children: [
                Expanded(
                  child: Text(
                    "Transaction Details",
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Georgia',
                    ),
                  ),
                ),
                // Action buttons
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        // Export/Print functionality
                      },
                      icon: Icon(Icons.print, color: Colors.grey[600]),
                      tooltip: "Print Receipt",
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Transaction status bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                border: Border.all(color: Colors.blue[200]!),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  Icon(Icons.receipt_long, size: 16, color: Colors.blue[700]),
                  const SizedBox(width: 8),
                  Text(
                    "Transaction ID: ${transaction.transactionId}",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue[700],
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
}

class WikiTransactionContent extends StatelessWidget {
  final Transaction transaction;
  final Function(String, String) onCopy;

  const WikiTransactionContent({
    super.key,
    required this.transaction,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main content area (left side)
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Transaction Overview
                WikiSection(
                  title: "Transaction Overview",
                  content: _buildTransactionOverview(),
                ),
                const SizedBox(height: 24),

                // Event Information
                if (transaction.ticketId != null)
                  Column(
                    children: [
                      WikiSection(
                        title: "Event Information",
                        content: _buildEventInfo(),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),

                // Payment Details
                WikiSection(
                  title: "Payment Details",
                  content: _buildPaymentDetails(),
                ),
                const SizedBox(height: 24),

                // System Information
                WikiSection(
                  title: "System Information",
                  content: _buildSystemInfo(),
                ),
              ],
            ),
          ),

          const SizedBox(width: 24),

          // Sidebar (right side)
          Expanded(
            flex: 1,
            child: WikiTransactionInfoBox(
              transaction: transaction,
              onCopy: onCopy,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionOverview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "This transaction represents a ${transaction.paymentStatus} payment for ${transaction.ticketCount} ticket(s) "
              "${transaction.ticketId != null ? 'for the event "${transaction.ticketId!.title}"' : ''}. "
              "The transaction was initiated on ${DateFormat('MMMM dd, yyyy \'at\' HH:mm').format(transaction.createdAt)} "
              "and has a current status of ${transaction.status ?? 'Unknown'}.",
          style: const TextStyle(
            fontSize: 16,
            height: 1.6,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildEventInfo() {
    final ticket = transaction.ticketId!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Event: ${ticket.title}\n"
              "Location: ${ticket.location}\n"
              "Date: ${DateFormat('MMMM dd, yyyy').format(DateTime.parse(ticket.date))}\n"
              "Category: ${ticket.category}",
          style: const TextStyle(
            fontSize: 16,
            height: 1.6,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Amount Paid: \$${transaction.amount.toStringAsFixed(2)}\n"
              "Price Per Ticket: \$${(transaction.pricePerTicket ?? 0).toStringAsFixed(2)}\n"
              "Number of Tickets: ${transaction.ticketCount}\n"
              "Ticket Type: ${transaction.ticketTypeName ?? 'Standard'}\n"
              "Payment Method: Stripe",
          style: const TextStyle(
            fontSize: 16,
            height: 1.6,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildSystemInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "User ID: ${transaction.userId}\n"
              "Stripe Session: ${transaction.stripeSessionId ?? 'N/A'}\n"
              "Created: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(transaction.createdAt)}\n"
              "Last Updated: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(transaction.createdAt)}",
          style: const TextStyle(
            fontSize: 16,
            height: 1.6,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}

class WikiSection extends StatelessWidget {
  final String title;
  final Widget content;

  const WikiSection({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.grey, width: 1),
            ),
          ),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              fontFamily: 'Georgia',
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(height: 16),
        content,
      ],
    );
  }
}

class WikiTransactionInfoBox extends StatelessWidget {
  final Transaction transaction;
  final Function(String, String) onCopy;

  const WikiTransactionInfoBox({
    super.key,
    required this.transaction,
    required this.onCopy,
  });

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
      case 'refunded':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[50],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info box header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: const Text(
              "Transaction Summary",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),

          // Info content
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Transaction image or icon
                if (transaction.ticketId?.image.isNotEmpty ?? false)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        transaction.ticketId!.image,
                        width: double.infinity,
                        height: 120,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: double.infinity,
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.event,
                              size: 40,
                              color: Colors.grey,
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                // Key information
                _buildInfoRow("Status", transaction.paymentStatus.toUpperCase(),
                    color: _getStatusColor(transaction.paymentStatus)),
                const SizedBox(height: 8),
                _buildInfoRow("Amount", "\$${transaction.amount.toStringAsFixed(2)}"),
                const SizedBox(height: 8),
                _buildInfoRow("Tickets", "${transaction.ticketCount}"),
                const SizedBox(height: 8),
                _buildInfoRow("Date", DateFormat('MMM dd, yyyy').format(transaction.createdAt)),

                if (transaction.ticketId != null) ...[
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  Text(
                    "Event Details",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    transaction.ticketId!.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    transaction.ticketId!.location,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],

                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),

                // Action buttons
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => onCopy(transaction.transactionId, "Transaction ID"),
                      icon: const Icon(Icons.copy, size: 16),
                      label: const Text("Copy ID"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[50],
                        foregroundColor: Colors.blue[700],
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (transaction.stripeSessionId != null)
                      ElevatedButton.icon(
                        onPressed: () => onCopy(transaction.stripeSessionId!, "Stripe Session ID"),
                        icon: const Icon(Icons.payment, size: 16),
                        label: const Text("Copy Stripe ID"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple[50],
                          foregroundColor: Colors.purple[700],
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? color}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 60,
          child: Text(
            "$label:",
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color ?? Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}