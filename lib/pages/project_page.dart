import 'package:flutter/material.dart';
import '../theme/coze_colors.dart';
import '../theme/coze_theme.dart';
import 'project_detail_page.dart';

// ─── Data Model: Each project = one chat session with file storage ───

enum ProjectType { chat, code, video, agent }

class ProjectItem {
  final String name;
  final String description;
  final ProjectType type;
  final String lastUpdated;
  final int fileCount;
  final String recentFiles; // e.g. "design.dart, screenshots.png"
  final String emoji;

  const ProjectItem({
    required this.name,
    required this.description,
    required this.type,
    required this.lastUpdated,
    required this.fileCount,
    required this.recentFiles,
    required this.emoji,
  });
}

const List<ProjectItem> _mockProjects = [
  ProjectItem(
    name: '扣子App UI复刻工作',
    description: '复刻扣子App的Flutter UI并接入后端API',
    type: ProjectType.code,
    lastUpdated: '2026-08-07',
    fileCount: 118,
    recentFiles: 'coze_design_system_complete.dart, UI截图...',
    emoji: '📱',
  ),
  ProjectItem(
    name: 'AI漫剧项目',
    description: '使用AI生成3D动漫风格的漫剧内容',
    type: ProjectType.video,
    lastUpdated: '2026-08-06',
    fileCount: 45,
    recentFiles: 'scene_01.png, storyboard.md...',
    emoji: '🎬',
  ),
  ProjectItem(
    name: '智能客服助手',
    description: '基于大模型的客服对话系统',
    type: ProjectType.chat,
    lastUpdated: '2026-08-05',
    fileCount: 12,
    recentFiles: 'faq_data.json, response_templates...',
    emoji: '💬',
  ),
  ProjectItem(
    name: '数据分析Agent',
    description: '自动化数据分析与报表生成的Agent',
    type: ProjectType.agent,
    lastUpdated: '2026-08-04',
    fileCount: 28,
    recentFiles: 'analysis_pipeline.py, report_template...',
    emoji: '🤖',
  ),
  ProjectItem(
    name: '周报自动生成',
    description: '根据每日工作记录自动汇总生成周报',
    type: ProjectType.chat,
    lastUpdated: '2026-08-01',
    fileCount: 7,
    recentFiles: 'week31_report.docx, tasks_log...',
    emoji: '📝',
  ),
];

const List<String> _filterTabs = ['全部', '对话', '编程', '视频', 'Agent'];

ProjectType? _filterToType(int index) {
  switch (index) {
    case 1: return ProjectType.chat;
    case 2: return ProjectType.code;
    case 3: return ProjectType.video;
    case 4: return ProjectType.agent;
    default: return null;
  }
}

IconData _typeIcon(ProjectType t) {
  switch (t) {
    case ProjectType.chat: return Icons.chat_bubble_outline;
    case ProjectType.code: return Icons.code;
    case ProjectType.video: return Icons.movie_outlined;
    case ProjectType.agent: return Icons.smart_toy_outlined;
  }
}

String _typeName(ProjectType t) {
  switch (t) {
    case ProjectType.chat: return '对话';
    case ProjectType.code: return '编程';
    case ProjectType.video: return '视频';
    case ProjectType.agent: return 'Agent';
  }
}

// ─── Page ───

class ProjectPage extends StatefulWidget {
  const ProjectPage({super.key});
  @override
  State<ProjectPage> createState() => _ProjectPageState();
}

class _ProjectPageState extends State<ProjectPage> {
  int _selectedFilter = 0;

  List<ProjectItem> get _filtered {
    final t = _filterToType(_selectedFilter);
    if (t == null) return _mockProjects;
    return _mockProjects.where((p) => p.type == t).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CozeColors.bgMax,
      appBar: AppBar(
        backgroundColor: CozeColors.bgMax,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20, color: CozeColors.fgPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('项目',
            style: TextStyle(
                fontSize: CozeFontSize.s18,
                fontWeight: FontWeight.bold,
                color: CozeColors.fgPrimary)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, size: 22, color: CozeColors.brand5),
            onPressed: () => _showCreateDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(child: _buildProjectList()),
        ],
      ),
    );
  }

  // ─── Filter Tabs ───
  Widget _buildFilterBar() {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: CozeSpacing.lg),
        itemCount: _filterTabs.length,
        separatorBuilder: (_, __) => const SizedBox(width: CozeSpacing.sm),
        itemBuilder: (context, index) {
          final isSelected = _selectedFilter == index;
          final count = index == 0
              ? _mockProjects.length
              : _mockProjects.where((p) => p.type == _filterToType(index)).length;
          return GestureDetector(
            onTap: () => setState(() => _selectedFilter = index),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: CozeSpacing.lg, vertical: CozeSpacing.sm),
              decoration: BoxDecoration(
                color: isSelected ? CozeColors.tagDark : CozeColors.bgMax,
                borderRadius: CozeRadius.pillBorder,
                border: isSelected ? null : Border.all(color: CozeColors.strokePrimary),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_filterTabs[index],
                      style: TextStyle(
                          fontSize: CozeFontSize.s14,
                          color: isSelected ? Colors.white : CozeColors.fgPrimary,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal)),
                  const SizedBox(width: 4),
                  Text('$count',
                      style: TextStyle(
                          fontSize: CozeFontSize.s12,
                          color: isSelected ? Colors.white.withOpacity(0.7) : CozeColors.dimText)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ─── Project List ───
  Widget _buildProjectList() {
    final projects = _filtered;
    if (projects.isEmpty) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.folder_off_outlined, size: 56, color: CozeColors.fgDim),
          const SizedBox(height: CozeSpacing.lg),
          const Text('暂无此类项目',
              style: TextStyle(fontSize: CozeFontSize.s16, color: CozeColors.fgDim)),
          const SizedBox(height: CozeSpacing.sm),
          GestureDetector(
            onTap: () => setState(() => _selectedFilter = 0),
            child: const Text('查看全部项目',
                style: TextStyle(fontSize: CozeFontSize.s14, color: CozeColors.brand5)),
          ),
        ]),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(CozeSpacing.lg),
      itemCount: projects.length,
      separatorBuilder: (_, __) => const SizedBox(height: CozeSpacing.md),
      itemBuilder: (context, index) => _buildProjectCard(projects[index]),
    );
  }

  // ─── Project Card (workspace style) ───
  Widget _buildProjectCard(ProjectItem project) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProjectDetailPage(
        projectName: project.name,
        projectDescription: project.description,
      ))),
      child: Container(
        padding: const EdgeInsets.all(CozeSpacing.lg),
        decoration: BoxDecoration(
          color: CozeColors.chipGray,
          borderRadius: CozeRadius.xxlBorder,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top: emoji + name + type badge
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: CozeColors.bgMax,
                    borderRadius: CozeRadius.xlBorder,
                  ),
                  child: Center(child: Text(project.emoji, style: const TextStyle(fontSize: 22))),
                ),
                const SizedBox(width: CozeSpacing.md),
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
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                          ),
                          // Type badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: CozeColors.brand5.withOpacity(0.08),
                              borderRadius: CozeRadius.pillBorder,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(_typeIcon(project.type), size: 11, color: CozeColors.brand5),
                                const SizedBox(width: 3),
                                Text(_typeName(project.type),
                                    style: const TextStyle(fontSize: 11, color: CozeColors.brand5)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(project.description,
                          style: const TextStyle(fontSize: CozeFontSize.s12, color: CozeColors.fgDim),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: CozeSpacing.md),
            // File info row
            Container(
              padding: const EdgeInsets.all(CozeSpacing.sm),
              decoration: BoxDecoration(
                color: CozeColors.bgMax,
                borderRadius: CozeRadius.lgBorder,
              ),
              child: Row(
                children: [
                  Icon(Icons.folder_outlined, size: 16, color: CozeColors.fgDim),
                  const SizedBox(width: 6),
                  Text('${project.fileCount} 个文件',
                      style: const TextStyle(
                          fontSize: CozeFontSize.s12,
                          fontWeight: FontWeight.w500,
                          color: CozeColors.fgSecondary)),
                  const SizedBox(width: CozeSpacing.md),
                  Expanded(
                    child: Text(project.recentFiles,
                        style: const TextStyle(fontSize: CozeFontSize.s11, color: CozeColors.dimText),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
            ),
            const SizedBox(height: CozeSpacing.sm),
            // Bottom: last updated
            Row(
              children: [
                const Icon(Icons.schedule, size: 14, color: CozeColors.dimText),
                const SizedBox(width: 4),
                Text('更新于 ${project.lastUpdated}',
                    style: const TextStyle(fontSize: CozeFontSize.s12, color: CozeColors.dimText)),
                const Spacer(),
                const Icon(Icons.chevron_right, size: 18, color: CozeColors.dimText),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─── Create Dialog ───
  void _showCreateDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.all(CozeSpacing.lg),
        padding: const EdgeInsets.symmetric(vertical: CozeSpacing.md),
        decoration: BoxDecoration(
          color: CozeColors.bgMax,
          borderRadius: CozeRadius.xxlBorder,
          boxShadow: CozeShadow.defaultShadow,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: CozeSpacing.md),
              child: Text('新建项目',
                  style: TextStyle(
                      fontSize: CozeFontSize.s16,
                      fontWeight: FontWeight.bold,
                      color: CozeColors.fgPrimary)),
            ),
            Divider(height: 1, color: CozeColors.strokePrimary),
            _createItem(Icons.chat_bubble_outline, '对话项目', '创建智能对话或聊天机器人', () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('功能开发中，敬请期待'), duration: Duration(seconds: 1)),
              );
            }),
            _createItem(Icons.code, '编程项目', '编写代码或搭建应用', () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('功能开发中，敬请期待'), duration: Duration(seconds: 1)),
              );
            }),
            _createItem(Icons.movie_outlined, '视频项目', 'AI视频创作和编辑', () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('功能开发中，敬请期待'), duration: Duration(seconds: 1)),
              );
            }),
            _createItem(Icons.smart_toy_outlined, 'Agent项目', '构建自定义AI Agent', () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('功能开发中，敬请期待'), duration: Duration(seconds: 1)),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _createItem(IconData icon, String title, String desc, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: CozeColors.brand5.withOpacity(0.08),
          borderRadius: CozeRadius.xlBorder,
        ),
        child: Icon(icon, size: 22, color: CozeColors.brand5),
      ),
      title: Text(title, style: const TextStyle(fontSize: CozeFontSize.s16, color: CozeColors.fgPrimary)),
      subtitle: Text(desc, style: const TextStyle(fontSize: CozeFontSize.s12, color: CozeColors.fgDim)),
      trailing: const Icon(Icons.chevron_right, size: 20, color: CozeColors.dimText),
      onTap: onTap,
    );
  }
}
