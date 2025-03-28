// lib/widgets/expense_filter.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:moong_jju_finance/providers/category_provider.dart';

class ExpenseFilterWidget extends ConsumerStatefulWidget {
  final DateTime startDate;
  final DateTime endDate;
  final String? selectedCategoryId;
  final Function(DateTime, DateTime, String?) onFilterChanged;

  const ExpenseFilterWidget({
    Key? key,
    required this.startDate,
    required this.endDate,
    this.selectedCategoryId,
    required this.onFilterChanged,
  }) : super(key: key);

  @override
  ConsumerState<ExpenseFilterWidget> createState() =>
      _ExpenseFilterWidgetState();
}

class _ExpenseFilterWidgetState extends ConsumerState<ExpenseFilterWidget> {
  late DateTime _startDate;
  late DateTime _endDate;
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _startDate = widget.startDate;
    _endDate = widget.endDate;
    _selectedCategoryId = widget.selectedCategoryId;
  }

  @override
  Widget build(BuildContext context) {
    final categoriesState = ref.watch(categoryNotifierProvider);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const Text(
            '지출 필터',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            '기간 선택',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          _buildDateRangeSelector(context),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          const Text(
            '카테고리 선택',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          _buildCategorySelector(categoriesState),
          const SizedBox(height: 24),
          _buildActionButtons(context),
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ],
      ),
    );
  }

  Widget _buildDateRangeSelector(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () => _selectStartDate(context),
            child: InputDecorator(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                labelText: '시작일',
              ),
              child: Text(DateFormat('yyyy-MM-dd').format(_startDate)),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: InkWell(
            onTap: () => _selectEndDate(context),
            child: InputDecorator(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                labelText: '종료일',
              ),
              child: Text(DateFormat('yyyy-MM-dd').format(_endDate)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySelector(AsyncValue<List<dynamic>> categoriesState) {
    return categoriesState.when(
      data: (categories) {
        return SizedBox(
          height: 120,
          child: SingleChildScrollView(
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                // '전체' 옵션
                FilterChip(
                  label: const Text('전체'),
                  selected: _selectedCategoryId == null,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedCategoryId = null;
                      });
                    }
                  },
                  backgroundColor: Colors.grey[200],
                  selectedColor: Colors.blue,
                  labelStyle: TextStyle(
                    color: _selectedCategoryId == null
                        ? Colors.white
                        : Colors.black,
                  ),
                ),

                // 각 카테고리 옵션
                ...categories.map((category) {
                  final categoryColor = Color(
                      int.parse(category.color.replaceFirst('#', '0xFF')));
                  return FilterChip(
                    label: Text(category.name),
                    selected: _selectedCategoryId == category.id,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategoryId = selected ? category.id : null;
                      });
                    },
                    backgroundColor: Colors.grey[200],
                    selectedColor: categoryColor,
                    labelStyle: TextStyle(
                      color: _selectedCategoryId == category.id
                          ? Colors.white
                          : Colors.black,
                    ),
                    avatar: CircleAvatar(
                      backgroundColor: categoryColor.withOpacity(0.8),
                      child: Icon(
                        IconData(
                          int.parse('0xe${category.icon}', radix: 16),
                          fontFamily: 'MaterialIcons',
                        ),
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => const Text('카테고리를 불러오는 중 오류가 발생했습니다.'),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () {
            // 기본 설정으로 초기화
            setState(() {
              _startDate = DateTime.now().subtract(const Duration(days: 30));
              _endDate = DateTime.now();
              _selectedCategoryId = null;
            });
          },
          child: const Text('초기화'),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: () {
            widget.onFilterChanged(_startDate, _endDate, _selectedCategoryId);
          },
          child: const Text('적용하기'),
        ),
      ],
    );
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: _endDate,
    );

    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: _startDate,
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );

    if (picked != null && picked != _endDate) {
      setState(() {
        _endDate = picked;
      });
    }
  }
}
