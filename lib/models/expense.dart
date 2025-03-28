class Expense {
  final String id;
  final double amount;
  final String description;
  final DateTime date;
  final String categoryId;
  final String userId;
  final DateTime createdAt;

  Expense({
    required this.id,
    required this.amount,
    required this.description,
    required this.date,
    required this.categoryId,
    required this.userId,
    required this.createdAt,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'],
      amount: json['amount'].toDouble(),
      description: json['description'],
      date: DateTime.parse(json['date']),
      categoryId: json['category_id'],
      userId: json['user_id'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'description': description,
      'date': date.toIso8601String(),
      'category_id': categoryId,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
