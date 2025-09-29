class WalletAccount {
  final String id;
  final String userId;
  final String account;
  final String accountName;
  final String bankName;
  final String accountLabel;
  final DateTime createdAt;

  WalletAccount({
    required this.id,
    required this.userId,
    required this.account,
    required this.accountName,
    required this.bankName,
    required this.accountLabel,
    required this.createdAt,
  });

  factory WalletAccount.fromJson(Map<String, dynamic> json) {
    return WalletAccount(
      id: json['id'],
      userId: json['userId'],
      account: json['account'],
      accountName: json['accountName'],
      bankName: json['bankName'],
      accountLabel: json['accountLabel'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
