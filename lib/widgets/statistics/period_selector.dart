// lib/widgets/statistics/period_selector.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PeriodSelector extends StatelessWidget {
  final String periodType;
  final DateTime selectedDate;
  final VoidCallback onPrevPeriod;
  final VoidCallback onNextPeriod;
  final VoidCallback onSelectPeriod;

  const PeriodSelector({
    Key? key,
    required this.periodType,
    required this.selectedDate,
    required this.onPrevPeriod,
    required this.onNextPeriod,
    required this.onSelectPeriod,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back_ios),
              onPressed: onPrevPeriod,
            ),
            GestureDetector(
              onTap: onSelectPeriod,
              child: Text(
                periodType == '월간'
                    ? DateFormat('yyyy년 MM월').format(selectedDate)
                    : '${selectedDate.year}년',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.arrow_forward_ios),
              onPressed: onNextPeriod,
            ),
          ],
        ),
      ),
    );
  }
}