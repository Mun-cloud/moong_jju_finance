// lib/widgets/statistics/income_analysis_tab.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../models/income.dart';
import 'period_selector.dart';
import 'income_source_chart.dart';
import 'income_source_list.dart';

class IncomeAnalysisTab extends StatelessWidget {
  final List<Income> incomes;
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

  IncomeAnalysisTab({
    Key? key,
    required this.incomes,
    required this.periodType,
    required this.selectedDate,
    required this.onPrevPeriod,
    required this.onNextPeriod,
    required this.onSelectPeriod,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 수입원별 금액 계산
    final Map<String, double> sourceIncomes = {};
    double totalIncome = 0;
    
    for (var income in incomes) {
      sourceIncomes[income.source] = (sourceIncomes[income.source] ?? 0) + income.amount;
      totalIncome += income.amount;
    }
    
    // 수입원별로 정렬
    final sortedSources = sourceIncomes.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
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
          
          // 총 수입 요약
          _buildTotalIncomeSummary(totalIncome),
          SizedBox(height: 20),
          
          // 수입원별 차트
          IncomeSourceChart(
            sortedSources: sortedSources,
            totalIncome: totalIncome,
          ),
          SizedBox(height: 20),
          
          // 수입원별 목록
          IncomeSourceList(
            sortedSources: sortedSources,
            totalIncome: totalIncome,
          ),
        ],
      ),
    );
  }

  // 총 수입 요약 위젯
  Widget _buildTotalIncomeSummary(double totalIncome) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '총 수입',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8),
            Text(
              currencyFormatter.format(totalIncome),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
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