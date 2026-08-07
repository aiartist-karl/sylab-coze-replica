import 'package:flutter/material.dart';
import '../theme/coze_colors.dart';
import '../theme/coze_theme.dart';
import '../services/auth_service.dart';
import 'device_page.dart';
import 'skill_store_page.dart';
import 'history_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});
  @override
  Widget build(BuildContext context) {
    final auth = AuthService();
    return Scaffold(
      backgroundColor: CozeColors.bgMax,
      appBar: AppBar(backgroundColor: CozeColors.bgMax, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, size: 20, color: CozeColors.fgPrimary), onPressed: () => Navigator.pop(context)),
        title: const Text('我的', style: TextStyle(fontSize: CozeFontSize.s18, fontWeight: FontWeight.bold, color: CozeColors.fgPrimary))),
      body: ListView(padding: const EdgeInsets.symmetric(horizontal: CozeSpacing.lg), children: [
        const SizedBox(height: CozeSpacing.lg),
        // Profile card
        Container(padding: const EdgeInsets.all(CozeSpacing.lg),
          decoration: BoxDecoration(color: CozeColors.chipGray, borderRadius: CozeRadius.xxlBorder),
          child: Row(children: [
            Stack(clipBehavior: Clip.none, children: [
              Container(width: 64, height: 64, decoration: const BoxDecoration(color: CozeColors.infoBlue, shape: BoxShape.circle),
                  child: const Center(child: Text('冯', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w600)))),
              Positioned(right: -2, bottom: -2, child: Container(width: 22, height: 22,
                  decoration: BoxDecoration(color: CozeColors.bgMax, shape: BoxShape.circle, border: Border.all(color: CozeColors.strokePrimary)),
                  child: const Icon(Icons.camera_alt, size: 12, color: CozeColors.fgDim))),
            ]),
            const SizedBox(width: CozeSpacing.lg),
            const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [Text('冯包包', style: TextStyle(fontSize: CozeFontSize.s20, fontWeight: FontWeight.bold, color: CozeColors.fgPrimary)),
                  SizedBox(width: CozeSpacing.sm), Icon(Icons.edit, size: 14, color: CozeColors.fgDim)]),
              SizedBox(height: 6),
              Text('ID: user_fengbaobao', style: TextStyle(fontSize: CozeFontSize.s14, color: CozeColors.fgDim)),
            ])),
          ])),
        const SizedBox(height: CozeSpacing.xl),
        // Credits card
        Container(padding: const EdgeInsets.all(CozeSpacing.lg),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFFFFF8F0), Color(0xFFFFFDF5)]),
            borderRadius: CozeRadius.xxlBorder, border: Border.all(color: const Color(0xFFFFE4B5))),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Icon(Icons.stars, size: 24, color: Color(0xFFFFB800)),
              const SizedBox(width: CozeSpacing.sm),
              const Expanded(child: Text('我的积分', style: TextStyle(fontSize: CozeFontSize.s16, fontWeight: FontWeight.w600, color: CozeColors.fgPrimary))),
              Container(padding: const EdgeInsets.symmetric(horizontal: CozeSpacing.md, vertical: 4),
                decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFFFB800), Color(0xFFFF8C00)]), borderRadius: CozeRadius.pillBorder),
                child: const Text('升级Pro', style: TextStyle(fontSize: CozeFontSize.s12, fontWeight: FontWeight.w600, color: Colors.white))),
            ]),
            const SizedBox(height: CozeSpacing.lg),
            Row(children: [
              _stat('当前积分', '1,500'), Container(width: 1, height: 32, color: CozeColors.separator),
              _stat('本月消耗', '2,300'), Container(width: 1, height: 32, color: CozeColors.separator),
              _stat('每日赠送', '100'),
            ]),
          ])),
        const SizedBox(height: CozeSpacing.xxl),
        // 常用功能
        _section('常用功能', [
          _F(Icons.devices, '设备管理', CozeColors.infoBlue, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DevicePage()))),
          _F(Icons.auto_awesome, '技能商店', CozeColors.brand5, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SkillStorePage()))),
          _F(Icons.history, '历史对话', CozeColors.teal, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryPage()))),
          _F(Icons.favorite_outline, '我的收藏', CozeColors.error, () => _toast(context)),
        ], context),
        const SizedBox(height: CozeSpacing.lg),
        // 更多服务
        _section('更多服务', [
          _F(Icons.workspace_premium_outlined, '会员特权', CozeColors.warning, () => _toast(context)),
          _F(Icons.card_giftcard_outlined, '积分商城', const Color(0xFFFF6B6B), () => _toast(context)),
          _F(Icons.people_outline, '邀请好友', CozeColors.success, () => _toast(context)),
        ], context),
        const SizedBox(height: CozeSpacing.lg),
        // 账号设置
        _section('账号', [
          _F(Icons.person_outline, '个人信息', CozeColors.fgSecondary, () => _toast(context)),
          _F(Icons.notifications_outlined, '通知设置', CozeColors.fgSecondary, () => _toast(context)),
          _F(Icons.security_outlined, '隐私与安全', CozeColors.fgSecondary, () => _toast(context)),
        ], context),
        const SizedBox(height: CozeSpacing.lg),
        // 通用设置
        _section('通用', [
          _F(Icons.language, '语言', CozeColors.fgSecondary, () => _toast(context)),
          _F(Icons.dark_mode_outlined, '深色模式', CozeColors.fgSecondary, () => _toast(context)),
          _F(Icons.storage_outlined, '存储空间', CozeColors.fgSecondary, () => _toast(context)),
        ], context),
        const SizedBox(height: CozeSpacing.lg),
        // 关于
        _section('关于', [
          _F(Icons.info_outline, '关于Coze', CozeColors.fgSecondary, () => _toast(context, 'Coze Replica v1.1.0')),
          _F(Icons.feedback_outlined, '意见反馈', CozeColors.fgSecondary, () => _toast(context)),
          _F(Icons.description_outlined, '用户协议', CozeColors.fgSecondary, () => _toast(context)),
        ], context),
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

  Widget _stat(String label, String value) {
    return Expanded(child: Column(children: [
      Text(value, style: const TextStyle(fontSize: CozeFontSize.s18, fontWeight: FontWeight.bold, color: CozeColors.fgPrimary)),
      const SizedBox(height: 4),
      Text(label, style: const TextStyle(fontSize: CozeFontSize.s12, color: CozeColors.fgDim)),
    ]));
  }

  Widget _section(String title, List<_F> items, BuildContext ctx) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(padding: const EdgeInsets.only(bottom: CozeSpacing.sm, left: CozeSpacing.xs),
          child: Text(title, style: const TextStyle(fontSize: CozeFontSize.s14, fontWeight: FontWeight.w600, color: CozeColors.fgSecondary))),
      Container(decoration: BoxDecoration(color: CozeColors.chipGray, borderRadius: CozeRadius.xxlBorder),
        child: Column(children: List.generate(items.length, (i) => Column(children: [
          ListTile(
            leading: Container(width: 36, height: 36,
                decoration: BoxDecoration(color: items[i].c.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: Icon(items[i].icon, size: 20, color: items[i].c)),
            title: Text(items[i].label, style: const TextStyle(fontSize: CozeFontSize.s16, color: CozeColors.fgPrimary)),
            trailing: const Icon(Icons.chevron_right, size: 20, color: CozeColors.dimText),
            onTap: items[i].onTap),
          if (i < items.length - 1) Divider(height: 1, color: CozeColors.strokePrimary, indent: 68),
        ])))),
    ]);
  }

  void _toast(BuildContext ctx, [String msg = '功能开发中']) {
    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(msg), duration: const Duration(seconds: 1)));
  }
}

class _F { final IconData icon; final String label; final Color c; final VoidCallback onTap;
  const _F(this.icon, this.label, this.c, this.onTap); }
