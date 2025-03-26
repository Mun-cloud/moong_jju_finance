class Income {
  final String id;
  final double amount;
  final String source;
  final String description;
  final DateTime date;
  final String userId;
  final DateTime createdAt;

  Income({
    required this.id,
    required this.amount,
    required this.source,
    required this.description,
    required this.date,
    required this.userId,
    required this.createdAt,
  });

  factory Income.fromJson(Map<String, dynamic> json) {
    return Income(
      id: json['id'],
      amount: json['amount'].toDouble(),
      source: json['source'],
      description: json['description'],
      date: DateTime.parse(json['date']),
      userId: json['user_id'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'source': source,
      'description': description,
      'date': date.toIso8601String(),
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
