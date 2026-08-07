import 'package:flutter/material.dart';
import '../theme/coze_colors.dart';
import '../theme/coze_theme.dart';

class ChatPage extends StatefulWidget {
  final String agentName;
  const ChatPage({super.key, required this.agentName});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  bool _showAttachmentMenu = false;
  final ScrollController _scrollController = ScrollController();

  // Mock messages
  final List<_Message> _messages = [
    _Message(
      isUser: false,
      avatar: '🚀',
      senderName: '小篷',
      time: '08-03 13:23',
      content:
          '你好！我帮你分析一下这个方案。首先我们需要考虑以下几个方面：\n\n1. 技术可行性评估\n2. 成本估算\n3. 时间线规划',
      hasMention: true,
      mentionText: '@用户',
    ),
    _Message(
      isUser: false,
      avatar: '🚀',
      senderName: '小篷',
      time: '08-03 13:25',
      content:
          '我已经完成了初步的分析，以下是详细报告。这个项目预计需要3周时间完成，成本约在5000元左右。你觉得怎么样？',
    ),
    _Message(
      isUser: true,
      content: '好的，我觉得方案不错，可以继续推进。',
    ),
    _Message(
      isUser: false,
      avatar: '🚀',
      senderName: '小篷',
      time: '08-03 13:30',
      content:
          '太好了！我现在就开始执行第一步。首先，让我为你创建一个项目计划书，包含所有的技术细节和时间节点。',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CozeColors.bgMax,
      appBar: AppBar(
        backgroundColor: CozeColors.bgMax,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, size: 22, color: CozeColors.fgPrimary),
          onPressed: () {},
        ),
        title: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(widget.agentName,
                  style: const TextStyle(
                      fontSize: CozeFontSize.s18,
                      fontWeight: FontWeight.bold,
                      color: CozeColors.fgPrimary)),
              const Text(' >',
                  style: TextStyle(fontSize: CozeFontSize.s16, color: CozeColors.fgDim)),
            ],
          ),
        ),
        titleSpacing: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, size: 22, color: CozeColors.fgDim),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_horiz, size: 22, color: CozeColors.fgDim),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Chat messages
          Expanded(
            child: Stack(
              children: [
                ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: CozeSpacing.lg, vertical: CozeSpacing.sm),
                  itemCount: _messages.length + 2, // +date separator + spacer
                  itemBuilder: (context, index) {
                    if (index == 0) return _buildDateSeparator();
                    final msgIndex = index - 1;
                    if (msgIndex >= _messages.length) {
                      return const SizedBox(height: 60);
                    }
                    return _buildMessage(_messages[msgIndex]);
                  },
                ),
                // Scroll-to-bottom button
                Positioned(
                  right: CozeSpacing.lg,
                  bottom: CozeSpacing.lg,
                  child: GestureDetector(
                    onTap: () => _scrollController.animateTo(
                      _scrollController.position.maxScrollExtent,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    ),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: CozeColors.bgMax,
                        shape: BoxShape.circle,
                        boxShadow: CozeShadow.small,
                      ),
                      child: const Icon(Icons.keyboard_arrow_down,
                          size: 24, color: CozeColors.fgDim),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Attachment menu
          if (_showAttachmentMenu) _buildAttachmentMenu(),
          // Bottom input area
          _buildInputArea(),
        ],
      ),
    );
  }

  // ─── Date Separator ───
  Widget _buildDateSeparator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: CozeSpacing.md),
      child: Row(
        children: [
          Expanded(child: Container(height: 1, color: CozeColors.separator)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: CozeSpacing.md),
            child: const Text('08-03',
                style: TextStyle(fontSize: CozeFontSize.s12, color: CozeColors.dimText)),
          ),
          Expanded(child: Container(height: 1, color: CozeColors.separator)),
        ],
      ),
    );
  }

  // ─── Message Bubble ───
  Widget _buildMessage(_Message msg) {
    if (msg.isUser) {
      return _buildUserMessage(msg);
    }
    return _buildAIMessage(msg);
  }

  Widget _buildUserMessage(_Message msg) {
    return Padding(
      padding: const EdgeInsets.only(bottom: CozeSpacing.md),
      child: Align(
        alignment: Alignment.centerRight,
        child: Container(
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
          padding: const EdgeInsets.symmetric(horizontal: CozeSpacing.lg, vertical: CozeSpacing.md),
          decoration: BoxDecoration(
            color: CozeColors.mgPrimary,
            borderRadius: CozeRadius.xlBorder,
          ),
          child: Text(msg.content,
              style: const TextStyle(fontSize: CozeFontSize.s16, color: CozeColors.fgPrimary)),
        ),
      ),
    );
  }

  Widget _buildAIMessage(_Message msg) {
    return Padding(
      padding: const EdgeInsets.only(bottom: CozeSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: CozeColors.bgSecondary,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Center(child: Text(msg.avatar!, style: const TextStyle(fontSize: 18))),
          ),
          const SizedBox(width: CozeSpacing.sm),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sender + time
                Text('${msg.senderName} ${msg.time}',
                    style: const TextStyle(
                        fontSize: CozeFontSize.s12, color: CozeColors.dimText)),
                const SizedBox(height: CozeSpacing.xs),
                // Bubble
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: CozeSpacing.lg, vertical: CozeSpacing.md),
                  decoration: BoxDecoration(
                    color: CozeColors.cardGray,
                    borderRadius: CozeRadius.xlBorder,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(msg.content,
                          style: const TextStyle(
                              fontSize: CozeFontSize.s16, color: CozeColors.fgPrimary, height: 1.5)),
                      // @mention tag
                      if (msg.hasMention) ...[
                        const SizedBox(height: CozeSpacing.sm),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: CozeColors.infoBlue,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(msg.mentionText ?? '',
                              style: const TextStyle(
                                  fontSize: CozeFontSize.s14, color: Colors.white)),
                        ),
                      ],
                      const SizedBox(height: CozeSpacing.sm),
                      const Text('展开',
                          style: TextStyle(
                              fontSize: CozeFontSize.s16, color: CozeColors.teal)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Attachment Menu ───
  Widget _buildAttachmentMenu() {
    final items = [
      _AttachItem(Icons.image_outlined, '图片', false),
      _AttachItem(Icons.insert_drive_file_outlined, '文件', false),
      _AttachItem(Icons.storage_outlined, '数据集', false),
      _AttachItem(Icons.auto_awesome_outlined, '技能', false),
      _AttachItem(Icons.mic_outlined, '旁听', true),
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(CozeSpacing.lg, 0, CozeSpacing.lg, CozeSpacing.sm),
      padding: const EdgeInsets.all(CozeSpacing.md),
      decoration: BoxDecoration(
        color: CozeColors.bgMax,
        borderRadius: CozeRadius.xlBorder,
        boxShadow: CozeShadow.small,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: items
            .map((item) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: CozeColors.chipGray,
                            borderRadius: CozeRadius.xlBorder,
                          ),
                          child: Icon(item.icon, size: 24, color: CozeColors.fgSecondary),
                        ),
                        if (item.hasRedDot)
                          Positioned(
                            right: -2,
                            top: -2,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                  color: CozeColors.error, shape: BoxShape.circle),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(item.label,
                        style: const TextStyle(
                            fontSize: CozeFontSize.s12, color: CozeColors.fgDim)),
                  ],
                ))
            .toList(),
      ),
    );
  }

  // ─── Bottom Input Area ───
  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.fromLTRB(CozeSpacing.md, CozeSpacing.sm, CozeSpacing.md, CozeSpacing.lg),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: CozeSpacing.md, vertical: CozeSpacing.sm),
        decoration: BoxDecoration(
          color: CozeColors.bgMax,
          borderRadius: CozeRadius.pillBorder,
          boxShadow: CozeShadow.small,
        ),
        child: Row(
          children: [
            // Plus button with red dot
            GestureDetector(
              onTap: () => setState(() => _showAttachmentMenu = !_showAttachmentMenu),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(Icons.add_circle_outline, size: 28, color: CozeColors.fgDim),
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                          color: CozeColors.error, shape: BoxShape.circle),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: CozeSpacing.sm),
            // "Press to speak" button
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: CozeSpacing.md),
                decoration: BoxDecoration(
                  color: CozeColors.chipGray,
                  borderRadius: CozeRadius.pillBorder,
                ),
                child: const Center(
                  child: Text('按下说话',
                      style: TextStyle(
                          fontSize: CozeFontSize.s16, color: CozeColors.fgPrimary)),
                ),
              ),
            ),
            const SizedBox(width: CozeSpacing.sm),
            const Icon(Icons.keyboard, size: 28, color: CozeColors.fgDim),
          ],
        ),
      ),
    );
  }
}

class _Message {
  final bool isUser;
  final String? avatar;
  final String? senderName;
  final String? time;
  final String content;
  final bool hasMention;
  final String? mentionText;

  const _Message({
    required this.isUser,
    this.avatar,
    this.senderName,
    this.time,
    required this.content,
    this.hasMention = false,
    this.mentionText,
  });
}

class _AttachItem {
  final IconData icon;
  final String label;
  final bool hasRedDot;
  const _AttachItem(this.icon, this.label, this.hasRedDot);
}
