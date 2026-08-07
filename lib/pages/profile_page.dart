import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import '../theme/coze_colors.dart';
import '../theme/coze_theme.dart';
import '../services/auth_service.dart';
import '../widgets/coze_dialog.dart';
import 'credits_detail_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _nickname = '冯包包';
  String? _avatarPath;
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
    final result = await CozeDialog.showInput(
      context,
      title: '修改昵称',
      hintText: '请输入新昵称',
      initialValue: _nickname,
      confirmText: '确定',
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
        // Credits card
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
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreditsDetailPage())),
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
        // Logout button
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
}
