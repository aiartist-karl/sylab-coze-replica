import 'package:flutter/material.dart';
import '../theme/coze_colors.dart';
import '../theme/coze_theme.dart';
import '../models/project_item.dart';
import 'project_detail_page.dart';

/// 项目列表页 — 每个会话 = 一个项目工作空间
/// 卡片显示：项目名称、描述、最近文件预览、最后活跃时间
class ProjectPage extends StatefulWidget {
  const ProjectPage({super.key});
  @override
  State<ProjectPage> createState() => _ProjectPageState();
}

class _ProjectPageState extends State<ProjectPage> {
  List<ProjectItem> _projects = List<ProjectItem>.from(mockProjectList);

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
            icon: const Icon(Icons.search, size: 22, color: CozeColors.fgDim),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // 统计栏
          _buildStatsBar(),
          // 项目列表
          Expanded(child: _buildProjectList()),
          // 底部创建按钮
          _buildCreateButton(),
        ],
      ),
    );
  }

  // ─── Stats Bar ───
  Widget _buildStatsBar() {
    final totalFiles = _projects.fold<int>(0, (sum, p) => sum + p.files.length);
    return Container(
      margin: const EdgeInsets.fromLTRB(CozeSpacing.lg, 0, CozeSpacing.lg, CozeSpacing.sm),
      padding: const EdgeInsets.symmetric(horizontal: CozeSpacing.lg, vertical: CozeSpacing.md),
      decoration: BoxDecoration(
        color: CozeColors.chipGray,
        borderRadius: CozeRadius.xlBorder,
      ),
      child: Row(
        children: [
          _statItem('${_projects.length}', '个项目'),
          Container(width: 1, height: 20, color: CozeColors.separator),
          _statItem('$totalFiles', '个文件'),
          Container(width: 1, height: 20, color: CozeColors.separator),
          _statItem(_projects.where((p) => p.lastActiveTime.contains('小时')).length.toString(), '个活跃'),
        ],
      ),
    );
  }

  Widget _statItem(String num, String label) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(num,
              style: const TextStyle(
                  fontSize: CozeFontSize.s18,
                  fontWeight: FontWeight.bold,
                  color: CozeColors.fgPrimary)),
          const SizedBox(width: 4),
          Text(label,
              style: const TextStyle(fontSize: CozeFontSize.s12, color: CozeColors.fgDim)),
        ],
      ),
    );
  }

  // ─── Project List ───
  Widget _buildProjectList() {
    if (_projects.isEmpty) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.folder_off_outlined, size: 56, color: CozeColors.fgDim),
          const SizedBox(height: CozeSpacing.lg),
          const Text('暂无项目',
              style: TextStyle(fontSize: CozeFontSize.s16, color: CozeColors.fgDim)),
          const SizedBox(height: CozeSpacing.sm),
          const Text('点击下方按钮创建第一个项目',
              style: TextStyle(fontSize: CozeFontSize.s14, color: CozeColors.dimText)),
        ]),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: CozeSpacing.lg, vertical: CozeSpacing.sm),
      itemCount: _projects.length,
      separatorBuilder: (_, __) => const SizedBox(height: CozeSpacing.md),
      itemBuilder: (context, index) => _buildProjectCard(_projects[index]),
    );
  }

  // ─── Project Card ───
  Widget _buildProjectCard(ProjectItem project) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ProjectDetailPage(project: project)),
      ),
      child: Container(
        padding: const EdgeInsets.all(CozeSpacing.lg),
        decoration: BoxDecoration(
          color: CozeColors.chipGray,
          borderRadius: CozeRadius.xxlBorder,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top: emoji + name + time
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: CozeColors.bgMax,
                    borderRadius: CozeRadius.xlBorder,
                  ),
                  child: Center(child: Text(project.avatar, style: const TextStyle(fontSize: 22))),
                ),
                const SizedBox(width: CozeSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(project.name,
                          style: const TextStyle(
                              fontSize: CozeFontSize.s16,
                              fontWeight: FontWeight.bold,
                              color: CozeColors.fgPrimary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 2),
                      Text(project.lastActiveTime,
                          style: const TextStyle(fontSize: CozeFontSize.s12, color: CozeColors.dimText)),
                    ],
                  ),
                ),
                // File count badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: CozeColors.bgMax,
                    borderRadius: CozeRadius.pillBorder,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.folder_outlined, size: 12, color: CozeColors.fgDim),
                      const SizedBox(width: 3),
                      Text('${project.files.length} 个文件',
                          style: const TextStyle(fontSize: 11, color: CozeColors.fgDim)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: CozeSpacing.md),
            // Description
            Text(project.description,
                style: const TextStyle(
                    fontSize: CozeFontSize.s14, color: CozeColors.fgDim, height: 1.4),
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
            // Recent files preview
            if (project.files.isNotEmpty) ...[
              const SizedBox(height: CozeSpacing.md),
              _buildRecentFilesRow(project),
            ],
            const SizedBox(height: CozeSpacing.md),
            // Last message preview
            Row(
              children: [
                Icon(Icons.chat_bubble_outline, size: 12, color: CozeColors.dimText),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(project.lastMessage,
                      style: const TextStyle(
                          fontSize: CozeFontSize.s12, color: CozeColors.dimText),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─── Recent Files Row (show first 3 files as chips) ───
  Widget _buildRecentFilesRow(ProjectItem project) {
    final recent = project.recentFiles;
    return SizedBox(
      height: 28,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: recent.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (context, i) {
          final f = recent[i];
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: fileTypeColor(f.type).withOpacity(0.08),
              borderRadius: CozeRadius.pillBorder,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(fileTypeIcon(f.type), size: 12, color: fileTypeColor(f.type)),
                const SizedBox(width: 4),
                Text(f.name,
                    style: TextStyle(fontSize: 11, color: fileTypeColor(f.type)),
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          );
        },
      ),
    );
  }

  // ─── Create Button (bottom) ───
  Widget _buildCreateButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(CozeSpacing.lg, CozeSpacing.sm, CozeSpacing.lg, CozeSpacing.lg),
      child: GestureDetector(
        onTap: () => _showCreateDialog(),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: CozeColors.brand5,
            borderRadius: CozeRadius.xlBorder,
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add, size: 22, color: Colors.white),
              SizedBox(width: CozeSpacing.sm),
              Text('创建项目',
                  style: TextStyle(
                      fontSize: CozeFontSize.s16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Create Dialog ───
  void _showCreateDialog() {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.all(CozeSpacing.lg),
        padding: const EdgeInsets.all(CozeSpacing.xl),
        decoration: BoxDecoration(
          color: CozeColors.bgMax,
          borderRadius: CozeRadius.xxlBorder,
          boxShadow: CozeShadow.defaultShadow,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('创建新项目',
                style: TextStyle(
                    fontSize: CozeFontSize.s18,
                    fontWeight: FontWeight.bold,
                    color: CozeColors.fgPrimary)),
            const SizedBox(height: CozeSpacing.lg),
            TextField(
              controller: controller,
              autofocus: true,
              decoration: InputDecoration(
                hintText: '输入项目名称',
                hintStyle: const TextStyle(color: CozeColors.dimText),
                filled: true,
                fillColor: CozeColors.chipGray,
                border: OutlineInputBorder(
                  borderRadius: CozeRadius.xlBorder,
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: CozeSpacing.lg, vertical: CozeSpacing.md),
              ),
            ),
            const SizedBox(height: CozeSpacing.lg),
            GestureDetector(
              onTap: () {
                final name = controller.text.trim();
                if (name.isNotEmpty) {
                  setState(() {
                    _projects.insert(0, ProjectItem(
                      id: 'p${DateTime.now().millisecondsSinceEpoch}',
                      name: name,
                      description: '新项目 — 开始你的第一个对话吧',
                      avatar: '📁',
                      lastMessage: '刚刚创建',
                      lastActiveTime: '刚刚',
                    ));
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('已创建项目「$name」'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: CozeColors.brand5,
                  borderRadius: CozeRadius.xlBorder,
                ),
                child: const Center(
                  child: Text('创建',
                      style: TextStyle(
                          fontSize: CozeFontSize.s16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
