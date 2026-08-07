import 'package:flutter/material.dart';
import '../theme/coze_colors.dart';
import '../theme/coze_theme.dart';

class CreditsDetailPage extends StatefulWidget {
  const CreditsDetailPage({super.key});

  @override
  State<CreditsDetailPage> createState() => _CreditsDetailPageState();
}

class _CreditsDetailPageState extends State<CreditsDetailPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // Mock stats data
  final Map<String, dynamic> _stats = {
    'totalUsage': 3557860.239,
    'period': '近一个月',
    'categories': {
      'Agent 项目': 3367230.1,
      '编程项目': 77944.971,
      '视频项目': 0,
      '云设备': 112685.12,
      '会议': 0,
      '其他': 0,
    },
  };

  // Mock consumption records
  final List<Map<String, dynamic>> _records = [
    {
      'name': 'sylab',
      'type': 'Agent 项目',
      'typeColor': CozeColors.brand5,
      'time': '2026-08-07 18:14',
      'amount': -61791.45,
    },
    {
      'name': '小小酥',
      'type': 'Coze Agent',
      'typeColor': CozeColors.brand5,
      'time': '2026-08-07 18:13',
      'amount': -2223201.01,
    },
    {
      'name': '小小酥的新项目',
      'type': 'Agent 项目',
      'typeColor': CozeColors.brand5,
      'time': '2026-08-07 13:52',
      'amount': -2096.38,
    },
    {
      'name': 'codex',
      'type': '云电脑',
      'typeColor': CozeColors.teal,
      'time': '2026-08-07 00:21',
      'amount': -6200,
    },
    {
      'name': '3d动漫',
      'type': '云电脑',
      'typeColor': CozeColors.teal,
      'time': '2026-08-07 00:21',
      'amount': -68400,
    },
    {
      'name': '漫剧',
      'type': '云手机',
      'typeColor': CozeColors.purple,
      'time': '2026-08-07 00:20',
      'amount': -38085.12,
    },
    {
      'name': '新项目',
      'type': 'AI 编程',
      'typeColor': CozeColors.orange,
      'time': '2026-08-06 18:33',
      'amount': -57385.65,
    },
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CozeColors.bgMax,
      appBar: AppBar(
        backgroundColor: CozeColors.bgMax,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20, color: CozeColors.fgPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            const Expanded(
              child: Text('积分充值',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: CozeFontSize.s16,
                      fontWeight: FontWeight.w500,
                      color: CozeColors.fgDim)),
            ),
            Container(width: 1, height: 16, color: CozeColors.strokePrimary),
            const Expanded(
              child: Text('积分消耗',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: CozeFontSize.s16,
                      fontWeight: FontWeight.bold,
                      color: CozeColors.fgPrimary)),
            ),
            const Expanded(child: SizedBox()),
          ],
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: CozeSpacing.lg, vertical: CozeSpacing.lg),
          children: [
            _buildStatsCard(),
            const SizedBox(height: CozeSpacing.lg),
            _buildSectionHeader(),
            const SizedBox(height: CozeSpacing.md),
            _buildRecordsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard() {
    final totalUsage = _stats['totalUsage'] as double;
    final categories = _stats['categories'] as Map<String, dynamic>;

    return Container(
      padding: const EdgeInsets.all(CozeSpacing.lg),
      decoration: BoxDecoration(
        color: CozeColors.cardGray,
        borderRadius: CozeRadius.xxlBorder,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text('累计用量 ',
                      style: TextStyle(
                          fontSize: CozeFontSize.s14, color: CozeColors.fgDim)),
                  Text(_formatNumber(totalUsage),
                      style: const TextStyle(
                          fontSize: CozeFontSize.s24,
                          fontWeight: FontWeight.bold,
                          color: CozeColors.fgPrimary)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: CozeSpacing.md, vertical: CozeSpacing.xs),
                decoration: BoxDecoration(
                  border: Border.all(color: CozeColors.strokePrimary),
                  borderRadius: CozeRadius.xlBorder,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_stats['period'] as String,
                        style: const TextStyle(
                            fontSize: CozeFontSize.s12, color: CozeColors.fgSecondary)),
                    const SizedBox(width: 4),
                    const Icon(Icons.expand_more, size: 16, color: CozeColors.fgDim),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: CozeSpacing.lg),
          ...categories.entries.map((entry) {
            final value = entry.value as double;
            final ratio = value / totalUsage;
            return Padding(
              padding: const EdgeInsets.only(bottom: CozeSpacing.sm),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: CozeSpacing.sm, vertical: 2),
                    decoration: BoxDecoration(
                      color: value > 0 ? CozeColors.chipGray : Colors.transparent,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(entry.key,
                        style: TextStyle(
                            fontSize: CozeFontSize.s14,
                            color: value > 0 ? CozeColors.fgPrimary : CozeColors.dimText)),
                  ),
                  const Spacer(),
                  Text(value > 0 ? _formatNumber(value) : '0',
                      style: TextStyle(
                          fontSize: CozeFontSize.s14,
                          color: value > 0 ? CozeColors.fgPrimary : CozeColors.dimText)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('全部消耗明细',
            style: TextStyle(
                fontSize: CozeFontSize.s16,
                fontWeight: FontWeight.bold,
                color: CozeColors.fgPrimary)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: CozeSpacing.sm),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('全部',
                  style: TextStyle(
                      fontSize: CozeFontSize.s14, color: CozeColors.fgSecondary)),
              const SizedBox(width: 4),
              const Icon(Icons.expand_more, size: 16, color: CozeColors.fgDim),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecordsList() {
    return Container(
      decoration: BoxDecoration(
        color: CozeColors.cardGray,
        borderRadius: CozeRadius.xxlBorder,
      ),
      child: Column(
        children: List.generate(_records.length, (index) {
          final record = _records[index];
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: CozeSpacing.lg, vertical: CozeSpacing.md),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(record['name'] as String,
                                  style: const TextStyle(
                                      fontSize: CozeFontSize.s16,
                                      fontWeight: FontWeight.w600,
                                      color: CozeColors.fgPrimary)),
                              const SizedBox(width: CozeSpacing.sm),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: CozeColors.chipGray,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(record['type'] as String,
                                    style: TextStyle(
                                        fontSize: CozeFontSize.s12,
                                        color: record['typeColor'] as Color)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text('${record['time']} | 查看项目',
                              style: const TextStyle(
                                  fontSize: CozeFontSize.s12,
                                  color: CozeColors.dimText)),
                        ],
                      ),
                    ),
                    Text(_formatAmount(record['amount'] as double),
                        style: TextStyle(
                            fontSize: CozeFontSize.s18,
                            fontWeight: FontWeight.bold,
                            color: record['amount'] < 0 ? CozeColors.error : CozeColors.success)),
                  ],
                ),
              ),
              if (index < _records.length - 1)
                Divider(height: 1, color: CozeColors.strokePrimary, indent: CozeSpacing.lg),
            ],
          );
        }),
      ),
    );
  }

  String _formatNumber(double value) {
    return value.toStringAsFixed(3);
  }

  String _formatAmount(double value) {
    final abs = value.abs();
    final formatted = abs >= 10000
        ? '${(abs / 10000).toStringAsFixed(4)}万'
        : abs.toStringAsFixed(2);
    return '-$formatted';
  }
}
