// lib/widgets/settings/data_section.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class DataSection extends ConsumerWidget {
  const DataSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '데이터 관리',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            ListTile(
              title: Text('데이터 내보내기'),
              subtitle: Text('지출 및 수입 데이터를 CSV 파일로 내보내기'),
              trailing: Icon(Icons.arrow_forward_ios),
              leading: Icon(Icons.upload_file),
              onTap: () {
                // 데이터 내보내기 다이얼로그 표시
                _showExportDialog(context);
              },
            ),
            Divider(),
            ListTile(
              title: Text('데이터 가져오기'),
              subtitle: Text('CSV 파일에서 데이터 가져오기'),
              trailing: Icon(Icons.arrow_forward_ios),
              leading: Icon(Icons.download_rounded),
              onTap: () {
                // 데이터 가져오기 화면으로 이동
                _showImportDialog(context);
              },
            ),
            Divider(),
            ListTile(
              title: Text('데이터 백업'),
              subtitle: Text('모든 데이터를 클라우드에 백업'),
              trailing: Icon(Icons.arrow_forward_ios),
              leading: Icon(Icons.cloud_upload),
              onTap: () {
                // 데이터 백업 실행
                _showBackupDialog(context);
              },
            ),
            Divider(),
            ListTile(
              title: Text('데이터 복원'),
              subtitle: Text('클라우드에서 백업 데이터 복원'),
              trailing: Icon(Icons.arrow_forward_ios),
              leading: Icon(Icons.cloud_download),
              onTap: () {
                // 데이터 복원 실행
                _showRestoreDialog(context);
              },
            ),
            Divider(),
            ListTile(
              title: Text('데이터 초기화'),
              subtitle: Text('모든 지출 및 수입 데이터 삭제'),
              trailing: Icon(Icons.delete_forever),
              leading: Icon(Icons.warning_amber_rounded),
              onTap: () {
                // 데이터 초기화 확인 다이얼로그 표시
                _showResetDialog(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  // 데이터 내보내기 다이얼로그
  void _showExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('데이터 내보내기'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('내보낼 데이터 기간을 선택하세요:'),
            SizedBox(height: 16),
            ListTile(
              title: Text('전체 기간'),
              leading: Radio<String>(
                value: 'all',
                groupValue: 'all',
                onChanged: (value) {},
              ),
            ),
            ListTile(
              title: Text('특정 기간'),
              leading: Radio<String>(
                value: 'period',
                groupValue: 'all',
                onChanged: (value) {},
              ),
            ),
            SizedBox(height: 16),
            Text('내보낼 데이터 유형:'),
            SizedBox(height: 8),
            CheckboxListTile(
              title: Text('지출'),
              value: true,
              onChanged: (value) {},
            ),
            CheckboxListTile(
              title: Text('수입'),
              value: true,
              onChanged: (value) {},
            ),
            CheckboxListTile(
              title: Text('예산'),
              value: true,
              onChanged: (value) {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              // 데이터 내보내기 기능 실행
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('데이터가 성공적으로 내보내졌습니다')),
              );
            },
            child: Text('내보내기'),
          ),
        ],
      ),
    );
  }

  // 데이터 가져오기 다이얼로그
  void _showImportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('데이터 가져오기'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('CSV 파일을 선택하세요:'),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // 파일 선택 기능
              },
              child: Text('파일 선택'),
            ),
            SizedBox(height: 16),
            Text('가져올 데이터 유형:'),
            SizedBox(height: 8),
            CheckboxListTile(
              title: Text('지출'),
              value: true,
              onChanged: (value) {},
            ),
            CheckboxListTile(
              title: Text('수입'),
              value: true,
              onChanged: (value) {},
            ),
            CheckboxListTile(
              title: Text('예산'),
              value: true,
              onChanged: (value) {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              // 데이터 가져오기 기능 실행
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('데이터가 성공적으로 가져와졌습니다')),
              );
            },
            child: Text('가져오기'),
          ),
        ],
      ),
    );
  }

  // 데이터 백업 다이얼로그
  void _showBackupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('데이터 백업'),
        content: Text('모든 데이터를 클라우드에 백업하시겠습니까? 기존 백업은 덮어씌워집니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              // 데이터 백업 기능 실행
              Navigator.pop(context);
              
              // 백업 진행 중 다이얼로그 표시
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return AlertDialog(
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('백업 중...'),
                      ],
                    ),
                  );
                },
              );
              
              // 백업 완료 후 다이얼로그 닫기 (실제로는 백업 완료 후 호출)
              Future.delayed(Duration(seconds: 2), () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('데이터가 성공적으로 백업되었습니다')),
                );
              });
            },
            child: Text('백업'),
          ),
        ],
      ),
    );
  }

  // 데이터 복원 다이얼로그
  void _showRestoreDialog(BuildContext context) {
    // 백업 목록 (실제로는 서버에서 가져옴)
    final backups = [
      {
        'date': DateTime.now().subtract(Duration(days: 1)),
        'size': '2.3 MB',
      },
      {
        'date': DateTime.now().subtract(Duration(days: 7)),
        'size': '2.1 MB',
      },
      {
        'date': DateTime.now().subtract(Duration(days: 30)),
        'size': '1.8 MB',
      },
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('데이터 복원'),
        content: Container(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('복원할 백업을 선택하세요:'),
              SizedBox(height: 8),
              Container(
                height: 200,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: backups.length,
                  itemBuilder: (context, index) {
                    final backup = backups[index];
                    return ListTile(
                      title: Text(DateFormat('yyyy년 MM월 dd일 HH:mm').format(backup['date'] as DateTime)),
                      subtitle: Text('크기: ${backup['size']}'),
                      trailing: Radio<int>(
                        value: index,
                        groupValue: 0,
                        onChanged: (value) {},
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 8),
              Text(
                '주의: 복원 시 현재 데이터가 백업 데이터로 대체됩니다.',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              // 데이터 복원 기능 실행
              Navigator.pop(context);
              
              // 복원 진행 중 다이얼로그 표시
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return AlertDialog(
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('복원 중...'),
                      ],
                    ),
                  );
                },
              );
              
              // 복원 완료 후 다이얼로그 닫기 (실제로는 복원 완료 후 호출)
              Future.delayed(Duration(seconds: 2), () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('데이터가 성공적으로 복원되었습니다')),
                );
              });
            },
            child: Text('복원'),
          ),
        ],
      ),
    );
  }

  // 데이터 초기화 다이얼로그
  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('데이터 초기화'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '주의: 이 작업은 되돌릴 수 없습니다!',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Text('초기화할 데이터 유형을 선택하세요:'),
            SizedBox(height: 8),
            CheckboxListTile(
              title: Text('지출'),
              value: true,
              onChanged: (value) {},
            ),
            CheckboxListTile(
              title: Text('수입'),
              value: true,
              onChanged: (value) {},
            ),
            CheckboxListTile(
              title: Text('예산'),
              value: true,
              onChanged: (value) {},
            ),
            CheckboxListTile(
              title: Text('카테고리'),
              value: false,
              onChanged: (value) {},
            ),
            SizedBox(height: 16),
            Text('초기화를 확인하려면 "초기화"를 입력하세요:'),
            SizedBox(height: 8),
            TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: '초기화',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('취소'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () {
              // 데이터 초기화 기능 실행
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('선택한 데이터가 초기화되었습니다')),
              );
            },
            child: Text('초기화'),
          ),
        ],
      ),
    );
  }
}