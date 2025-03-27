// lib/widgets/statistics/budget_status_tab.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/expense.dart';
import '../../models/category.dart';
import 'period_selector.dart';

class BudgetStatusTab extends StatelessWidget {
  final List<Expense> expenses;
  final List<Category> categories;
  final String periodType;
  final DateTime selectedDate;
  final VoidCallback onPrevPeriod;
  final VoidCallback onNextPeriod;
  final VoidCallback onSelectPeriod;
  
  // 통화 포맷터
  final currencyFormatter = NumberFormat.currency(
    locale: 'ko_KR',
    symbol: '₩',
    decimalDigits: 0,
  );

  BudgetStatusTab({
    Key? key,
    required this.expenses,
    required this.categories,
    required this.periodType,
    required this.selectedDate,
    required this.onPrevPeriod,
    required this.onNextPeriod,
    required this.onSelectPeriod,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 카테고리별 지출 합계 계산
    final Map<String, double> categoryExpenses = {};
    
    for (var expense in expenses) {
      categoryExpenses[expense.categoryId] = (categoryExpenses[expense.categoryId] ?? 0) + expense.amount;
    }
    
    // 예산 데이터 (실제로는 예산 데이터를 불러와야 함)
    // 이 예제에서는 임의의 예산 데이터를 생성
    final Map<String, double> categoryBudgets = {};
    for (var category in categories) {
      // 임의의 예산 금액 설정 (실제 앱에서는 데이터베이스에서 불러와야 함)
      categoryBudgets[category.id] = (categoryExpenses[category.id] ?? 0) * (1 + (0.2 + (category.id.hashCode % 5) / 10));
    }
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 기간 선택기
          PeriodSelector(
            periodType: periodType,
            selectedDate: selectedDate,
            onPrevPeriod: onPrevPeriod,
            onNextPeriod: onNextPeriod,
            onSelectPeriod: onSelectPeriod,
          ),
          SizedBox(height: 20),
          
          // 예산 현황 요약
          _buildBudgetStatusSummary(categoryExpenses, categoryBudgets),
        ],
      ),
    );
  }

  // 예산 현황 요약 위젯
  Widget _buildBudgetStatusSummary(
    Map<String, double> categoryExpenses,
    Map<String, double> categoryBudgets,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '예산 현황',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Text(
              periodType == '월간'
                  ? DateFormat('yyyy년 MM월').format(selectedDate)
                  : '${selectedDate.year}년',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 16),
            if (categories.isEmpty)
              Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    '카테고리가 없습니다',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final spent = categoryExpenses[category.id] ?? 0;
                  final budget = categoryBudgets[category.id] ?? 0;
                  final percentage = budget > 0 ? (spent / budget) * 100 : 0;
                  final categoryColor = Color(int.parse(category.color.replaceFirst('#', '0xFF')));
                  
                  return Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: categoryColor,
                                  radius: 12,
                                  child: Icon(
                                    IconData(
                                      int.parse('0xe${category.icon}', radix: 16),
                                      fontFamily: 'MaterialIcons',
                                    ),
                                    color: Colors.white,
                                    size: 12,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  category.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '${percentage.toStringAsFixed(1)}%',
                              style: TextStyle(
                                color: percentage > 100 ? Colors.red : Colors.grey[600],
                                fontWeight: percentage > 100 ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: percentage / 100 > 1 ? 1 : percentage / 100,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            percentage > 100 ? Colors.red : categoryColor,
                          ),
                        ),
                        SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              currencyFormatter.format(spent),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              currencyFormatter.format(budget),
                              style: TextStyle(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
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