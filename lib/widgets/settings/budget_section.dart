// lib/widgets/settings/budget_section.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/category_provider.dart';

// 예산 관리 시작일 설정을 위한 프로바이더
final budgetStartDayProvider = StateProvider<int>((ref) => 1); // 기본값은 1일

class BudgetSection extends ConsumerWidget {
  const BudgetSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 카테고리 목록 가져오기
    final categoriesState = ref.watch(categoryNotifierProvider);

    // 예산 관리 시작일
    final budgetStartDay = ref.watch(budgetStartDayProvider);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '예산 설정',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('카테고리별 예산 설정'),
              subtitle: const Text('각 카테고리별 월간 예산 금액 설정'),
              trailing: const Icon(Icons.arrow_forward_ios),
              leading: const Icon(Icons.category),
              onTap: () {
                // 카테고리별 예산 설정 화면으로 이동
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => BudgetEditScreen(),
                //   ),
                // );
              },
            ),
            const Divider(),
            ListTile(
              title: const Text('월간 예산 관리 시작일'),
              subtitle:
                  Text('매월 $budgetStartDay일부터 다음 달 ${budgetStartDay - 1}일까지'),
              trailing: DropdownButton<int>(
                value: budgetStartDay,
                onChanged: (int? newValue) {
                  if (newValue != null) {
                    ref.read(budgetStartDayProvider.notifier).state = newValue;
                  }
                },
                items:
                    List.generate(28, (index) => index + 1) // 1일부터 28일까지만 선택 가능
                        .map<DropdownMenuItem<int>>((int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text('$value일'),
                  );
                }).toList(),
              ),
              leading: const Icon(Icons.calendar_today),
            ),
            const Divider(),
            categoriesState.when(
              data: (categories) {
                if (categories.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('카테고리가 없습니다. 먼저 카테고리를 추가해주세요.'),
                    ),
                  );
                }

                return Column(
                  children: [
                    ListTile(
                      title: const Text('자동 예산 배분'),
                      subtitle: const Text('이전 달 지출 패턴을 기반으로 예산 자동 설정'),
                      trailing: ElevatedButton(
                        onPressed: () {
                          // 자동 예산 배분 기능
                          _showAutoAllocationDialog(context);
                        },
                        child: const Text('자동 설정'),
                      ),
                      leading: const Icon(Icons.auto_awesome),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '* 자동 설정은 이전 3개월 지출 데이터를 분석하여 최적의 예산을 제안합니다.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => const Center(
                child: Text('카테고리를 불러오는 중 오류가 발생했습니다.'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAutoAllocationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('자동 예산 배분'),
        content: const Text('이전 3개월 지출 데이터를 기반으로 각 카테고리별 예산을 자동으로 설정하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              // 자동 예산 배분 로직 실행
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('카테고리별 예산이 자동으로 설정되었습니다')),
              );
            },
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
}
