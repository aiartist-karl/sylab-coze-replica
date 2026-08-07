import 'package:flutter/material.dart';
import 'dart:io';
import '../theme/coze_colors.dart';
import '../theme/coze_theme.dart';
import '../models/chat_item.dart';
import '../services/user_service.dart';
import 'skill_store_page.dart';
import 'device_page.dart';
import 'chat_page.dart';
import 'search_page.dart';
import 'project_page.dart';
import 'world_page.dart';
import 'history_page.dart';
import 'settings_page.dart';
import 'profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _showCreateMenu = false;
  late List<ChatListItem> _chatList;

  @override
  void initState() {
    super.initState();
    _chatList = [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CozeColors.bgMax,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildUserBar(),
            _buildCreditsBanner(),
            _buildQuickActions(),
            Expanded(child: _buildChatList()),
          ],
        ),
      ),
    );
  }

  // ─── User Info Bar (~70px) ───
  Widget _buildUserBar() {
    final userService = UserService();
    final avatarFile = userService.avatarFile;
    final initials = userService.initials;
    final nickname = userService.nickname;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: CozeSpacing.lg, vertical: CozeSpacing.md),
      child: Row(
        children: [
          // Avatar with red dot
          GestureDetector(
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => const ProfilePage())),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                ClipOval(
                  child: avatarFile != null
                    ? Image.file(avatarFile, width: 40, height: 40, fit: BoxFit.cover)
                    : Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: CozeColors.infoBlue,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(initials,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: CozeFontSize.s16,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ),
                ),
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: CozeColors.error,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: CozeSpacing.md),
          // Username — tap to open profile
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.push(
                  context, MaterialPageRoute(builder: (_) => const ProfilePage())),
              child: Text(
                nickname,
                style: const TextStyle(
                  fontSize: CozeFontSize.s18,
                  fontWeight: FontWeight.bold,
                  color: CozeColors.fgPrimary,
                ),
              ),
            ),
          ),
          // Right icons
          _iconButton(Icons.search, size: 22, onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchPage()));
          }),
          const SizedBox(width: CozeSpacing.sm),
          GestureDetector(
            onTap: () => setState(() => _showCreateMenu = !_showCreateMenu),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                _iconButton(Icons.add_circle_outline, size: 22),
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: CozeColors.error,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: CozeSpacing.sm),
          _iconButton(Icons.chevron_right, size: 22, onTap: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (_) => const ProfilePage()));
          }),
        ],
      ),
    );
  }

  Widget _iconButton(IconData icon, {double size = 24, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(icon, size: size, color: CozeColors.fgDim),
    );
  }

  // ─── Credits Banner ───
  Widget _buildCreditsBanner() {
    return GestureDetector(
      onTap: () => _showCreditsDialog(),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: CozeSpacing.lg, vertical: CozeSpacing.xs),
        padding: const EdgeInsets.symmetric(horizontal: CozeSpacing.md, vertical: CozeSpacing.sm),
        decoration: BoxDecoration(
          color: CozeColors.lightOrange,
          borderRadius: CozeRadius.xlBorder,
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, size: 16, color: CozeColors.fgDim),
            const SizedBox(width: CozeSpacing.sm),
            const Text('1,500',
                style: TextStyle(
                    fontSize: CozeFontSize.s14,
                    fontWeight: FontWeight.w600,
                    color: CozeColors.fgPrimary)),
            const Spacer(),
            const Text('升级享受更多权益',
                style: TextStyle(fontSize: CozeFontSize.s14, color: CozeColors.fgDim)),
            const Icon(Icons.chevron_right, size: 18, color: CozeColors.fgDim),
          ],
        ),
      ),
    );
  }

  void _showCreditsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('积分详情',
            style: TextStyle(fontSize: CozeFontSize.s18, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: CozeSpacing.sm),
            _creditRow('当前积分', '1,500'),
            _creditRow('每日赠送', '100'),
            _creditRow('本月已使用', '2,300'),
            const SizedBox(height: CozeSpacing.md),
            Container(
              padding: const EdgeInsets.all(CozeSpacing.md),
              decoration: BoxDecoration(
                color: CozeColors.lightOrange,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.star, size: 20, color: CozeColors.warning),
                  SizedBox(width: CozeSpacing.sm),
                  Expanded(
                    child: Text('升级Pro享受无限积分',
                        style: TextStyle(fontSize: CozeFontSize.s14, color: CozeColors.fgPrimary)),
                  ),
                  Text('¥99/月',
                      style: TextStyle(
                          fontSize: CozeFontSize.s14,
                          fontWeight: FontWeight.bold,
                          color: CozeColors.brand5)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('知道了', style: TextStyle(color: CozeColors.fgDim)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('功能开发中'), duration: Duration(seconds: 1)),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: CozeColors.brand5,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('升级'),
          ),
        ],
      ),
    );
  }

  Widget _creditRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: CozeFontSize.s14, color: CozeColors.fgDim)),
          Text(value,
              style: const TextStyle(
                  fontSize: CozeFontSize.s14,
                  fontWeight: FontWeight.w600,
                  color: CozeColors.fgPrimary)),
        ],
      ),
    );
  }

  // ─── Quick Action Buttons (horizontal scroll) ───
  Widget _buildQuickActions() {
    final actions = [
      _ActionData(Icons.chat_bubble_outline, '项目', () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const ProjectPage()));
      }),
      _ActionData(Icons.devices, '设备', () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const DevicePage()));
      }),
      _ActionData(Icons.auto_awesome, '技能', () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const SkillStorePage()));
      }),
      _ActionData(Icons.public, 'World', () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const WorldPage()));
      }),
      _ActionData(Icons.history, '历史对话', () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryPage()));
      }),
    ];

    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: CozeSpacing.lg),
        itemCount: actions.length,
        separatorBuilder: (_, __) => const SizedBox(width: CozeSpacing.sm),
        itemBuilder: (context, index) {
          final a = actions[index];
          return GestureDetector(
            onTap: a.onTap,
            child: Container(
              width: 70,
              height: 80,
              decoration: BoxDecoration(
                color: CozeColors.chipGray,
                borderRadius: CozeRadius.xxlBorder,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(a.icon, size: 24, color: CozeColors.fgSecondary),
                  const SizedBox(height: CozeSpacing.sm + 2),
                  Text(a.label,
                      style: const TextStyle(fontSize: CozeFontSize.s12, color: CozeColors.fgDim),
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ─── Chat List ───
  Widget _buildChatList() {
    return Stack(
      children: [
        ListView.separated(
          padding: const EdgeInsets.only(top: CozeSpacing.sm, bottom: CozeSpacing.lg),
          itemCount: _chatList.length,
          separatorBuilder: (_, __) => const SizedBox(height: CozeSpacing.xs),
          itemBuilder: (context, index) => _buildChatItem(_chatList[index]),
        ),
        // Create menu overlay
        if (_showCreateMenu) ...[
          GestureDetector(
            onTap: () => setState(() => _showCreateMenu = false),
            child: Container(color: Colors.transparent),
          ),
          Positioned(
            top: 0,
            right: CozeSpacing.lg,
            child: _buildCreateMenu(),
          ),
        ],
      ],
    );
  }

  Widget _buildChatItem(ChatListItem item) {
    return GestureDetector(
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (_) => ChatPage(agentName: item.name))),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: CozeSpacing.lg),
        padding: const EdgeInsets.all(CozeSpacing.md),
        decoration: BoxDecoration(
          color: CozeColors.chipGray,
          borderRadius: CozeRadius.xlBorder,
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: CozeColors.bgSecondary,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Center(child: Text(item.avatar, style: const TextStyle(fontSize: 22))),
            ),
            const SizedBox(width: CozeSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(item.name,
                            style: const TextStyle(
                                fontSize: CozeFontSize.s16,
                                fontWeight: FontWeight.bold,
                                color: CozeColors.fgPrimary),
                            overflow: TextOverflow.ellipsis),
                      ),
                      Text(item.time,
                          style: const TextStyle(
                              fontSize: CozeFontSize.s12, color: CozeColors.dimText)),
                    ],
                  ),
                  const SizedBox(height: CozeSpacing.xs),
                  Text(item.preview,
                      style: const TextStyle(fontSize: CozeFontSize.s14, color: CozeColors.fgDim),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Create Menu (popup) ───
  Widget _buildCreateMenu() {
    final menuItems = [
      _MenuItem(Icons.chat_bubble_outline, '新建会话', Icons.add, () {
        setState(() => _showCreateMenu = false);
        // 创建新的 ChatListItem
        final newItem = ChatListItem(
          avatar: '💬',
          name: '新会话',
          preview: '刚刚创建的会话',
          time: '刚刚',
        );
        // 添加到列表顶部
        setState(() {
          _chatList.insert(0, newItem);
        });
        // 导航到聊天页面
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ChatPage(agentName: '新会话')),
        );
      }),
      _MenuItem(Icons.code, '新建编程项目', null, () {
        setState(() => _showCreateMenu = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('功能开发中，敬请期待'), duration: Duration(seconds: 1)),
        );
      }),
      _MenuItem(Icons.movie_outlined, '新建视频项目', null, () {
        setState(() => _showCreateMenu = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('功能开发中，敬请期待'), duration: Duration(seconds: 1)),
        );
      }),
      _MenuItem(Icons.smart_toy_outlined, '新建Agent', null, () {
        setState(() => _showCreateMenu = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('功能开发中，敬请期待'), duration: Duration(seconds: 1)),
        );
      }),
    ];

    return Container(
      width: 200,
      margin: const EdgeInsets.only(top: 50),
      decoration: BoxDecoration(
        color: CozeColors.bgMax,
        borderRadius: CozeRadius.xlBorder,
        boxShadow: CozeShadow.defaultShadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: menuItems
            .map((m) => ListTile(
                  leading: Icon(m.icon, size: 24, color: CozeColors.fgSecondary),
                  title: Text(m.label,
                      style: const TextStyle(
                          fontSize: CozeFontSize.s16, color: CozeColors.fgPrimary)),
                  trailing: m.trailingIcon != null
                      ? Icon(m.trailingIcon, size: 18, color: CozeColors.dimText)
                      : null,
                  onTap: m.onTap,
                ))
            .toList(),
      ),
    );
  }
}

class _ActionData {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionData(this.icon, this.label, this.onTap);
}

class _MenuItem {
  final IconData icon;
  final String label;
  final IconData? trailingIcon;
  final VoidCallback onTap;
  const _MenuItem(this.icon, this.label, this.trailingIcon, this.onTap);
}
