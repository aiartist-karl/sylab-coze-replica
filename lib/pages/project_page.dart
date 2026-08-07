import 'package:flutter/material.dart';
import '../theme/coze_colors.dart';
import '../theme/coze_theme.dart';

class ProjectPage extends StatelessWidget {
  const ProjectPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CozeColors.bgMax,
      appBar: AppBar(backgroundColor: CozeColors.bgMax, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, size: 20, color: CozeColors.fgPrimary), onPressed: () => Navigator.pop(context)),
        title: const Text('项目', style: TextStyle(fontSize: CozeFontSize.s18, fontWeight: FontWeight.bold, color: CozeColors.fgPrimary))),
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.folder_open, size: 64, color: CozeColors.fgDim),
          const SizedBox(height: CozeSpacing.lg),
          const Text('暂无项目', style: TextStyle(fontSize: CozeFontSize.s18, color: CozeColors.fgDim)),
          const SizedBox(height: CozeSpacing.sm),
          const Text('点击 + 创建你的第一个项目', style: TextStyle(fontSize: CozeFontSize.s14, color: CozeColors.dimText)),
          const SizedBox(height: CozeSpacing.xxl),
          ElevatedButton.icon(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('功能开发中'), duration: Duration(seconds: 1))),
            icon: const Icon(Icons.add), label: const Text('创建项目'),
            style: ElevatedButton.styleFrom(backgroundColor: CozeColors.brand5, foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)))),
        ]),
      ),
    );
  }
}
