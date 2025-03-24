class Expense {
  final String id;
  final double amount;
  final String description;
  final DateTime date;
  final String categoryId;
  final String userId;
  final String? categoryName;
  final String? categoryIcon;
  final String? categoryColor;

  Expense({
    required this.id,
    required this.amount,
    required this.description,
    required this.date,
    required this.categoryId,
    required this.userId,
    this.categoryName,
    this.categoryIcon,
    this.categoryColor,
  });

  factory Expense.fromJson(Map<String, dynamic> json,
      {Map<String, dynamic>? category}) {
    return Expense(
      id: json['id'],
      amount: json['amount'].toDouble(),
      description: json['description'] ?? '',
      date: DateTime.parse(json['date']),
      categoryId: json['category_id'] ?? '',
      userId: json['user_id'],
      categoryName: category?['name'],
      categoryIcon: category?['icon'],
      categoryColor: category?['color'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'description': description,
      'date': date.toIso8601String(),
      'category_id': categoryId,
      'user_id': userId,
    };
  }
}
