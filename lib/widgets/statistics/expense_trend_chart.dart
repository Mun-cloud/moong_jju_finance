// lib/widgets/statistics/expense_trend_chart.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../models/expense.dart';

class ExpenseTrendChart extends StatelessWidget {
  final List<Expense> expenses;
  final String periodType;
  final DateTime selectedDate;

  // 통화 포맷터
  final currencyFormatter = NumberFormat.currency(
    locale: 'ko_KR',
    symbol: '₩',
    decimalDigits: 0,
  );

  ExpenseTrendChart({
    Key? key,
    required this.expenses,
    required this.periodType,
    required this.selectedDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (periodType == '월간') {
      return _buildDailyExpenseChart();
    } else {
      return _buildMonthlyExpenseChart();
    }
  }

  // 일별 지출 차트 (월간 통계용)
  Widget _buildDailyExpenseChart() {
    // 일별 데이터 준비
    final Map<int, double> dailyExpenses = {};

    // 이번 달의 일수
    final daysInMonth =
        DateTime(selectedDate.year, selectedDate.month + 1, 0).day;

    // 초기화
    for (int i = 1; i <= daysInMonth; i++) {
      dailyExpenses[i] = 0;
    }

    // 일별 지출 합계
    for (var expense in expenses) {
      final day = expense.date.day;
      dailyExpenses[day] = (dailyExpenses[day] ?? 0) + expense.amount;
    }

    // 차트에 표시할 일수 (화면 공간 제약으로 일부만 표시)
    final displayDays = daysInMonth;
    const startDay = 1;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '일별 지출 추이',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 22,
                        getTitlesWidget: (value, meta) {
                          final day = value.toInt();
                          return day % 5 == 0 || day == 1 || day == daysInMonth
                              ? Text(
                                  '$day일',
                                  style: const TextStyle(
                                    color: Color(0xff68737d),
                                    fontSize: 12,
                                  ),
                                )
                              : const SizedBox.shrink();
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          if (value == 0) return const Text('0');
                          if (value >= 10000) {
                            return Text(
                              '${(value / 10000).toStringAsFixed(0)}만',
                              style: const TextStyle(
                                color: Color(0xff68737d),
                                fontSize: 12,
                              ),
                            );
                          }
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(
                              color: Color(0xff68737d),
                              fontSize: 12,
                            ),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border:
                        Border.all(color: const Color(0xff37434d), width: 1),
                  ),
                  minX: startDay.toDouble(),
                  maxX: daysInMonth.toDouble(),
                  minY: 0,
                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        for (int i = startDay; i <= daysInMonth; i++)
                          FlSpot(i.toDouble(), dailyExpenses[i] ?? 0),
                      ],
                      isCurved: true,
                      color: Colors.red,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.red.withOpacity(0.2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 월별 지출 차트 (연간 통계용)
  Widget _buildMonthlyExpenseChart() {
    // 월별 데이터 준비
    final Map<int, double> monthlyExpenses = {};

    // 초기화
    for (int i = 1; i <= 12; i++) {
      monthlyExpenses[i] = 0;
    }

    // 월별 지출 합계
    for (var expense in expenses) {
      final month = expense.date.month;
      monthlyExpenses[month] = (monthlyExpenses[month] ?? 0) + expense.amount;
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '월별 지출 추이',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: monthlyExpenses.values.isEmpty
                      ? 10000
                      : monthlyExpenses.values.reduce((a, b) => a > b ? a : b) *
                          1.2,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      tooltipBgColor: Colors.blueAccent,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        int month = group.x.toInt();
                        return BarTooltipItem(
                          '$month월\n',
                          const TextStyle(color: Colors.white),
                          children: <TextSpan>[
                            TextSpan(
                              text: currencyFormatter
                                  .format(monthlyExpenses[month] ?? 0),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          int month = value.toInt();
                          return Text(
                            '$month월',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          if (value == 0) return const Text('0');
                          if (value >= 10000) {
                            return Text(
                              '${(value / 10000).toStringAsFixed(0)}만',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 10,
                              ),
                            );
                          }
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 10,
                            ),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    checkToShowHorizontalLine: (value) => value % 5 == 0,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey.withOpacity(0.3),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(
                    12,
                    (index) => BarChartGroupData(
                      x: index + 1,
                      barRods: [
                        BarChartRodData(
                          toY: monthlyExpenses[index + 1] ?? 0,
                          color: Colors.red,
                          width: 22,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(6),
                            topRight: Radius.circular(6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
