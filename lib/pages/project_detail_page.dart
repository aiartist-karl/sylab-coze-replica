import 'package:flutter/material.dart';
import '../theme/coze_colors.dart';
import '../theme/coze_theme.dart';

// ─── File Model ───

class ProjectFile {
  final String name;
  final FileType type;
  final String size;
  final String lastModified;

  const ProjectFile({
    required this.name,
    required this.type,
    required this.size,
    required this.lastModified,
  });
}

enum FileType { folder, image, document, code, other }

IconData _fileIcon(FileType t) {
  switch (t) {
    case FileType.folder: return Icons.folder_outlined;
    case FileType.image: return Icons.image_outlined;
    case FileType.document: return Icons.description_outlined;
    case FileType.code: return Icons.code_outlined;
    case FileType.other: return Icons.insert_drive_file_outlined;
  }
}

Color _fileColor(FileType t) {
  switch (t) {
    case FileType.folder: return const Color(0xFFFFC107);
    case FileType.image: return CozeColors.infoBlue;
    case FileType.document: return CozeColors.brand5;
    case FileType.code: return CozeColors.success;
    case FileType.other: return CozeColors.fgDim;
  }
}

// ─── Mock Data ───

List<ProjectFile> _mockFiles = [
  const ProjectFile(name: 'images', type: FileType.folder, size: '114 items', lastModified: '2026-08-07'),
  const ProjectFile(name: 'docs', type: FileType.folder, size: '3 items', lastModified: '2026-08-06'),
  const ProjectFile(name: 'coze_design_system_complete.dart', type: FileType.code, size: '12.4 KB', lastModified: '2026-08-07'),
  const ProjectFile(name: 'UI分析截图.PNG', type: FileType.image, size: '2.1 MB', lastModified: '2026-08-07'),
  const ProjectFile(name: '项目需求文档.docx', type: FileType.document, size: '156 KB', lastModified: '2026-08-06'),
  const ProjectFile(name: 'chat_page.dart', type: FileType.code, size: '8.7 KB', lastModified: '2026-08-07'),
  const ProjectFile(name: 'home_page.dart', type: FileType.code, size: '6.2 KB', lastModified: '2026-08-07'),
  const ProjectFile(name: 'build.yml', type: FileType.code, size: '1.8 KB', lastModified: '2026-08-06'),
];

// ─── Page ───

class ProjectDetailPage extends StatefulWidget {
  final String projectName;
  final String projectDescription;

  const ProjectDetailPage({
    super.key,
    required this.projectName,
    required this.projectDescription,
  });

  @override
  State<ProjectDetailPage> createState() => _ProjectDetailPageState();
}

class _ProjectDetailPageState extends State<ProjectDetailPage> {
  late List<ProjectFile> _files;
  bool _showFoldersFirst = true;

  @override
  void initState() {
    super.initState();
    _files = List<ProjectFile>.from(_mockFiles);
  }

  List<ProjectFile> get _sortedFiles {
    if (!_showFoldersFirst) return _files;
    final folders = _files.where((f) => f.type == FileType.folder).toList();
    final others = _files.where((f) => f.type != FileType.folder).toList();
    return [...folders, ...others];
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.projectName,
                style: const TextStyle(
                    fontSize: CozeFontSize.s18,
                    fontWeight: FontWeight.bold,
                    color: CozeColors.fgPrimary)),
            Text(widget.projectDescription,
                style: const TextStyle(fontSize: CozeFontSize.s12, color: CozeColors.fgDim)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file, size: 22, color: CozeColors.brand5),
            onPressed: _showUploadDialog,
            tooltip: '上传文件',
          ),
          IconButton(
            icon: const Icon(Icons.more_horiz, size: 22, color: CozeColors.fgDim),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // File count header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: CozeSpacing.lg, vertical: CozeSpacing.md),
            child: Row(
              children: [
                const Text('全部文件',
                    style: TextStyle(
                        fontSize: CozeFontSize.s16,
                        fontWeight: FontWeight.bold,
                        color: CozeColors.fgPrimary)),
                const SizedBox(width: CozeSpacing.sm),
                Text('${_files.length} 项',
                    style: const TextStyle(fontSize: CozeFontSize.s14, color: CozeColors.dimText)),
                const Spacer(),
                // Sort toggle
                GestureDetector(
                  onTap: () => setState(() => _showFoldersFirst = !_showFoldersFirst),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_showFoldersFirst ? Icons.folder_outlined : Icons.sort,
                          size: 16, color: CozeColors.fgDim),
                      const SizedBox(width: 4),
                      Text(_showFoldersFirst ? '文件夹优先' : '按名称',
                          style: const TextStyle(fontSize: CozeFontSize.s12, color: CozeColors.fgDim)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: CozeColors.strokePrimary),
          // File list
          Expanded(
            child: _sortedFiles.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.folder_off_outlined, size: 56, color: CozeColors.fgDim),
                        const SizedBox(height: CozeSpacing.lg),
                        const Text('暂无文件',
                            style: TextStyle(fontSize: CozeFontSize.s16, color: CozeColors.fgDim)),
                        const SizedBox(height: CozeSpacing.sm),
                        GestureDetector(
                          onTap: _showUploadDialog,
                          child: const Text('上传文件',
                              style: TextStyle(fontSize: CozeFontSize.s14, color: CozeColors.brand5)),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: CozeSpacing.sm),
                    itemCount: _sortedFiles.length,
                    separatorBuilder: (_, __) => Divider(
                        height: 1,
                        indent: CozeSpacing.lg + 40 + CozeSpacing.md,
                        color: CozeColors.strokePrimary),
                    itemBuilder: (context, index) => _buildFileItem(_sortedFiles[index]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileItem(ProjectFile file) {
    return GestureDetector(
      onTap: () => _onFileTap(file),
      onLongPress: () => _showFileOptions(file),
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: CozeSpacing.lg, vertical: CozeSpacing.md),
        child: Row(
          children: [
            // Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _fileColor(file.type).withOpacity(0.12),
                borderRadius: CozeRadius.lgBorder,
              ),
              child: Icon(_fileIcon(file.type), size: 22, color: _fileColor(file.type)),
            ),
            const SizedBox(width: CozeSpacing.md),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(file.name,
                      style: const TextStyle(
                          fontSize: CozeFontSize.s14,
                          fontWeight: FontWeight.w500,
                          color: CozeColors.fgPrimary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(file.size,
                          style: const TextStyle(fontSize: CozeFontSize.s12, color: CozeColors.dimText)),
                      Text(' · ${file.lastModified}',
                          style: const TextStyle(fontSize: CozeFontSize.s12, color: CozeColors.dimText)),
                    ],
                  ),
                ],
              ),
            ),
            // More button
            GestureDetector(
              onTap: () => _showFileOptions(file),
              child: const Icon(Icons.more_vert, size: 20, color: CozeColors.fgDim),
            ),
          ],
        ),
      ),
    );
  }

  void _onFileTap(ProjectFile file) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(file.type == FileType.folder
            ? '打开文件夹: ${file.name}'
            : '预览文件: ${file.name}'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _showFileOptions(ProjectFile file) {
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
            Padding(
              padding: const EdgeInsets.symmetric(vertical: CozeSpacing.md),
              child: Text(file.name,
                  style: const TextStyle(
                      fontSize: CozeFontSize.s14,
                      fontWeight: FontWeight.bold,
                      color: CozeColors.fgPrimary)),
            ),
            Divider(height: 1, color: CozeColors.strokePrimary),
            ListTile(
              leading: const Icon(Icons.download_outlined, size: 22, color: CozeColors.fgSecondary),
              title: const Text('下载', style: TextStyle(fontSize: CozeFontSize.s16)),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('下载中...'), duration: Duration(seconds: 1)),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.share_outlined, size: 22, color: CozeColors.fgSecondary),
              title: const Text('分享', style: TextStyle(fontSize: CozeFontSize.s16)),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.drive_file_rename_outline, size: 22, color: CozeColors.fgSecondary),
              title: const Text('重命名', style: TextStyle(fontSize: CozeFontSize.s16)),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, size: 22, color: CozeColors.error),
              title: const Text('删除', style: TextStyle(fontSize: CozeFontSize.s16, color: CozeColors.error)),
              onTap: () {
                setState(() => _files.removeWhere((f) => f.name == file.name));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('已删除 ${file.name}'),
                    action: SnackBarAction(
                      label: '撤销',
                      textColor: CozeColors.brand5,
                      onPressed: () => setState(() => _files.add(file)),
                    ),
                    duration: const Duration(seconds: 3),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showUploadDialog() {
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
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: CozeColors.brand5.withOpacity(0.08),
                borderRadius: CozeRadius.xxlBorder,
              ),
              child: const Icon(Icons.cloud_upload_outlined, size: 32, color: CozeColors.brand5),
            ),
            const SizedBox(height: CozeSpacing.lg),
            const Text('上传文件到此项目',
                style: TextStyle(
                    fontSize: CozeFontSize.s18,
                    fontWeight: FontWeight.bold,
                    color: CozeColors.fgPrimary)),
            const SizedBox(height: CozeSpacing.sm),
            const Text('支持图片、文档、代码等文件',
                style: TextStyle(fontSize: CozeFontSize.s14, color: CozeColors.fgDim)),
            const SizedBox(height: CozeSpacing.xl),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('功能开发中，敬请期待'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
                icon: const Icon(Icons.file_upload_outlined),
                label: const Text('选择文件', style: TextStyle(fontSize: CozeFontSize.s16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: CozeColors.brand5,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: CozeRadius.xlBorder),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: CozeSpacing.md),
          ],
        ),
      ),
    );
  }
}
