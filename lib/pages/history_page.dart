import 'package:flutter/material.dart';
import '../theme/coze_colors.dart';
import '../theme/coze_theme.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});
  @override
  Widget build(BuildContext context) {
    final items = [
      _H('和小篷讨论了项目方案', '今天 14:30', '🚀'),
      _H('修仙巨擎Reborn对话', '昨天 10:15', '⚔️'),
      _H('代码助手Pro调试记录', '2天前', '🤖'),
      _H('数据分析师报告生成', '3天前', '📊'),
    ];
    return Scaffold(
      backgroundColor: CozeColors.bgMax,
      appBar: AppBar(backgroundColor: CozeColors.bgMax, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, size: 20, color: CozeColors.fgPrimary), onPressed: () => Navigator.pop(context)),
        title: const Text('历史对话', style: TextStyle(fontSize: CozeFontSize.s18, fontWeight: FontWeight.bold, color: CozeColors.fgPrimary))),
      body: ListView.separated(
        padding: const EdgeInsets.all(CozeSpacing.lg), itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: CozeSpacing.sm),
        itemBuilder: (_, i) {
          final item = items[i];
          return Container(padding: const EdgeInsets.all(CozeSpacing.md),
            decoration: BoxDecoration(color: CozeColors.chipGray, borderRadius: CozeRadius.xlBorder),
            child: Row(children: [
              Container(width: 40, height: 40,
                decoration: BoxDecoration(color: CozeColors.bgSecondary, borderRadius: BorderRadius.circular(20)),
                child: Center(child: Text(item.e, style: const TextStyle(fontSize: 20)))),
              const SizedBox(width: CozeSpacing.md),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(item.t, style: const TextStyle(fontSize: CozeFontSize.s16, fontWeight: FontWeight.w500, color: CozeColors.fgPrimary)),
                const SizedBox(height: 4),
                Text(item.d, style: const TextStyle(fontSize: CozeFontSize.s12, color: CozeColors.dimText)),
              ])),
              const Icon(Icons.chevron_right, size: 20, color: CozeColors.dimText),
            ]));
        }),
    );
  }
}
class _H { final String t, d, e; const _H(this.t, this.d, this.e); }
