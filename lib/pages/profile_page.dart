import 'dart:io';
import 'package:flutter/material.dart';
import '../theme/coze_colors.dart';
import '../theme/coze_theme.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../widgets/coze_dialog.dart';
import 'device_page.dart';
import 'skill_store_page.dart';
import 'history_page.dart';
import 'settings_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final UserService _userService = UserService();

  Future<void> _changeAvatar() async {
    final success = await _userService.changeAvatar();
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('头像更新失败'), duration: Duration(seconds: 2)),
      );
    }
  }

  Future<void> _changeNickname() async {
    final result = await CozeDialog.showInput(
      context,
      title: '修改昵称',
      hintText: '请输入新昵称',
      initialValue: _userService.nickname,
      confirmText: '确定',
    );
    if (result != null && result.isNotEmpty) {
      await _userService.changeNickname(result);
    }
  }

  Widget _buildAvatar() {
    final avatarFile = _userService.avatarFile;
    if (avatarFile != null) {
      return ClipOval(
        child: Image.file(avatarFile, width: 64, height: 64, fit: BoxFit.cover),
      );
    }
    return Container(
      width: 64,
      height: 64,
      decoration: const BoxDecoration(color: CozeColors.infoBlue, shape: BoxShape.circle),
      child: Center(
        child: Text(
          _userService.initials,
          style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();
    return Scaffold(
      backgroundColor: CozeColors.bgMax,
      appBar: AppBar(
        backgroundColor: CozeColors.bgMax,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20, color: CozeColors.fgPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('我的',
            style: TextStyle(
                fontSize: CozeFontSize.s18,
                fontWeight: FontWeight.bold,
                color: CozeColors.fgPrimary)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, size: 22, color: CozeColors.fgDim),
            onPressed: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => const SettingsPage())),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: CozeSpacing.lg),
        children: [
          const SizedBox(height: CozeSpacing.lg),
          // ─── User Profile Card ───
          _buildProfileCard(context),
          const SizedBox(height: CozeSpacing.xl),
          // ─── Credits/Membership Card ───
          _buildMembershipCard(context),
          const SizedBox(height: CozeSpacing.xxl),
          // ─── Feature Entries ───
          _buildFeatureSection(context, '常用功能', [
            _FeatureItem(Icons.devices, '设备管理', CozeColors.infoBlue, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const DevicePage()));
            }),
            _FeatureItem(Icons.auto_awesome, '技能商店', CozeColors.brand5, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SkillStorePage()));
            }),
            _FeatureItem(Icons.history, '历史对话', CozeColors.teal, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryPage()));
            }),
            _FeatureItem(Icons.favorite_outline, '我的收藏', CozeColors.error, () {
              _showToast(context, '功能开发中');
            }),
          ]),
          const SizedBox(height: CozeSpacing.lg),
          // ─── More Features ───
          _buildFeatureSection(context, '更多服务', [
            _FeatureItem(Icons.workspace_premium_outlined, '会员特权', CozeColors.warning, () {
              _showToast(context, '功能开发中');
            }),
            _FeatureItem(Icons.card_giftcard_outlined, '积分商城', const Color(0xFFFF6B6B), () {
              _showToast(context, '功能开发中');
            }),
            _FeatureItem(Icons.people_outline, '邀请好友', CozeColors.success, () {
              _showToast(context, '功能开发中');
            }),
          ]),
          const SizedBox(height: CozeSpacing.lg),
          // ─── About & Help ───
          _buildFeatureSection(context, '关于与帮助', [
            _FeatureItem(Icons.info_outline, '关于Coze', CozeColors.fgDim, () {
              _showToast(context, 'Coze Replica v1.0.0');
            }),
            _FeatureItem(Icons.help_outline, '帮助与反馈', CozeColors.fgDim, () {
              _showToast(context, '功能开发中');
            }),
            _FeatureItem(Icons.policy_outlined, '隐私政策', CozeColors.fgDim, () {
              _showToast(context, '功能开发中');
            }),
          ]),
          const SizedBox(height: CozeSpacing.xxl),
          // ─── Logout Button ───
          if (auth.isLoggedIn)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () async {
                  await auth.logout();
                  if (context.mounted) {
                    _showToast(context, '已退出登录');
                    Navigator.of(context).pop();
                  }
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: CozeColors.error,
                  side: const BorderSide(color: CozeColors.error),
                  shape: RoundedRectangleBorder(borderRadius: CozeRadius.xlBorder),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('退出登录', style: TextStyle(fontSize: CozeFontSize.s16)),
              ),
            ),
          const SizedBox(height: CozeSpacing.xxl),
        ],
      ),
    );
  }

  // ─── Profile Card ───
  Widget _buildProfileCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsPage()));
      },
      child: Container(
        padding: const EdgeInsets.all(CozeSpacing.lg),
        decoration: BoxDecoration(
          color: CozeColors.chipGray,
          borderRadius: CozeRadius.xxlBorder,
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: _changeAvatar,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  _buildAvatar(),
                  Positioned(
                    right: -2,
                    bottom: -2,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: CozeColors.bgMax,
                        shape: BoxShape.circle,
                        border: Border.all(color: CozeColors.strokePrimary, width: 1),
                      ),
                      child: const Icon(Icons.camera_alt, size: 12, color: CozeColors.fgDim),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: CozeSpacing.lg),
            Expanded(
              child: GestureDetector(
                onTap: _changeNickname,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(_userService.nickname,
                            style: const TextStyle(
                                fontSize: CozeFontSize.s20,
                                fontWeight: FontWeight.bold,
                                color: CozeColors.fgPrimary)),
                        const SizedBox(width: CozeSpacing.sm),
                        const Icon(Icons.edit, size: 14, color: CozeColors.fgDim),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text('ID: user_${_userService.nickname.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_')}',
                        style: const TextStyle(fontSize: CozeFontSize.s14, color: CozeColors.fgDim)),
                  ],
                ),
              ),
            ),
            const Icon(Icons.chevron_right, size: 22, color: CozeColors.fgDim),
          ],
        ),
      ),
    );
  }

  // ─── Membership Card ───
  Widget _buildMembershipCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(CozeSpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF8F0), Color(0xFFFFFDF5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: CozeRadius.xxlBorder,
        border: Border.all(color: const Color(0xFFFFE4B5), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.stars, size: 24, color: Color(0xFFFFB800)),
              const SizedBox(width: CozeSpacing.sm),
              const Expanded(
                child: Text('我的积分',
                    style: TextStyle(
                        fontSize: CozeFontSize.s16,
                        fontWeight: FontWeight.w600,
                        color: CozeColors.fgPrimary)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: CozeSpacing.md, vertical: 4),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFB800), Color(0xFFFF8C00)],
                  ),
                  borderRadius: CozeRadius.pillBorder,
                ),
                child: const Text('升级Pro',
                    style: TextStyle(
                        fontSize: CozeFontSize.s12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white)),
              ),
            ],
          ),
          const SizedBox(height: CozeSpacing.lg),
          Row(
            children: [
              _creditStat('当前积分', '1,500'),
              Container(width: 1, height: 32, color: CozeColors.separator),
              _creditStat('本月消耗', '2,300'),
              Container(width: 1, height: 32, color: CozeColors.separator),
              _creditStat('每日赠送', '100'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _creditStat(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: const TextStyle(
                  fontSize: CozeFontSize.s18,
                  fontWeight: FontWeight.bold,
                  color: CozeColors.fgPrimary)),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(fontSize: CozeFontSize.s12, color: CozeColors.fgDim)),
        ],
      ),
    );
  }

  // ─── Feature Section ───
  Widget _buildFeatureSection(BuildContext context, String title, List<_FeatureItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: CozeSpacing.sm, left: CozeSpacing.xs),
          child: Text(title,
              style: const TextStyle(
                  fontSize: CozeFontSize.s14,
                  fontWeight: FontWeight.w600,
                  color: CozeColors.fgSecondary)),
        ),
        Container(
          decoration: BoxDecoration(
            color: CozeColors.chipGray,
            borderRadius: CozeRadius.xxlBorder,
          ),
          child: Column(
            children: List.generate(items.length, (i) {
              final item = items[i];
              return Column(
                children: [
                  ListTile(
                    leading: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: item.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(item.icon, size: 20, color: item.color),
                    ),
                    title: Text(item.label,
                        style: const TextStyle(fontSize: CozeFontSize.s16, color: CozeColors.fgPrimary)),
                    trailing: const Icon(Icons.chevron_right, size: 20, color: CozeColors.dimText),
                    onTap: item.onTap,
                  ),
                  if (i < items.length - 1)
                    Divider(height: 1, color: CozeColors.strokePrimary, indent: 68),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }

  void _showToast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 1)),
    );
  }
}

class _FeatureItem {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _FeatureItem(this.icon, this.label, this.color, this.onTap);
}
