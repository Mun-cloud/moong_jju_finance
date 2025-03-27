// lib/widgets/statistics/income_source_list.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class IncomeSourceList extends StatelessWidget {
  final List<MapEntry<String, double>> sortedSources;
  final double totalIncome;
  
  // 통화 포맷터
  final currencyFormatter = NumberFormat.currency(
    locale: 'ko_KR',
    symbol: '₩',
    decimalDigits: 0,
  );

  IncomeSourceList({
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
            SizedBox(height: 8),
            if (sortedSources.isEmpty)
              Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    '이 기간에 수입 내역이 없습니다',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: sortedSources.length,
                itemBuilder: (context, index) {
                  final source = sortedSources[index];
                  final percentage = (source.value / totalIncome) * 100;
                  
                  return ListTile(
                    title: Text(source.key),
                    trailing: Text(
                      currencyFormatter.format(source.value),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: source.value / totalIncome,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                        ),
                        SizedBox(height: 4),
                        Text('${percentage.toStringAsFixed(1)}%'),
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