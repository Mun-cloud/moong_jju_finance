// lib/widgets/statistics/category_expense_list.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/expense.dart';
import '../../models/category.dart';

class CategoryExpenseList extends StatelessWidget {
  final List<Expense> expenses;
  final List<Category> categories;
  
  // 통화 포맷터
  final currencyFormatter = NumberFormat.currency(
    locale: 'ko_KR',
    symbol: '₩',
    decimalDigits: 0,
  );

  CategoryExpenseList({
    Key? key,
    required this.expenses,
    required this.categories,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 카테고리별 지출 합계 계산
    final Map<String, double> categoryExpenses = {};
    double totalExpense = 0;
    
    for (var expense in expenses) {
      categoryExpenses[expense.categoryId] = (categoryExpenses[expense.categoryId] ?? 0) + expense.amount;
      totalExpense += expense.amount;
    }
    
    // 카테고리별로 정렬
    final sortedCategories = categoryExpenses.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '카테고리별 지출',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            if (sortedCategories.isEmpty)
              Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    '이 기간에 지출 내역이 없습니다',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: sortedCategories.length,
                itemBuilder: (context, index) {
                  final entry = sortedCategories[index];
                  final category = categories.firstWhere(
                    (c) => c.id == entry.key,
                    orElse: () => Category(
                      id: 'unknown',
                      name: '기타',
                      icon: 'more_horiz',
                      color: '#757575',
                      userId: 'default',
                      createdAt: DateTime.now(),
                    ),
                  );
                  
                  final categoryColor = Color(int.parse(category.color.replaceFirst('#', '0xFF')));
                  final percentage = totalExpense > 0 ? (entry.value / totalExpense) * 100 : 0;
                  
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: categoryColor,
                      child: Icon(
                        IconData(
                          int.parse('0xe${category.icon}', radix: 16),
                          fontFamily: 'MaterialIcons',
                        ),
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    title: Text(category.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: percentage / 100,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(categoryColor),
                        ),
                        SizedBox(height: 4),
                        Text('${percentage.toStringAsFixed(1)}%'),
                      ],
                    ),
                    trailing: Text(
                      currencyFormatter.format(entry.value),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red[700],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}