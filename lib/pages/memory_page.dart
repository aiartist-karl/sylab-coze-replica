import 'package:flutter/material.dart';
import '../theme/coze_colors.dart';
import '../theme/coze_theme.dart';

class MemoryPage extends StatefulWidget {
  const MemoryPage({super.key});
  @override
  State<MemoryPage> createState() => _MemoryPageState();
}

class _MemoryPageState extends State<MemoryPage> {
  // 模拟记忆数据（后续对接后端API）
  final List<Map<String, dynamic>> _memories = [
    {
      'category': '用户偏好',
      'items': [
        {'content': '喜欢简洁的UI风格，不喜欢花哨的设计', 'time': '2天前'},
        {'content': '偏好使用深色模式', 'time': '5天前'},
      ],
    },
    {
      'category': '对话历史',
      'items': [
        {'content': '正在开发Flutter复刻版APP', 'time': '1小时前'},
        {'content': '讨论了CI/CD流程优化方案', 'time': '昨天'},
      ],
    },
    {
      'category': '项目信息',
      'items': [
        {'content': '使用GitHub Actions进行自动化构建', 'time': '3天前'},
        {'content': '后端部署在阿里云47.116.29.140', 'time': '1周前'},
      ],
    },
  ];

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
        title: const Text('Bot记忆系统', style: TextStyle(fontSize: CozeFontSize.s18, fontWeight: FontWeight.bold, color: CozeColors.fgPrimary)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, size: 22, color: CozeColors.fgDim),
            onPressed: _addMemory,
          ),
        ],
      ),
      body: _memories.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.memory, size: 56, color: CozeColors.fgDim),
                  SizedBox(height: CozeSpacing.lg),
                  Text('暂无记忆', style: TextStyle(fontSize: CozeFontSize.s16, color: CozeColors.fgDim)),
                  SizedBox(height: CozeSpacing.sm),
                  Text('点击右上角+添加第一条记忆', style: TextStyle(fontSize: CozeFontSize.s14, color: CozeColors.dimText)),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.symmetric(horizontal: CozeSpacing.lg, vertical: CozeSpacing.md),
              children: [
                // 记忆统计
                _buildStats(),
                const SizedBox(height: CozeSpacing.lg),
                // 记忆分类
                ..._memories.map((group) => _buildMemoryGroup(group)),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addMemory,
        backgroundColor: CozeColors.brand5,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildStats() {
    int totalMemories = 0;
    for (var group in _memories) {
      totalMemories += (group['items'] as List).length;
    }

    return Container(
      padding: const EdgeInsets.all(CozeSpacing.lg),
      decoration: BoxDecoration(
        color: CozeColors.chipGray,
        borderRadius: CozeRadius.xxlBorder,
      ),
      child: Row(
        children: [
          _statItem('总记忆数', '$totalMemories'),
          const SizedBox(width: CozeSpacing.md),
          Container(width: 1, height: 32, color: CozeColors.strokePrimary),
          const SizedBox(width: CozeSpacing.md),
          _statItem('分类数', '${_memories.length}'),
          const Spacer(),
          const Icon(Icons.memory, size: 28, color: CozeColors.brand5),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: const TextStyle(fontSize: CozeFontSize.s18, fontWeight: FontWeight.bold, color: CozeColors.fgPrimary)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: CozeFontSize.s12, color: CozeColors.fgDim)),
        ],
      ),
    );
  }

  Widget _buildMemoryGroup(Map<String, dynamic> group) {
    final category = group['category'] as String;
    final items = group['items'] as List<Map<String, dynamic>>;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: CozeSpacing.sm, left: CozeSpacing.xs),
          child: Text(category, style: const TextStyle(fontSize: CozeFontSize.s14, fontWeight: FontWeight.w600, color: CozeColors.fgSecondary)),
        ),
        Container(
          decoration: BoxDecoration(color: CozeColors.chipGray, borderRadius: CozeRadius.xxlBorder),
          child: Column(
            children: List.generate(items.length, (i) {
              final item = items[i];
              return Column(
                children: [
                  ListTile(
                    leading: Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(color: CozeColors.brand5.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.psychology, size: 20, color: CozeColors.brand5),
                    ),
                    title: Text(item['content'] as String, style: const TextStyle(fontSize: CozeFontSize.s16, color: CozeColors.fgPrimary)),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(item['time'] as String, style: const TextStyle(fontSize: CozeFontSize.s12, color: CozeColors.dimText)),
                    ),
                    trailing: PopupMenuButton<String>(
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'edit', child: Text('编辑')),
                        const PopupMenuItem(value: 'delete', child: Text('删除', style: TextStyle(color: CozeColors.error))),
                      ],
                      onSelected: (value) {
                        if (value == 'edit') {
                          _editMemory(item);
                        } else if (value == 'delete') {
                          _deleteMemory(group, item);
                        }
                      },
                    ),
                    onTap: () => _viewMemoryDetail(item),
                  ),
                  if (i < items.length - 1) Divider(height: 1, color: CozeColors.strokePrimary, indent: 68),
                ],
              );
            }),
          ),
        ),
        const SizedBox(height: CozeSpacing.lg),
      ],
    );
  }

  void _addMemory() {
    showDialog(
      context: context,
      builder: (ctx) {
        final contentController = TextEditingController();
        final categoryController = TextEditingController(text: '用户偏好');

        return AlertDialog(
          title: const Text('添加记忆'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: categoryController,
                decoration: const InputDecoration(
                  labelText: '分类',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: contentController,
                decoration: const InputDecoration(
                  labelText: '记忆内容',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                if (contentController.text.trim().isNotEmpty) {
                  setState(() {
                    // 查找或创建分类
                    var group = _memories.firstWhere(
                      (g) => g['category'] == categoryController.text.trim(),
                      orElse: () {
                        final newGroup = {'category': categoryController.text.trim(), 'items': []};
                        _memories.add(newGroup);
                        return newGroup;
                      },
                    );
                    (group['items'] as List).add({
                      'content': contentController.text.trim(),
                      'time': '刚刚',
                    });
                  });
                  Navigator.pop(ctx);
                }
              },
              child: const Text('添加'),
            ),
          ],
        );
      },
    );
  }

  void _editMemory(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (ctx) {
        final controller = TextEditingController(text: item['content'] as String);

        return AlertDialog(
          title: const Text('编辑记忆'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: '记忆内容',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  setState(() {
                    item['content'] = controller.text.trim();
                  });
                  Navigator.pop(ctx);
                }
              },
              child: const Text('保存'),
            ),
          ],
        );
      },
    );
  }

  void _deleteMemory(Map<String, dynamic> group, Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除这条记忆吗？\n\n「${item['content']}」'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                (group['items'] as List).remove(item);
                if ((group['items'] as List).isEmpty) {
                  _memories.remove(group);
                }
              });
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('已删除记忆'), duration: Duration(seconds: 1)),
              );
            },
            child: const Text('删除', style: TextStyle(color: CozeColors.error)),
          ),
        ],
      ),
    );
  }

  void _viewMemoryDetail(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('记忆详情'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item['content'] as String, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 12),
            Text('记录时间：${item['time']}', style: const TextStyle(fontSize: 14, color: CozeColors.fgDim)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }
}
