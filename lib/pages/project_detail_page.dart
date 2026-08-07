import 'package:flutter/material.dart';
import '../theme/coze_colors.dart';
import '../theme/coze_theme.dart';
import '../models/project_item.dart';

/// 项目详情页 — 文件管理
/// 显示该项目下所有文件列表，支持文件夹/文件分类视图 + 上传文件
class ProjectDetailPage extends StatefulWidget {
  final ProjectItem project;
  const ProjectDetailPage({super.key, required this.project});
  @override
  State<ProjectDetailPage> createState() => _ProjectDetailPageState();
}

class _ProjectDetailPageState extends State<ProjectDetailPage> {
  late List<ProjectFile> _allFiles;
  bool _isGridView = false;
  FileType? _filterType; // null = all

  @override
  void initState() {
    super.initState();
    _allFiles = List<ProjectFile>.from(widget.project.files);
  }

  List<ProjectFile> get _filteredFiles {
    if (_filterType == null) return _allFiles;
    return _allFiles.where((f) => f.type == _filterType).toList();
  }

  Map<FileType, List<ProjectFile>> get _groupedFiles {
    final map = <FileType, List<ProjectFile>>{};
    for (final f in _filteredFiles) {
      map.putIfAbsent(f.type, () => []).add(f);
    }
    return map;
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
            Text(widget.project.name,
                style: const TextStyle(
                    fontSize: CozeFontSize.s16,
                    fontWeight: FontWeight.bold,
                    color: CozeColors.fgPrimary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            Text('${_allFiles.length} 个文件 · ${widget.project.totalFileCount}',
                style: const TextStyle(fontSize: CozeFontSize.s12, color: CozeColors.dimText)),
          ],
        ),
        actions: [
          // View toggle
          IconButton(
            icon: Icon(
              _isGridView ? Icons.view_list_outlined : Icons.grid_view_outlined,
              size: 22,
              color: CozeColors.fgDim,
            ),
            onPressed: () => setState(() => _isGridView = !_isGridView),
          ),
          // Upload button
          IconButton(
            icon: const Icon(Icons.cloud_upload_outlined, size: 22, color: CozeColors.brand5),
            onPressed: () => _showUploadDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          // File type filter tabs
          _buildFilterTabs(),
          // File list
          Expanded(child: _buildFileContent()),
        ],
      ),
    );
  }

  // ─── Filter Tabs ───
  Widget _buildFilterTabs() {
    final types = _allFiles.map((f) => f.type).toSet().toList();
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: CozeSpacing.lg),
        children: [
          // "全部文件" tab
          _filterChip('全部文件', null, _allFiles.length),
          const SizedBox(width: CozeSpacing.sm),
          // Type-specific tabs
          ...types.map((t) => Padding(
            padding: const EdgeInsets.only(right: CozeSpacing.sm),
            child: _filterChip(
              fileTypeName(t),
              t,
              _allFiles.where((f) => f.type == t).length,
            ),
          )),
        ],
      ),
    );
  }

  Widget _filterChip(String label, FileType? type, int count) {
    final isSelected = _filterType == type;
    return GestureDetector(
      onTap: () => setState(() => _filterType = type),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: CozeSpacing.md, vertical: CozeSpacing.sm),
        decoration: BoxDecoration(
          color: isSelected ? CozeColors.tagDark : CozeColors.chipGray,
          borderRadius: CozeRadius.pillBorder,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (type != null) ...[
              Icon(fileTypeIcon(type), size: 12,
                  color: isSelected ? Colors.white : fileTypeColor(type)),
              const SizedBox(width: 4),
            ],
            Text(label,
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
  }

  // ─── File Content ───
  Widget _buildFileContent() {
    if (_filteredFiles.isEmpty) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.folder_open, size: 56, color: CozeColors.fgDim),
          const SizedBox(height: CozeSpacing.lg),
          const Text('暂无文件',
              style: TextStyle(fontSize: CozeFontSize.s16, color: CozeColors.fgDim)),
          const SizedBox(height: CozeSpacing.sm),
          GestureDetector(
            onTap: () => _showUploadDialog(),
            child: const Text('上传文件',
                style: TextStyle(fontSize: CozeFontSize.s14, color: CozeColors.brand5)),
          ),
        ]),
      );
    }

    if (_isGridView) {
      return _buildGridView();
    }

    // Default: list view with folder grouping
    return _buildFolderListView();
  }

  // ─── Folder List View (grouped by type) ───
  Widget _buildFolderListView() {
    if (_filterType != null) {
      // Single type filter — flat list
      return ListView.separated(
        padding: const EdgeInsets.all(CozeSpacing.lg),
        itemCount: _filteredFiles.length,
        separatorBuilder: (_, __) => const SizedBox(height: CozeSpacing.sm),
        itemBuilder: (context, index) => _buildFileTile(_filteredFiles[index]),
      );
    }

    // Grouped by file type — "folder" style
    final grouped = _groupedFiles;
    final typeEntries = grouped.entries.toList();

    return ListView.builder(
      padding: const EdgeInsets.all(CozeSpacing.lg),
      itemCount: typeEntries.length,
      itemBuilder: (context, typeIndex) {
        final entry = typeEntries[typeIndex];
        return _buildFileFolder(entry.key, entry.value);
      },
    );
  }

  // ─── File "Folder" Section ───
  Widget _buildFileFolder(FileType type, List<ProjectFile> files) {
    return Padding(
      padding: const EdgeInsets.only(bottom: CozeSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Folder header
          GestureDetector(
            onTap: () => setState(() => _filterType = type),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: CozeSpacing.sm),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: fileTypeColor(type).withOpacity(0.1),
                      borderRadius: CozeRadius.xlBorder,
                    ),
                    child: Icon(fileTypeIcon(type), size: 14, color: fileTypeColor(type)),
                  ),
                  const SizedBox(width: CozeSpacing.sm),
                  Text(fileTypeName(type),
                      style: const TextStyle(
                          fontSize: CozeFontSize.s14,
                          fontWeight: FontWeight.w600,
                          color: CozeColors.fgPrimary)),
                  const SizedBox(width: CozeSpacing.sm),
                  Text('(${files.length})',
                      style: const TextStyle(fontSize: CozeFontSize.s12, color: CozeColors.dimText)),
                  const Spacer(),
                  const Icon(Icons.chevron_right, size: 18, color: CozeColors.dimText),
                ],
              ),
            ),
          ),
          const SizedBox(height: CozeSpacing.xs),
          // Files in this folder
          ...files.map((f) => Padding(
            padding: const EdgeInsets.only(bottom: CozeSpacing.sm),
            child: _buildFileTile(f),
          )),
        ],
      ),
    );
  }

  // ─── File Tile ───
  Widget _buildFileTile(ProjectFile file) {
    final color = fileTypeColor(file.type);
    return GestureDetector(
      onTap: () => _showFilePreview(file),
      child: Container(
        padding: const EdgeInsets.all(CozeSpacing.md),
        decoration: BoxDecoration(
          color: CozeColors.chipGray,
          borderRadius: CozeRadius.xlBorder,
        ),
        child: Row(
          children: [
            // File type icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: CozeRadius.xlBorder,
              ),
              child: Icon(fileTypeIcon(file.type), size: 20, color: color),
            ),
            const SizedBox(width: CozeSpacing.md),
            // File info
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
                      const SizedBox(width: CozeSpacing.sm),
                      Text(file.modifiedTime,
                          style: const TextStyle(fontSize: CozeFontSize.s12, color: CozeColors.dimText)),
                    ],
                  ),
                ],
              ),
            ),
            // More options
            GestureDetector(
              onTap: () => _showFileOptions(file),
              child: const Icon(Icons.more_horiz, size: 20, color: CozeColors.dimText),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Grid View ───
  Widget _buildGridView() {
    return GridView.builder(
      padding: const EdgeInsets.all(CozeSpacing.lg),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: CozeSpacing.sm,
        mainAxisSpacing: CozeSpacing.sm,
        childAspectRatio: 0.85,
      ),
      itemCount: _filteredFiles.length,
      itemBuilder: (context, index) {
        final file = _filteredFiles[index];
        final color = fileTypeColor(file.type);
        return GestureDetector(
          onTap: () => _showFilePreview(file),
          child: Container(
            padding: const EdgeInsets.all(CozeSpacing.sm),
            decoration: BoxDecoration(
              color: CozeColors.chipGray,
              borderRadius: CozeRadius.xlBorder,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: CozeRadius.xlBorder,
                  ),
                  child: Icon(fileTypeIcon(file.type), size: 24, color: color),
                ),
                const SizedBox(height: CozeSpacing.sm),
                Text(file.name,
                    style: const TextStyle(
                        fontSize: 11,
                        color: CozeColors.fgPrimary),
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(file.size,
                    style: const TextStyle(fontSize: 10, color: CozeColors.dimText)),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─── File Preview Dialog ───
  void _showFilePreview(ProjectFile file) {
    final color = fileTypeColor(file.type);
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
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: CozeRadius.xlBorder,
                  ),
                  child: Icon(fileTypeIcon(file.type), size: 24, color: color),
                ),
                const SizedBox(width: CozeSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(file.name,
                          style: const TextStyle(
                              fontSize: CozeFontSize.s16,
                              fontWeight: FontWeight.bold,
                              color: CozeColors.fgPrimary)),
                      const SizedBox(height: 4),
                      Text('${fileTypeName(file.type)} · ${file.size}',
                          style: const TextStyle(fontSize: CozeFontSize.s12, color: CozeColors.dimText)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: CozeSpacing.lg),
            // File info rows
            _fileInfoRow(Icons.schedule, '修改时间', file.modifiedTime),
            _fileInfoRow(Icons.storage_outlined, '文件大小', file.size),
            _fileInfoRow(Icons.category_outlined, '文件类型', fileTypeName(file.type)),
            if (file.preview != null) ...[
              const SizedBox(height: CozeSpacing.md),
              const Divider(),
              const SizedBox(height: CozeSpacing.sm),
              const Text('预览',
                  style: TextStyle(
                      fontSize: CozeFontSize.s14,
                      fontWeight: FontWeight.w600,
                      color: CozeColors.fgPrimary)),
              const SizedBox(height: CozeSpacing.sm),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(CozeSpacing.md),
                decoration: BoxDecoration(
                  color: CozeColors.chipGray,
                  borderRadius: CozeRadius.xlBorder,
                ),
                child: Text(file.preview!,
                    style: const TextStyle(
                        fontSize: CozeFontSize.s14, color: CozeColors.fgDim, height: 1.4)),
              ),
            ],
            const SizedBox(height: CozeSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.download_outlined, size: 18),
                    label: const Text('下载'),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: CozeRadius.xlBorder),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: CozeSpacing.md),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.share_outlined, size: 18),
                    label: const Text('分享'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CozeColors.brand5,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: CozeRadius.xlBorder),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _fileInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: CozeColors.fgDim),
          const SizedBox(width: CozeSpacing.sm),
          Text(label, style: const TextStyle(fontSize: CozeFontSize.s14, color: CozeColors.fgDim)),
          const Spacer(),
          Text(value,
              style: const TextStyle(
                  fontSize: CozeFontSize.s14,
                  fontWeight: FontWeight.w500,
                  color: CozeColors.fgPrimary)),
        ],
      ),
    );
  }

  // ─── File Options ───
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
            ListTile(
              leading: const Icon(Icons.download_outlined, color: CozeColors.fgSecondary),
              title: const Text('下载文件'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('下载中...'), duration: Duration(seconds: 1)),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.share_outlined, color: CozeColors.fgSecondary),
              title: const Text('分享文件'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('分享功能开发中'), duration: Duration(seconds: 1)),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit_outlined, color: CozeColors.fgSecondary),
              title: const Text('重命名'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('重命名功能开发中'), duration: Duration(seconds: 1)),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: CozeColors.error),
              title: const Text('删除', style: TextStyle(color: CozeColors.error)),
              onTap: () {
                setState(() {
                  _allFiles.removeWhere((f) => f.name == file.name);
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('已删除 ${file.name}'),
                    duration: const Duration(seconds: 2),
                    action: SnackBarAction(
                      label: '撤销',
                      textColor: CozeColors.brand5,
                      onPressed: () {
                        setState(() => _allFiles.add(file));
                      },
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ─── Upload Dialog ───
  void _showUploadDialog() {
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
              child: Text('上传文件',
                  style: TextStyle(
                      fontSize: CozeFontSize.s16,
                      fontWeight: FontWeight.bold,
                      color: CozeColors.fgPrimary)),
            ),
            Divider(height: 1, color: CozeColors.strokePrimary),
            _uploadOption(Icons.image_outlined, '图片', '从相册选择或拍照上传', () {
              _simulateUpload('示例图片.png', FileType.image, '1.2 MB');
            }),
            _uploadOption(Icons.insert_drive_file_outlined, '文档', 'PDF、Word、TXT 等文档', () {
              _simulateUpload('示例文档.pdf', FileType.document, '856 KB');
            }),
            _uploadOption(Icons.code, '代码文件', '源代码或配置文件', () {
              _simulateUpload('example.dart', FileType.code, '4.2 KB');
            }),
            _uploadOption(Icons.movie_outlined, '视频', 'MP4、MOV 等视频文件', () {
              _simulateUpload('示例视频.mp4', FileType.video, '32 MB');
            }),
            _uploadOption(Icons.storage_outlined, '数据集', 'CSV、JSON、Excel 等数据文件', () {
              _simulateUpload('data.csv', FileType.data, '2.8 MB');
            }),
          ],
        ),
      ),
    );
  }

  Widget _uploadOption(IconData icon, String title, String desc, VoidCallback onTap) {
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
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }

  void _simulateUpload(String name, FileType type, String size) {
    setState(() {
      _allFiles.insert(0, ProjectFile(
        name: name,
        type: type,
        size: size,
        modifiedTime: '刚刚',
      ));
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$name 已上传'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
