import 'package:flutter/material.dart';
import '../theme/coze_colors.dart';
import '../theme/coze_theme.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});
  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _recent = ['如何创建Agent', '数据分析', '视频生成'];
  final List<String> _hot = ['AI绘画', '代码助手', '小红书', '视频制作', '金融分析'];

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CozeColors.bgMax,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(CozeSpacing.lg, CozeSpacing.md, CozeSpacing.lg, CozeSpacing.sm),
              child: Row(
                children: [
                  GestureDetector(onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.arrow_back_ios, size: 20, color: CozeColors.fgPrimary)),
                  const SizedBox(width: CozeSpacing.sm),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: CozeSpacing.md),
                      decoration: BoxDecoration(color: CozeColors.chipGray, borderRadius: CozeRadius.pillBorder),
                      child: TextField(controller: _controller,
                          decoration: const InputDecoration(hintText: '搜索Agent、技能、项目...',
                              border: InputBorder.none, hintStyle: TextStyle(fontSize: CozeFontSize.s14, color: CozeColors.dimText))),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: CozeSpacing.lg),
                children: [
                  const Text('最近搜索', style: TextStyle(fontSize: CozeFontSize.s14, fontWeight: FontWeight.w600, color: CozeColors.fgSecondary)),
                  const SizedBox(height: CozeSpacing.sm),
                  Wrap(spacing: CozeSpacing.sm, runSpacing: CozeSpacing.sm,
                      children: _recent.map((s) => _chip(s)).toList()),
                  const SizedBox(height: CozeSpacing.xl),
                  const Text('热门搜索', style: TextStyle(fontSize: CozeFontSize.s14, fontWeight: FontWeight.w600, color: CozeColors.fgSecondary)),
                  const SizedBox(height: CozeSpacing.sm),
                  Wrap(spacing: CozeSpacing.sm, runSpacing: CozeSpacing.sm,
                      children: _hot.map((s) => _chip(s)).toList()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label) {
    return GestureDetector(
      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('搜索: $label'), duration: const Duration(seconds: 1))),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: CozeSpacing.md, vertical: CozeSpacing.sm),
        decoration: BoxDecoration(color: CozeColors.chipGray, borderRadius: CozeRadius.pillBorder),
        child: Text(label, style: const TextStyle(fontSize: CozeFontSize.s14, color: CozeColors.fgPrimary)),
      ),
    );
  }
}
