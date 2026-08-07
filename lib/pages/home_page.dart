import 'package:flutter/material.dart';
import '../theme/coze_colors.dart';
import '../theme/coze_theme.dart';
import '../models/chat_item.dart';
import 'skill_store_page.dart';
import 'device_page.dart';
import 'chat_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _showCreateMenu = false;

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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: CozeSpacing.lg, vertical: CozeSpacing.md),
      child: Row(
        children: [
          // Avatar with red dot
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: CozeColors.infoBlue,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text('冯',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: CozeFontSize.s16,
                          fontWeight: FontWeight.w600)),
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
          const SizedBox(width: CozeSpacing.md),
          // Username only — no "免费版" tag per user request
          const Expanded(
            child: Text(
              '冯包包',
              style: TextStyle(
                fontSize: CozeFontSize.s18,
                fontWeight: FontWeight.bold,
                color: CozeColors.fgPrimary,
              ),
            ),
          ),
          // Right icons
          _iconButton(Icons.search, size: 22),
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
          _iconButton(Icons.chevron_right, size: 22),
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
    return Container(
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
    );
  }

  // ─── Quick Action Buttons (horizontal scroll) ───
  Widget _buildQuickActions() {
    final actions = [
      _ActionData(Icons.chat_bubble_outline, '项目', () {}),
      _ActionData(Icons.devices, '设备',
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DevicePage()))),
      _ActionData(Icons.auto_awesome, '技能',
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SkillStorePage()))),
      _ActionData(Icons.public, 'World', () {}),
      _ActionData(Icons.history, '历史对话', () {}),
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
          itemCount: mockChatList.length,
          separatorBuilder: (_, __) => const SizedBox(height: CozeSpacing.xs),
          itemBuilder: (context, index) => _buildChatItem(mockChatList[index]),
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
      _MenuItem(Icons.chat_bubble_outline, '新建项目', Icons.add),
      _MenuItem(Icons.code, '新建编程项目', null),
      _MenuItem(Icons.movie_outlined, '新建视频项目', null),
      _MenuItem(Icons.smart_toy_outlined, '新建Agent', null),
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
                  onTap: () => setState(() => _showCreateMenu = false),
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
  const _MenuItem(this.icon, this.label, this.trailingIcon);
}
