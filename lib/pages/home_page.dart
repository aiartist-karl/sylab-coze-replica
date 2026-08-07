import 'package:flutter/material.dart';
import '../theme/coze_colors.dart';
import '../theme/coze_theme.dart';
import '../models/project_item.dart';
import '../widgets/coze_dialog.dart';
import 'skill_store_page.dart';
import 'chat_page.dart';
import 'search_page.dart';
import 'project_page.dart';
import 'project_detail_page.dart';
import 'profile_page.dart';
import 'memory_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey _createBtnKey = GlobalKey();
  OverlayEntry? _menuOverlay;
  late List<ProjectItem> _chatList;

  @override
  void initState() {
    super.initState();
    _chatList = List<ProjectItem>.from(mockProjectList);
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

  // ─── User Info Bar ───
  Widget _buildUserBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: CozeSpacing.lg, vertical: CozeSpacing.md),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.push(
                context, cozeFadeRoute( (_) => const ProfilePage())),
            child: Stack(
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
          ),
          const SizedBox(width: CozeSpacing.md),
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

  // ─── Quick Action Buttons ───
  Widget _buildQuickActions() {
    final actions = [
      _ActionData(Icons.chat_bubble_outline, '项目', () {
        Navigator.push(context, cozeFadeRoute( (_) => const ProjectPage()));
      }),
      _ActionData(Icons.person_outline, '我的', () {
        Navigator.push(context, cozeFadeRoute( (_) => const ProfilePage()));
      }),
      _ActionData(Icons.memory, '记忆', () {
        Navigator.push(context, cozeFadeRoute( (_) => const MemoryPage()));
      }),
      _ActionData(Icons.auto_awesome, '技能', () {
        Navigator.push(context, cozeFadeRoute( (_) => const SkillStorePage()));
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

  // ─── Chat List (sessions = projects) ───
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

  // ─── Dismissible wrapper ───
  Widget _buildDismissibleChatItem(int index) {
    final item = _chatList[index];
    return Dismissible(
      key: ValueKey('chat_${item.id}_$index'),
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
        return await CozeDialog.showConfirm(
          context,
          title: '删除对话',
          content: '确定删除与「${item.name}」的对话记录吗？',
          confirmText: '删除',
          cancelText: '取消',
          isDestructive: true,
        );
      },
      onDismissed: (direction) {
        setState(() => _chatList.removeAt(index));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('已删除与「${item.name}」的对话'),
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: '撤销',
              textColor: CozeColors.brand5,
              onPressed: () => setState(() => _chatList.insert(index, item)),
            ),
          ),
        );
      },
      child: _buildChatItem(item),
    );
  }

  // ─── Chat Item Card ───
  Widget _buildChatItem(ProjectItem item) {
    return GestureDetector(
      onTap: () => Navigator.push(
          context, cozeFadeRoute( (_) => ChatPage(agentName: item.name, project: item))),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: CozeSpacing.lg),
        padding: const EdgeInsets.all(CozeSpacing.md),
        decoration: BoxDecoration(
          color: CozeColors.chipGray,
          borderRadius: CozeRadius.xlBorder,
        ),
        child: Row(
          children: [
            // Avatar
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
            // Content
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
                      Text(item.lastActiveTime,
                          style: const TextStyle(
                              fontSize: CozeFontSize.s12, color: CozeColors.dimText)),
                    ],
                  ),
                  const SizedBox(height: CozeSpacing.xs),
                  Text(item.lastMessage,
                      style: const TextStyle(fontSize: CozeFontSize.s14, color: CozeColors.fgDim),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  // File count indicator
                  if (item.files.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Icon(Icons.folder_outlined, size: 11, color: CozeColors.dimText),
                        const SizedBox(width: 3),
                        Text(item.totalFileCount,
                            style: const TextStyle(fontSize: 11, color: CozeColors.dimText)),
                        const SizedBox(width: 6),
                        ...item.recentFiles.take(3).map((f) => Padding(
                          padding: const EdgeInsets.only(right: 3),
                          child: Icon(fileTypeIcon(f.type), size: 10, color: fileTypeColor(f.type)),
                        )),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: CozeSpacing.sm),
            // File management button — tap to view project files
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                cozeFadeRoute( (_) => ProjectDetailPage(project: item)),
              ),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: CozeColors.bgMax,
                  borderRadius: CozeRadius.xlBorder,
                ),
                child: Icon(Icons.folder_outlined, size: 18, color: CozeColors.fgDim),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Create Menu ───
  Widget _buildCreateMenu() {
    void dismissAndToast(String msg) {
      _dismissMenu();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), duration: const Duration(seconds: 1)),
      );
    }

    final menuItems = [
      _MenuItem(Icons.chat_bubble_outline, '新建会话', Icons.add,
          () {
            _dismissMenu();
            Navigator.push(
              context,
              cozeFadeRoute(
                (_) => const ChatPage(agentName: '新会话'),
              ),
            );
          }),
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
    final menuEstHeight = 220.0;
    final margin = 8.0;

    double left = anchorRect.right - menuWidth;
    if (left < margin) left = margin;

    double top = anchorRect.bottom + margin;
    if (top + menuEstHeight > screenSize.height - margin) {
      top = anchorRect.top - menuEstHeight - margin;
      if (top < margin) top = margin;
    }

    return Stack(
      children: [
        GestureDetector(
          onTap: onDismiss,
          child: Container(color: Colors.transparent),
        ),
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
