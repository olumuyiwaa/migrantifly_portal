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
    final transaction = widget.transaction;

    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.blue))
          : Column(
        children: [
          WikiTransactionHeader(transaction: transaction),
          Expanded(
            child: SingleChildScrollView(
              child: WikiTransactionContent(
                transaction: transaction,
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
            Row(
              children: [
                Expanded(
                  child: Text(
                    "Transaction Details",
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Georgia',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
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
          // Left side
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                WikiSection(
                  title: "Transaction Overview",
                  content: _buildTransactionOverview(),
                ),
                const SizedBox(height: 24),

                WikiSection(
                  title: "Client Information",
                  content: _buildClientInfo(),
                ),
                const SizedBox(height: 24),

                WikiSection(
                  title: "Payment Details",
                  content: _buildPaymentDetails(),
                ),
                const SizedBox(height: 24),

                WikiSection(
                  title: "System Information",
                  content: _buildSystemInfo(),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          // Right side
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
    return Text(
      "This transaction of ${transaction.currency} ${transaction.amount.toStringAsFixed(2)} "
          "was made by ${transaction.clientFullName} "
          "on ${DateFormat('MMMM dd, yyyy \'at\' HH:mm').format(transaction.createdAt)} "
          "using ${transaction.paymentMethod}. Current status: ${transaction.status}.",
      style: const TextStyle(fontSize: 16, height: 1.6, color: Colors.black87),
    );
  }

  Widget _buildClientInfo() {
    final client = transaction.client;
    return Text(
      "Name: ${client.profile?.fullName ?? client.email}\n"
          "Email: ${client.email}\n"
          "Phone: ${client.profile?.phoneNumber ?? 'N/A'}\n"
          "Address: ${client.profile?.fullAddress ?? ''}\n"
          "Nationality: ${client.profile?.countryLocated ?? 'N/A'}",
      style: const TextStyle(fontSize: 16, height: 1.6, color: Colors.black87),
    );
  }

  Widget _buildPaymentDetails() {
    return Text(
      "Amount: ${transaction.currency} ${transaction.amount.toStringAsFixed(2)}\n"
          "Payment Method: ${transaction.paymentMethod}\n"
          "Invoice Number: ${transaction.invoiceNumber}\n"
          "Invoice: ${transaction.invoiceUrl}",
      style: const TextStyle(fontSize: 16, height: 1.6, color: Colors.black87),
    );
  }

  Widget _buildSystemInfo() {
    return Text(
      "Gateway Reference: ${transaction.gatewayReference}\n"
          "Visa Type: ${transaction.application?.visaType ?? 'N/A'}\n"
          "Created At: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(transaction.createdAt)}\n"
          "Updated At: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(transaction.updatedAt)}",
      style: const TextStyle(fontSize: 16, height: 1.6, color: Colors.black87),
    );
  }
}

class WikiSection extends StatelessWidget {
  final String title;
  final Widget content;

  const WikiSection({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey, width: 1)),
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
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
        return Colors.red;
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
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Transaction Summary",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const Divider(),
            _buildInfoRow("Status", transaction.status.toUpperCase(),
                color: _getStatusColor(transaction.status)),
            const SizedBox(height: 8),
            _buildInfoRow(
                "Amount", "${transaction.currency} ${transaction.amount}"),
            const SizedBox(height: 8),
            _buildInfoRow("Method", transaction.paymentMethod),
            const SizedBox(height: 8),
            _buildInfoRow("Date",
                DateFormat('MMM dd, yyyy').format(transaction.createdAt)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () =>
                  onCopy(transaction.transactionId, "Transaction ID"),
              icon: const Icon(Icons.copy, size: 16),
              label: const Text("Copy Transaction ID"),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () async {
                final url = Uri.parse(transaction.invoiceUrl);
                if (await canLaunchUrl(url)) {
                  await launchUrl(url);
                }
              },
              icon: const Icon(Icons.picture_as_pdf, size: 16),
              label: const Text("Open Invoice"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? color}) {
    return Row(
      children: [
        SizedBox(
          width: 70,
          child: Text(
            "$label:",
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w500, color: color),
          ),
        ),
      ],
    );
  }
}
