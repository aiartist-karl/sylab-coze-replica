import 'package:flutter/material.dart';
import '../theme/coze_colors.dart';
import '../theme/coze_theme.dart';

class CreditsDetailPage extends StatelessWidget {
  const CreditsDetailPage({super.key});

  static const List<Map<String, dynamic>> _records = [
    {'name': 'sylab', 'type': 'Agent 项目', 'time': '2026-08-07 18:14', 'amount': -61791.45},
    {'name': '小小酥', 'type': 'Coze Agent', 'time': '2026-08-07 18:13', 'amount': -2223201.01},
    {'name': '小小酥的新项目', 'type': 'Agent 项目', 'time': '2026-08-07 13:52', 'amount': -2096.38},
    {'name': 'codex', 'type': '云电脑', 'time': '2026-08-07 00:21', 'amount': -6200.0},
    {'name': '3d动漫', 'type': '云电脑', 'time': '2026-08-07 00:21', 'amount': -68400.0},
    {'name': '漫剧', 'type': '云手机', 'time': '2026-08-07 00:20', 'amount': -38085.12},
    {'name': '新项目', 'type': 'AI 编程', 'time': '2026-08-06 18:33', 'amount': -57385.65},
  ];

  static const Map<String, double> _categories = {
    'Agent 项目': 3367230.1,
    '编程项目': 77944.971,
    '视频项目': 0,
    '云设备': 112685.12,
    '会议': 0,
    '其他': 0,
  };

  static const double _totalUsage = 3557860.239;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20, color: CozeColors.fgPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: Row(
          children: const [
            Expanded(
              child: Text('积分充值',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: CozeColors.fgDim)),
            ),
            SizedBox(width: 1, height: 16, child: ColoredBox(color: CozeColors.strokePrimary)),
            Expanded(
              child: Text('积分消耗',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: CozeColors.fgPrimary)),
            ),
            Expanded(child: SizedBox()),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildStatsCard(),
          const SizedBox(height: 16),
          _buildSectionHeader(),
          const SizedBox(height: 12),
          _buildRecordsList(),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text('累计用量 ', style: TextStyle(fontSize: 14, color: CozeColors.fgDim)),
                  Text(_totalUsage.toStringAsFixed(3),
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: CozeColors.fgPrimary)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: CozeColors.strokePrimary),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('近一个月', style: TextStyle(fontSize: 12, color: CozeColors.fgSecondary)),
                    SizedBox(width: 4),
                    Icon(Icons.expand_more, size: 16, color: CozeColors.fgDim),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._categories.entries.map((entry) {
            final value = entry.value;
            final isActive = value > 0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  if (isActive)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(entry.key, style: const TextStyle(fontSize: 14, color: CozeColors.fgPrimary)),
                    )
                  else
                    Text(entry.key, style: const TextStyle(fontSize: 14, color: CozeColors.dimText)),
                  const Spacer(),
                  Text(isActive ? value.toStringAsFixed(3) : '0',
                      style: TextStyle(fontSize: 14, color: isActive ? CozeColors.fgPrimary : CozeColors.dimText)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSectionHeader() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('全部消耗明细',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: CozeColors.fgPrimary)),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('全部', style: TextStyle(fontSize: 14, color: CozeColors.fgSecondary)),
            SizedBox(width: 4),
            Icon(Icons.expand_more, size: 16, color: CozeColors.fgDim),
          ],
        ),
      ],
    );
  }

  Widget _buildRecordsList() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: List.generate(_records.length, (index) {
          final r = _records[index];
          final amount = r['amount'] as double;
          final abs = amount.abs();
          final formatted = abs >= 10000
              ? '${(abs / 10000).toStringAsFixed(4)}万'
              : abs.toStringAsFixed(2);
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(r['name'] as String,
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: CozeColors.fgPrimary)),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF5F5F5),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(r['type'] as String,
                                    style: const TextStyle(fontSize: 12, color: CozeColors.brand5)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text('${r['time']} | 查看项目',
                              style: const TextStyle(fontSize: 12, color: CozeColors.dimText)),
                        ],
                      ),
                    ),
                    Text('-$formatted',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: CozeColors.error)),
                  ],
                ),
              ),
              if (index < _records.length - 1)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(height: 1, color: CozeColors.strokePrimary),
                ),
            ],
          );
        }),
      ),
    );
  }
}
