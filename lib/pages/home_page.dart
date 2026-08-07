import 'package:flutter/material.dart';
import '../theme/coze_colors.dart';
import '../theme/coze_theme.dart';
import '../models/chat_item.dart';
import 'skill_store_page.dart';
import 'chat_page.dart';
import 'search_page.dart';
import 'project_page.dart';
import 'profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey _createBtnKey = GlobalKey();
  OverlayEntry? _menuOverlay;
  late List<ChatListItem> _chatList;

  @override
  void initState() {
    super.initState();
    _chatList = List<ChatListItem>.from(mockChatList);
  }

  @override
  void dispose() {
    _dismissMenu();
    super.dispose();
  }

  // ─── Create menu: show/dismiss via Overlay ───
  void _toggleCreateMenu() {
    if (_menuOverlay != null) {
      _dismissMenu();
      return;
    }
    final renderBox = _createBtnKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final btnRect = renderBox.localToGlobal(Offset.zero) & renderBox.size;
    _showMenuAt(btnRect);
  }

  void _showMenuAt(Rect btnRect) {
    _menuOverlay = OverlayEntry(
      builder: (context) => _OverlayMenu(
        anchorRect: btnRect,
        menuBuilder: _buildCreateMenu,
        onDismiss: _dismissMenu,
      ),
    );
    Overlay.of(context).insert(_menuOverlay!);
  }

  void _dismissMenu() {
    _menuOverlay?.remove();
    _menuOverlay = null;
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
            key: _createBtnKey,
            onTap: _toggleCreateMenu,
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
      _ActionData(Icons.chat_bubble_outline, '项目', () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const ProjectPage()));
      }),
      _ActionData(Icons.person_outline, '我的', () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilePage()));
      }),
      _ActionData(Icons.auto_awesome, '技能', () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const SkillStorePage()));
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
    if (_chatList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline, size: 56, color: CozeColors.fgDim),
            const SizedBox(height: CozeSpacing.lg),
            const Text('暂无对话',
                style: TextStyle(fontSize: CozeFontSize.s16, color: CozeColors.fgDim)),
            const SizedBox(height: CozeSpacing.sm),
            const Text('点击上方Agent开始聊天吧',
                style: TextStyle(fontSize: CozeFontSize.s14, color: CozeColors.dimText)),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.only(top: CozeSpacing.sm, bottom: CozeSpacing.lg),
      itemCount: _chatList.length,
      separatorBuilder: (_, __) => const SizedBox(height: CozeSpacing.xs),
      itemBuilder: (context, index) => _buildDismissibleChatItem(index),
    );
  }

  // ─── Dismissible wrapper for swipe-to-delete ───
  Widget _buildDismissibleChatItem(int index) {
    final item = _chatList[index];
    return Dismissible(
      key: ValueKey('chat_${item.name}_$index'),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.symmetric(horizontal: CozeSpacing.lg),
        decoration: BoxDecoration(
          color: CozeColors.error,
          borderRadius: CozeRadius.xlBorder,
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: CozeSpacing.xl),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_outline, color: Colors.white, size: 22),
            SizedBox(height: 4),
            Text('删除',
                style: TextStyle(color: Colors.white, fontSize: CozeFontSize.s12)),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        // Show confirmation dialog
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text('删除对话',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            content: Text('确定删除与「${item.name}」的对话记录吗？'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('取消', style: TextStyle(color: CozeColors.fgDim)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('删除', style: TextStyle(color: CozeColors.error)),
              ),
            ],
          ),
        ) ?? false;
      },
      onDismissed: (direction) {
        setState(() {
          _chatList.removeAt(index);
        });
        // Show undo snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('已删除与「${item.name}」的对话'),
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: '撤销',
              textColor: CozeColors.brand5,
              onPressed: () {
                setState(() {
                  _chatList.insert(index, item);
                });
              },
            ),
          ),
        );
      },
      child: _buildChatItem(item),
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

  // ─── Create Menu (popup content) ───
  Widget _buildCreateMenu() {
    void dismissAndToast(String msg) {
      _dismissMenu();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), duration: const Duration(seconds: 1)),
      );
    }

    final menuItems = [
      _MenuItem(Icons.chat_bubble_outline, '新建项目', Icons.add,
          () => dismissAndToast('功能开发中，敬请期待')),
      _MenuItem(Icons.code, '新建编程项目', null,
          () => dismissAndToast('功能开发中，敬请期待')),
      _MenuItem(Icons.movie_outlined, '新建视频项目', null,
          () => dismissAndToast('功能开发中，敬请期待')),
      _MenuItem(Icons.smart_toy_outlined, '新建Agent', null,
          () => dismissAndToast('功能开发中，敬请期待')),
    ];

    return Container(
      width: 200,
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

/// Overlay widget that positions the menu below the anchor button.
/// Covers the full screen with a transparent backdrop for dismissal.
class _OverlayMenu extends StatelessWidget {
  final Rect anchorRect;
  final Widget Function() menuBuilder;
  final VoidCallback onDismiss;

  const _OverlayMenu({
    required this.anchorRect,
    required this.menuBuilder,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final menuWidth = 200.0;
    final menuEstHeight = 220.0; // approximate
    final margin = 8.0;

    // Position: right-aligned to the anchor button, below it
    double left = anchorRect.right - menuWidth;
    if (left < margin) left = margin;

    double top = anchorRect.bottom + margin;
    // If menu would overflow bottom, show above anchor
    if (top + menuEstHeight > screenSize.height - margin) {
      top = anchorRect.top - menuEstHeight - margin;
      if (top < margin) top = margin;
    }

    return Stack(
      children: [
        // Transparent backdrop — tap to dismiss
        GestureDetector(
          onTap: onDismiss,
          child: Container(color: Colors.transparent),
        ),
        // Positioned menu
        Positioned(
          left: left,
          top: top,
          child: Material(
            color: Colors.transparent,
            child: menuBuilder(),
          ),
        ),
      ],
    );
  }
}
