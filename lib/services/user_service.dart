import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';

/// 全局用户状态管理器
class UserService extends ChangeNotifier {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  String _nickname = '冯包包';
  String? _avatarPath;
  final ImagePicker _imagePicker = ImagePicker();

  String get nickname => _nickname;
  String? get avatarPath => _avatarPath;
  String get initials => _nickname.isNotEmpty ? _nickname[0] : '?';

  /// 加载用户信息
  Future<void> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final savedName = prefs.getString('user_nickname');
    final savedAvatar = prefs.getString('user_avatar_path');
    if (savedName != null) {
      _nickname = savedName;
    }
    if (savedAvatar != null) {
      _avatarPath = savedAvatar;
    }
    notifyListeners();
  }

  /// 修改昵称
  Future<void> changeNickname(String newNickname) async {
    if (newNickname.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_nickname', newNickname);
    _nickname = newNickname;
    notifyListeners();
  }

  /// 修改头像
  Future<bool> changeAvatar() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 512,
        maxHeight: 512,
      );
      if (image == null) return false;

      final bytes = await image.readAsBytes();
      final dir = Directory('${(await getApplicationDocumentsDirectory()).path}/profile');
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      final savePath = '${dir.path}/avatar.jpg';
      final file = File(savePath);
      await file.writeAsBytes(bytes);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_avatar_path', savePath);
      _avatarPath = savePath;
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 获取头像文件
  File? get avatarFile {
    if (_avatarPath != null) {
      final file = File(_avatarPath!);
      if (file.existsSync()) {
        return file;
      }
    }
    return null;
  }
}
