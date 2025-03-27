// lib/widgets/statistics/category_expense_chart.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../models/expense.dart';
import '../../models/category.dart';

class CategoryExpenseChart extends StatelessWidget {
  final List<Expense> expenses;
  final List<Category> categories;
  
  // 통화 포맷터
  final currencyFormatter = NumberFormat.currency(
    locale: 'ko_KR',
    symbol: '₩',
    decimalDigits: 0,
  );

  CategoryExpenseChart({
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
    
    // 상위 5개 카테고리만 표시 (나머지는 '기타'로 통합)
    final sortedCategories = categoryExpenses.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    final top5Categories = sortedCategories.take(5).toList();
    
    // 기타 카테고리 계산
    double otherCategoriesTotal = 0;
    if (sortedCategories.length > 5) {
      for (int i = 5; i < sortedCategories.length; i++) {
        otherCategoriesTotal += sortedCategories[i].value;
      }
    }
    
    // 파이 차트 데이터 생성
    final List<PieChartSectionData> pieChartData = [];
    
    for (var entry in top5Categories) {
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
      
      pieChartData.add(PieChartSectionData(
        color: categoryColor,
        value: entry.value,
        title: percentage >= 5 ? '${percentage.toStringAsFixed(1)}%' : '',
        radius: 100,
        titleStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ));
    }
    
    // 기타 카테고리 추가
    if (otherCategoriesTotal > 0) {
      final percentage = (otherCategoriesTotal / totalExpense) * 100;
      pieChartData.add(PieChartSectionData(
        color: Colors.grey,
        value: otherCategoriesTotal,
        title: percentage >= 5 ? '${percentage.toStringAsFixed(1)}%' : '',
        radius: 100,
        titleStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ));
    }
    
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
            if (totalExpense == 0)
              Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(
                    '이 기간에 지출 내역이 없습니다',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 40,
                          sections: pieChartData,
                          pieTouchData: PieTouchData(
                            touchCallback: (FlTouchEvent event, pieTouchResponse) {
                              // 터치 이벤트 처리 (필요시)
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: _buildCategoryLegend(top5Categories, categories, otherCategoriesTotal),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  // 카테고리별 범례 위젯
  Widget _buildCategoryLegend(
    List<MapEntry<String, double>> topCategories,
    List<Category> categories,
    double otherCategoriesTotal,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 상위 카테고리 범례
        ...topCategories.map((entry) {
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
          
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: categoryColor,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    category.name,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
        
        // 기타 카테고리 범례
        if (otherCategoriesTotal > 0)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 8),
                Text('기타'),
              ],
            ),
          ),
      ],
    );
  }
}