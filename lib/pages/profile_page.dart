import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import '../theme/coze_colors.dart';
import '../theme/coze_theme.dart';
import '../services/auth_service.dart';
import 'skill_store_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _nickname = '冯包包';
  String? _avatarPath; // 本地保存的头像路径
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final savedName = prefs.getString('user_nickname');
    final savedAvatar = prefs.getString('user_avatar_path');
    if (savedName != null) {
      setState(() => _nickname = savedName);
    }
    if (savedAvatar != null) {
      setState(() => _avatarPath = savedAvatar);
    }
  }

  Future<void> _changeAvatar() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 512,
        maxHeight: 512,
      );
      if (image == null) return;

      // 保存到应用文档目录
      final bytes = await image.readAsBytes();
      final dir = Directory('${(await _getAppDir()).path}/profile');
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      final savePath = '${dir.path}/avatar.jpg';
      final file = File(savePath);
      await file.writeAsBytes(bytes);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_avatar_path', savePath);

      setState(() => _avatarPath = savePath);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('头像更新失败: $e'), duration: const Duration(seconds: 2)),
        );
      }
    }
  }

  Future<Directory> _getAppDir() async {
    return await getApplicationDocumentsDirectory();
  }

  Future<void> _changeNickname() async {
    final controller = TextEditingController(text: _nickname);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('修改昵称'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: '请输入新昵称',
            border: OutlineInputBorder(),
          ),
          maxLength: 20,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('确定'),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_nickname', result);
      setState(() => _nickname = result);
    }
  }

  Widget _buildAvatar() {
    if (_avatarPath != null) {
      final file = File(_avatarPath!);
      if (file.existsSync()) {
        return ClipOval(
          child: Image.file(file, width: 64, height: 64, fit: BoxFit.cover),
        );
      }
    }
    return Container(
      width: 64,
      height: 64,
      decoration: const BoxDecoration(color: CozeColors.infoBlue, shape: BoxShape.circle),
      child: Center(
        child: Text(
          _nickname.isNotEmpty ? _nickname[0] : '?',
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
        title: const Text('我的', style: TextStyle(fontSize: CozeFontSize.s18, fontWeight: FontWeight.bold, color: CozeColors.fgPrimary)),
      ),
      body: ListView(padding: const EdgeInsets.symmetric(horizontal: CozeSpacing.lg), children: [
        const SizedBox(height: CozeSpacing.lg),
        // Profile card
        Container(
          padding: const EdgeInsets.all(CozeSpacing.lg),
          decoration: BoxDecoration(color: CozeColors.chipGray, borderRadius: CozeRadius.xxlBorder),
          child: Row(children: [
            GestureDetector(
              onTap: _changeAvatar,
              child: Stack(clipBehavior: Clip.none, children: [
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
                      border: Border.all(color: CozeColors.strokePrimary),
                    ),
                    child: const Icon(Icons.camera_alt, size: 12, color: CozeColors.fgDim),
                  ),
                ),
              ]),
            ),
            const SizedBox(width: CozeSpacing.lg),
            Expanded(
              child: GestureDetector(
                onTap: _changeNickname,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Text(_nickname, style: const TextStyle(fontSize: CozeFontSize.s20, fontWeight: FontWeight.bold, color: CozeColors.fgPrimary)),
                    const SizedBox(width: CozeSpacing.sm),
                    const Icon(Icons.edit, size: 14, color: CozeColors.fgDim),
                  ]),
                  const SizedBox(height: 6),
                  Text('ID: user_${_nickname.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_')}', style: const TextStyle(fontSize: CozeFontSize.s14, color: CozeColors.fgDim)),
                ]),
              ),
            ),
          ]),
        ),
        const SizedBox(height: CozeSpacing.xl),
        // Credits card with consumption details
        Container(
          padding: const EdgeInsets.all(CozeSpacing.lg),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFFFFF8F0), Color(0xFFFFFDF5)]),
            borderRadius: CozeRadius.xxlBorder,
            border: Border.all(color: const Color(0xFFFFE4B5)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Icon(Icons.stars, size: 24, color: Color(0xFFFFB800)),
              const SizedBox(width: CozeSpacing.sm),
              const Expanded(child: Text('我的积分', style: TextStyle(fontSize: CozeFontSize.s16, fontWeight: FontWeight.w600, color: CozeColors.fgPrimary))),
            ]),
            const SizedBox(height: CozeSpacing.lg),
            Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('当前余额', style: TextStyle(fontSize: CozeFontSize.s12, color: CozeColors.fgDim)),
                const SizedBox(height: 4),
                Text('1,500', style: TextStyle(fontSize: CozeFontSize.s24, fontWeight: FontWeight.bold, color: CozeColors.fgPrimary)),
              ])),
              Container(width: 1, height: 40, color: CozeColors.separator),
              const SizedBox(width: CozeSpacing.md),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('本月消耗', style: TextStyle(fontSize: CozeFontSize.s12, color: CozeColors.fgDim)),
                const SizedBox(height: 4),
                Text('2,300', style: TextStyle(fontSize: CozeFontSize.s24, fontWeight: FontWeight.bold, color: CozeColors.error)),
              ])),
            ]),
            const SizedBox(height: CozeSpacing.lg),
            GestureDetector(
              onTap: () => _showCreditsDetail(),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: CozeSpacing.md, horizontal: CozeSpacing.lg),
                decoration: BoxDecoration(
                  color: CozeColors.bgMax,
                  borderRadius: BorderRadius.all(CozeRadius.lg),
                  border: Border.all(color: CozeColors.strokePrimary),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.receipt_long_outlined, size: 18, color: CozeColors.fgSecondary),
                    const SizedBox(width: CozeSpacing.sm),
                    const Text('查看消耗明细', style: TextStyle(fontSize: CozeFontSize.s14, color: CozeColors.fgSecondary)),
                  ],
                ),
              ),
            ),
          ]),
        ),
        const SizedBox(height: CozeSpacing.xxl),
        _section('常用功能', [
          _F(Icons.auto_awesome, '技能商店', CozeColors.brand5, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SkillStorePage()))),
          _F(Icons.favorite_outline, '我的收藏', CozeColors.error, () => _toast('功能开发中')),
        ]),
        const SizedBox(height: CozeSpacing.lg),
        _section('更多服务', [
          _F(Icons.workspace_premium_outlined, '会员特权', CozeColors.warning, () => _toast('功能开发中')),
          _F(Icons.card_giftcard_outlined, '积分商城', const Color(0xFFFF6B6B), () => _toast('功能开发中')),
          _F(Icons.people_outline, '邀请好友', CozeColors.success, () => _toast('功能开发中')),
        ]),
        const SizedBox(height: CozeSpacing.lg),
        _section('账号', [
          _F(Icons.notifications_outlined, '通知设置', CozeColors.fgSecondary, () => _toast('功能开发中')),
          _F(Icons.security_outlined, '隐私与安全', CozeColors.fgSecondary, () => _toast('功能开发中')),
        ]),
        const SizedBox(height: CozeSpacing.lg),
        _section('通用', [
          _F(Icons.dark_mode_outlined, '深色模式', CozeColors.fgSecondary, () => _toast('功能开发中')),
          _F(Icons.storage_outlined, '存储空间', CozeColors.fgSecondary, () => _toast('功能开发中')),
        ]),
        const SizedBox(height: CozeSpacing.xxl),
        if (auth.isLoggedIn) SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () async {
              await auth.logout();
              if (context.mounted) Navigator.of(context).pop();
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
      ]),
    );
  }

  Widget _section(String title, List<_F> items) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.only(bottom: CozeSpacing.sm, left: CozeSpacing.xs),
        child: Text(title, style: const TextStyle(fontSize: CozeFontSize.s14, fontWeight: FontWeight.w600, color: CozeColors.fgSecondary)),
      ),
      Container(
        decoration: BoxDecoration(color: CozeColors.chipGray, borderRadius: CozeRadius.xxlBorder),
        child: Column(children: List.generate(items.length, (i) => Column(children: [
          ListTile(
            leading: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(color: items[i].c.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
              child: Icon(items[i].icon, size: 20, color: items[i].c),
            ),
            title: Text(items[i].label, style: const TextStyle(fontSize: CozeFontSize.s16, color: CozeColors.fgPrimary)),
            trailing: const Icon(Icons.chevron_right, size: 20, color: CozeColors.dimText),
            onTap: items[i].onTap,
          ),
          if (i < items.length - 1) Divider(height: 1, color: CozeColors.strokePrimary, indent: 68),
        ]))),
      ),
    ]);
  }

  void _showCreditsDetail() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('积分消耗明细'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _detailRow('8月7日', '-100', '对话消耗'),
              _detailRow('8月6日', '-50', '生图消耗'),
              _detailRow('8月5日', '-200', '视频生成'),
              _detailRow('8月4日', '-150', '对话消耗'),
              SizedBox(height: 8),
              Text('新注册赠送 100 积分', style: TextStyle(color: Colors.green, fontSize: 13)),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('关闭')),
        ],
      ),
    );
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 1)),
    );
  }
}

class _detailRow extends StatelessWidget {
  final String date;
  final String amount;
  final String desc;
  const _detailRow(this.date, this.amount, this.desc);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        Text(date, style: const TextStyle(fontSize: 13, color: Colors.grey)),
        const SizedBox(width: 12),
        Text(amount, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.red)),
        const SizedBox(width: 8),
        Text(desc, style: const TextStyle(fontSize: 13)),
      ]),
    );
  }
}

class _F {
  final IconData icon;
  final String label;
  final Color c;
  final VoidCallback onTap;
  const _F(this.icon, this.label, this.c, this.onTap);
}
