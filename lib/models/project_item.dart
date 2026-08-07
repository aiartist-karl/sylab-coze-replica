import 'package:flutter/material.dart';

/// 项目文件模型
class ProjectFile {
  final String name;
  final FileType type;
  final String size;
  final String modifiedTime;
  final String? preview; // 文件预览文本或路径

  const ProjectFile({
    required this.name,
    required this.type,
    required this.size,
    required this.modifiedTime,
    this.preview,
  });
}

enum FileType { image, document, code, video, audio, data, other }

/// 项目（= 会话）模型 — 1:1 关联
/// 每个会话自动就是一个项目工作空间，包含对话记录 + 文件产物
class ProjectItem {
  final String id;
  final String name;
  final String description;
  final String avatar;
  final String lastMessage;
  final String lastActiveTime;
  final List<ProjectFile> files;
  final int unreadCount;

  const ProjectItem({
    required this.id,
    required this.name,
    required this.description,
    required this.avatar,
    required this.lastMessage,
    required this.lastActiveTime,
    this.files = const [],
    this.unreadCount = 0,
  });

  /// 最近文件预览（取前3个）
  List<ProjectFile> get recentFiles => files.take(3).toList();

  /// 按文件类型分组
  Map<FileType, List<ProjectFile>> get filesByType {
    final map = <FileType, List<ProjectFile>>{};
    for (final f in files) {
      map.putIfAbsent(f.type, () => []).add(f);
    }
    return map;
  }

  /// 文件总大小描述
  String get totalFileCount => '${files.length} 个文件';
}

// ─── Mock Data ───

const _mockFiles1 = [
  ProjectFile(name: '需求分析文档.pdf', type: FileType.document, size: '2.4 MB', modifiedTime: '2小时前', preview: '产品需求规格说明书 v1.2'),
  ProjectFile(name: 'UI设计稿.png', type: FileType.image, size: '5.8 MB', modifiedTime: '3小时前', preview: 'Flutter UI 高保真设计图'),
  ProjectFile(name: 'main.dart', type: FileType.code, size: '12 KB', modifiedTime: '1小时前', preview: 'import \'package:flutter/material.dart\';'),
  ProjectFile(name: 'API接口文档.md', type: FileType.document, size: '8.2 KB', modifiedTime: '昨天'),
  ProjectFile(name: '数据库设计.sql', type: FileType.code, size: '3.1 KB', modifiedTime: '昨天'),
  ProjectFile(name: '测试报告.pdf', type: FileType.document, size: '1.5 MB', modifiedTime: '2天前'),
];

const _mockFiles2 = [
  ProjectFile(name: '数据分析结果.xlsx', type: FileType.data, size: '3.2 MB', modifiedTime: '昨天'),
  ProjectFile(name: '可视化截图.png', type: FileType.image, size: '2.1 MB', modifiedTime: '昨天', preview: 'Dashboard 数据可视化面板'),
  ProjectFile(name: 'analysis.py', type: FileType.code, size: '6.8 KB', modifiedTime: '1天前'),
];

const _mockFiles3 = [
  ProjectFile(name: '产品介绍视频.mp4', type: FileType.video, size: '128 MB', modifiedTime: '3天前'),
  ProjectFile(name: '配音脚本.txt', type: FileType.document, size: '4.2 KB', modifiedTime: '4天前'),
  ProjectFile(name: '封面设计.png', type: FileType.image, size: '3.5 MB', modifiedTime: '3天前', preview: '产品宣传片封面图'),
];

const _mockFiles4 = [
  ProjectFile(name: 'bot_config.yaml', type: FileType.code, size: '2.1 KB', modifiedTime: '5天前'),
  ProjectFile(name: 'review_rules.json', type: FileType.code, size: '5.6 KB', modifiedTime: '5天前'),
  ProjectFile(name: '测试日志.log', type: FileType.document, size: '156 KB', modifiedTime: '6天前'),
];

const mockProjectList = <ProjectItem>[
  ProjectItem(
    id: 'p1',
    name: '扣子App UI复刻工作',
    description: 'Flutter客户端开发，包含首页、聊天、技能商店等页面UI还原与交互逻辑',
    avatar: '🎨',
    lastMessage: '已完成首页左滑删除、Overlay菜单定位等交互',
    lastActiveTime: '2小时前',
    files: _mockFiles1,
  ),
  ProjectItem(
    id: 'p2',
    name: '智能数据分析平台',
    description: '使用Python + Flutter构建的可视化数据分析仪表盘，支持多维度数据探索',
    avatar: '📊',
    lastMessage: '数据分析模块已完成，准备对接可视化组件',
    lastActiveTime: '昨天',
    files: _mockFiles2,
  ),
  ProjectItem(
    id: 'p3',
    name: '产品宣传视频制作',
    description: 'AI辅助生成3分钟产品介绍视频，包含动画特效、配音和字幕',
    avatar: '🎬',
    lastMessage: '视频初剪完成，等待最终审核',
    lastActiveTime: '3天前',
    files: _mockFiles3,
  ),
  ProjectItem(
    id: 'p4',
    name: '代码审查Bot开发',
    description: '自动审查GitHub PR代码质量，提供优化建议、安全评分和改进方案',
    avatar: '🤖',
    lastMessage: '已支持Python/JS/Go三种语言的规则检查',
    lastActiveTime: '5天前',
    files: _mockFiles4,
  ),
];

// ─── Utility ───

IconData fileTypeIcon(FileType type) {
  switch (type) {
    case FileType.image: return Icons.image_outlined;
    case FileType.document: return Icons.description_outlined;
    case FileType.code: return Icons.code;
    case FileType.video: return Icons.movie_outlined;
    case FileType.audio: return Icons.audiotrack_outlined;
    case FileType.data: return Icons.table_chart_outlined;
    case FileType.other: return Icons.insert_drive_file_outlined;
  }
}

Color fileTypeColor(FileType type) {
  switch (type) {
    case FileType.image: return const Color(0xFF4CAF50);
    case FileType.document: return const Color(0xFF4A90D9);
    case FileType.code: return const Color(0xFFFF9800);
    case FileType.video: return const Color(0xFFE91E63);
    case FileType.audio: return const Color(0xFF9C27B0);
    case FileType.data: return const Color(0xFF00BCD4);
    case FileType.other: return const Color(0xFF8E8E93);
  }
}

String fileTypeName(FileType type) {
  switch (type) {
    case FileType.image: return '图片';
    case FileType.document: return '文档';
    case FileType.code: return '代码';
    case FileType.video: return '视频';
    case FileType.audio: return '音频';
    case FileType.data: return '数据';
    case FileType.other: return '其他';
  }
}
