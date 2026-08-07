import 'package:flutter/material.dart';
import '../theme/coze_colors.dart';
import '../theme/coze_theme.dart';
import '../services/auth_service.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});
  @override
  Widget build(BuildContext context) {
    final auth = AuthService();
    return Scaffold(
      backgroundColor: CozeColors.bgMax,
      appBar: AppBar(backgroundColor: CozeColors.bgMax, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, size: 20, color: CozeColors.fgPrimary), onPressed: () => Navigator.pop(context)),
        title: const Text('设置', style: TextStyle(fontSize: CozeFontSize.s18, fontWeight: FontWeight.bold, color: CozeColors.fgPrimary))),
      body: ListView(padding: const EdgeInsets.symmetric(horizontal: CozeSpacing.lg), children: [
        const SizedBox(height: CozeSpacing.lg),
        Container(padding: const EdgeInsets.all(CozeSpacing.lg),
          decoration: BoxDecoration(color: CozeColors.chipGray, borderRadius: CozeRadius.xxlBorder),
          child: Row(children: [
            Container(width: 56, height: 56, decoration: const BoxDecoration(color: CozeColors.infoBlue, shape: BoxShape.circle),
                child: const Center(child: Text('冯', style: TextStyle(color: Colors.white, fontSize: CozeFontSize.s24, fontWeight: FontWeight.w600)))),
            const SizedBox(width: CozeSpacing.md),
            const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('冯包包', style: TextStyle(fontSize: CozeFontSize.s18, fontWeight: FontWeight.bold, color: CozeColors.fgPrimary)),
              SizedBox(height: 4),
              Text('1,500 积分', style: TextStyle(fontSize: CozeFontSize.s14, color: CozeColors.fgDim)),
            ])),
            const Icon(Icons.chevron_right, size: 22, color: CozeColors.fgDim),
          ])),
        const SizedBox(height: CozeSpacing.xxl),
        _section('账号', [Icons.person_outline, Icons.notifications_outlined, Icons.security_outlined],
            ['个人信息', '通知设置', '隐私与安全'], context),
        const SizedBox(height: CozeSpacing.lg),
        _section('通用', [Icons.language, Icons.dark_mode_outlined, Icons.storage_outlined],
            ['语言', '深色模式', '存储空间'], context),
        const SizedBox(height: CozeSpacing.lg),
        _section('关于', [Icons.info_outline, Icons.feedback_outlined, Icons.description_outlined],
            ['关于Coze', '意见反馈', '用户协议'], context),
        const SizedBox(height: CozeSpacing.xxl),
        if (auth.isLoggedIn) SizedBox(width: double.infinity, child: OutlinedButton(
          onPressed: () async { await auth.logout(); if (context.mounted) { Navigator.of(context).pop(); } },
          style: OutlinedButton.styleFrom(foregroundColor: CozeColors.error,
              side: const BorderSide(color: CozeColors.error),
              shape: RoundedRectangleBorder(borderRadius: CozeRadius.xlBorder),
              padding: const EdgeInsets.symmetric(vertical: 14)),
          child: const Text('退出登录', style: TextStyle(fontSize: CozeFontSize.s16)),
        )),
        const SizedBox(height: CozeSpacing.xxl),
      ]),
    );
  }

  Widget _section(String title, List<IconData> icons, List<String> labels, BuildContext ctx) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(padding: const EdgeInsets.only(bottom: CozeSpacing.sm, left: CozeSpacing.xs),
          child: Text(title, style: const TextStyle(fontSize: CozeFontSize.s14, fontWeight: FontWeight.w600, color: CozeColors.fgSecondary))),
      Container(decoration: BoxDecoration(color: CozeColors.chipGray, borderRadius: CozeRadius.xxlBorder),
        child: Column(children: List.generate(icons.length, (i) => Column(children: [
          ListTile(leading: Icon(icons[i], size: 22, color: CozeColors.fgSecondary),
              title: Text(labels[i], style: const TextStyle(fontSize: CozeFontSize.s16, color: CozeColors.fgPrimary)),
              trailing: const Icon(Icons.chevron_right, size: 20, color: CozeColors.dimText),
              onTap: () => ScaffoldMessenger.of(ctx).showSnackBar(
                  SnackBar(content: Text('功能开发中'), duration: const Duration(seconds: 1)))),
          if (i < icons.length - 1) Divider(height: 1, color: CozeColors.strokePrimary, indent: 56),
        ])))),
    ]);
  }
}
