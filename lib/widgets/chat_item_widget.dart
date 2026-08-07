import 'package:flutter/material.dart';
import '../theme/coze_colors.dart';
import '../theme/coze_theme.dart';
import '../models/project_item.dart';
import 'project_detail_page.dart';

/// 会话 + 文件入口卡片
/// 首页聊天列表中每个会话项：点击进入对话，点文件夹按钮进入文件管理
class ChatItemWidget extends StatelessWidget {
  final ProjectItem project;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const ChatItemWidget({
    super.key,
    required this.project,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey('chat_${project.id}'),
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
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text('删除对话', style: TextStyle(fontWeight: FontWeight.bold)),
            content: Text('确定删除与「${project.name}」的对话记录吗？'),
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
      onDismissed: (_) => onDelete(),
      child: GestureDetector(
        onTap: onTap,
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
                child: Center(child: Text(project.avatar, style: const TextStyle(fontSize: 22))),
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
                          child: Text(project.name,
                              style: const TextStyle(
                                  fontSize: CozeFontSize.s16,
                                  fontWeight: FontWeight.bold,
                                  color: CozeColors.fgPrimary),
                              overflow: TextOverflow.ellipsis),
                        ),
                        Text(project.lastActiveTime,
                            style: const TextStyle(
                                fontSize: CozeFontSize.s12, color: CozeColors.dimText)),
                      ],
                    ),
                    const SizedBox(height: CozeSpacing.xs),
                    Text(project.lastMessage,
                        style: const TextStyle(fontSize: CozeFontSize.s14, color: CozeColors.fgDim),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    // File count indicator
                    if (project.files.isNotEmpty) ...[
                      const SizedBox(height: CozeSpacing.xs),
                      Row(
                        children: [
                          Icon(Icons.folder_outlined, size: 11, color: CozeColors.dimText),
                          const SizedBox(width: 3),
                          Text(project.totalFileCount,
                              style: const TextStyle(fontSize: CozeFontSize.s12, color: CozeColors.dimText)),
                          const SizedBox(width: CozeSpacing.sm),
                          ...project.recentFiles.take(2).map((f) => Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Icon(fileTypeIcon(f.type), size: 10, color: fileTypeColor(f.type)),
                          )),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: CozeSpacing.sm),
              // File management button
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ProjectDetailPage(project: project)),
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
      ),
    );
  }
}
