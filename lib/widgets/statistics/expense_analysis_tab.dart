// lib/widgets/statistics/expense_analysis_tab.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../models/expense.dart';
import '../../models/category.dart';
import 'period_selector.dart';
import 'category_expense_chart.dart';
import 'category_expense_list.dart';
import 'expense_trend_chart.dart';

class ExpenseAnalysisTab extends StatelessWidget {
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

  ExpenseAnalysisTab({
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
          
          // 총 지출 요약
          _buildTotalExpenseSummary(),
          SizedBox(height: 20),
          
          // 카테고리별 지출 차트
          CategoryExpenseChart(
            expenses: expenses,
            categories: categories,
          ),
          SizedBox(height: 20),
          
          // 카테고리별 지출 목록
          CategoryExpenseList(
            expenses: expenses,
            categories: categories,
          ),
          SizedBox(height: 20),
          
          // 월별 또는 일별 지출 추이
          ExpenseTrendChart(
            expenses: expenses,
            periodType: periodType,
            selectedDate: selectedDate,
          ),
        ],
      ),
    );
  }

  // 총 지출 요약 위젯
  Widget _buildTotalExpenseSummary() {
    final totalExpense = expenses.fold<double>(0, (sum, expense) => sum + expense.amount);
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '총 지출',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8),
            Text(
              currencyFormatter.format(totalExpense),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            SizedBox(height: 8),
            Text(
              periodType == '월간'
                  ? DateFormat('yyyy년 MM월').format(selectedDate)
                  : '${selectedDate.year}년',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}