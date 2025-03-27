// lib/widgets/statistics/income_source_chart.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class IncomeSourceChart extends StatelessWidget {
  final List<MapEntry<String, double>> sortedSources;
  final double totalIncome;
  
  // 통화 포맷터
  final currencyFormatter = NumberFormat.currency(
    locale: 'ko_KR',
    symbol: '₩',
    decimalDigits: 0,
  );

  IncomeSourceChart({
    Key? key,
    required this.sortedSources,
    required this.totalIncome,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '수입원별 금액',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            if (totalIncome == 0)
              Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(
                    '이 기간에 수입 내역이 없습니다',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              Container(
                height: 200,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: sortedSources.isEmpty ? 0 : sortedSources.first.value * 1.2,
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        tooltipBgColor: Colors.blueAccent,
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          return BarTooltipItem(
                            '${sortedSources[groupIndex].key}\n',
                            TextStyle(color: Colors.white),
                            children: <TextSpan>[
                              TextSpan(
                                text: currencyFormatter.format(sortedSources[groupIndex].value),
                                style: TextStyle(
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
                      bottomTitles: SideTitles(
                        showTitles: true,
                        getTextStyles: (context, value) => TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                        ),
                        margin: 10,
                        getTitles: (double value) {
                          int index = value.toInt();
                          if (index >= 0 && index < sortedSources.length) {
                            String source = sortedSources[index].key;
                            // 긴 이름은 줄임
                            if (source.length > 5) {
                              return source.substring(0, 5) + '...';
                            }
                            return source;
                          }
                          return '';
                        },
                      ),
                      leftTitles: SideTitles(
                        showTitles: true,
                        getTextStyles: (context, value) => TextStyle(
                          color: Colors.black,
                          fontSize: 10,
                        ),
                        margin: 10,
                        reservedSize: 30,
                        getTitles: (value) {
                          if (value == 0) return '0';
                          // 단위 간소화 (예: 100000 -> 10만)
                          if (value >= 10000) {
                            return '${(value / 10000).toStringAsFixed(0)}만';
                          }
                          return value.toInt().toString();
                        },
                      ),
                      topTitles: SideTitles(showTitles: false),
                      rightTitles: SideTitles(showTitles: false),
                    ),
                    gridData: FlGridData(
                      show: true,
                      checkToShowHorizontalLine: (value) => value % (sortedSources.isEmpty ? 1 : sortedSources.first.value / 5) == 0,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: Colors.grey.withOpacity(0.3),
                          strokeWidth: 1,
                        );
                      },
                    ),
                    borderData: FlBorderData(
                      show: false,
                    ),
                    barGroups: List.generate(
                      sortedSources.length,
                      (index) => BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            y: sortedSources[index].value,
                            colors: [Colors.green],
                            width: 22,
                            borderRadius: BorderRadius.only(
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