import 'package:flutter/material.dart';
import '../theme/coze_colors.dart';
import '../theme/coze_theme.dart';
import '../models/project_item.dart';
import '../widgets/coze_dialog.dart';
import 'project_detail_page.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ChatPage extends StatefulWidget {
  final String agentName;
  final ProjectItem? project; // Optional: linked project for file management
  const ChatPage({super.key, required this.agentName, this.project});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  bool _showAttachmentMenu = false;
  bool _isVoiceMode = false;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();

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

  /// Resolve project — use passed project or find from mock data
  ProjectItem? get _resolvedProject {
    if (widget.project != null) return widget.project;
    // Try to find by agent name
    for (final p in mockProjectList) {
      if (p.name == widget.agentName) return p;
    }
    return null;
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final project = _resolvedProject;
    return Scaffold(
      backgroundColor: CozeColors.bgMax,
      appBar: AppBar(
        backgroundColor: CozeColors.bgMax,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20, color: CozeColors.fgPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: GestureDetector(
          onTap: _renameProject,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(widget.agentName,
                    style: const TextStyle(
                        fontSize: CozeFontSize.s18,
                        fontWeight: FontWeight.bold,
                        color: CozeColors.fgPrimary),
                    overflow: TextOverflow.ellipsis),
              ),
              const Text(' >',
                  style: TextStyle(fontSize: CozeFontSize.s16, color: CozeColors.fgDim)),
            ],
          ),
        ),
        titleSpacing: 0,
        actions: [
          // File management button
          if (project != null)
            IconButton(
              icon: Icon(Icons.folder_outlined, size: 22, color: CozeColors.fgDim),
              tooltip: '项目文件',
              onPressed: () => Navigator.push(
                context,
                cozeFadeRoute((_) => ProjectDetailPage(project: project)),
              ),
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
                  itemCount: _messages.length + 2,
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

  // ─── Rename Project Dialog ───
  void _renameProject() {
    CozeDialog.showInput(
      context,
      title: '修改项目名称',
      hintText: '输入新项目名称',
      initialValue: widget.agentName,
      confirmText: '保存',
    ).then((newName) {
      if (newName != null && newName.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('项目名称已修改为「$newName」'), duration: const Duration(seconds: 1)),
        );
      }
    });
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
          child: msg.filePath != null
              ? _buildFileAttachment(msg)
              : Text(msg.content,
                  style: const TextStyle(fontSize: CozeFontSize.s16, color: CozeColors.fgPrimary)),
        ),
      ),
    );
  }

  Widget _buildFileAttachment(_Message msg) {
    if (msg.fileType == 'image' && msg.filePath != null) {
      return ClipRRect(
        borderRadius: CozeRadius.xlBorder,
        child: Image.file(
          File(msg.filePath!),
          width: 200,
          height: 200,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildFilePlaceholder(msg);
          },
        ),
      );
    } else if (msg.fileType == 'video') {
      return _buildVideoAttachment(msg);
    } else {
      return _buildFilePlaceholder(msg);
    }
  }

  Widget _buildVideoAttachment(_Message msg) {
    return Container(
      width: 200,
      height: 150,
      decoration: BoxDecoration(
        color: CozeColors.chipGray,
        borderRadius: CozeRadius.xlBorder,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.videocam, size: 40, color: CozeColors.fgSecondary),
          const SizedBox(height: CozeSpacing.sm),
          Text(
            msg.fileName ?? '视频',
            style: const TextStyle(fontSize: CozeFontSize.s12, color: CozeColors.fgDim),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildFilePlaceholder(_Message msg) {
    return Container(
      padding: const EdgeInsets.all(CozeSpacing.md),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.insert_drive_file, size: 32, color: CozeColors.fgSecondary),
          const SizedBox(width: CozeSpacing.sm),
          Flexible(
            child: Text(
              msg.fileName ?? '文件',
              style: const TextStyle(fontSize: CozeFontSize.s14, color: CozeColors.fgPrimary),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIMessage(_Message msg) {
    return Padding(
      padding: const EdgeInsets.only(bottom: CozeSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${msg.senderName} ${msg.time}',
                    style: const TextStyle(
                        fontSize: CozeFontSize.s12, color: CozeColors.dimText)),
                const SizedBox(height: CozeSpacing.xs),
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

  // ─── Attachment Menu (Image, Video, File) ──
  Widget _buildAttachmentMenu() {
    return Container(
      margin: const EdgeInsets.fromLTRB(CozeSpacing.lg, 0, CozeSpacing.lg, CozeSpacing.sm),
      padding: const EdgeInsets.all(CozeSpacing.md),
      decoration: BoxDecoration(
        color: CozeColors.bgMax,
        borderRadius: CozeRadius.xlBorder,
        boxShadow: CozeShadow.small,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _attachOption(Icons.image_outlined, '图片', () => _pickImage()),
          const SizedBox(width: CozeSpacing.md),
          _attachOption(Icons.videocam_outlined, '视频', () => _pickVideo()),
          const SizedBox(width: CozeSpacing.md),
          _attachOption(Icons.insert_drive_file_outlined, '文件', () => _pickFile()),
        ],
      ),
    );
  }

  Widget _attachOption(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: CozeColors.chipGray,
              borderRadius: CozeRadius.xlBorder,
            ),
            child: Icon(icon, size: 24, color: CozeColors.fgSecondary),
          ),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(fontSize: CozeFontSize.s12, color: CozeColors.fgDim)),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    setState(() => _showAttachmentMenu = false);
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _messages.add(_Message(
            isUser: true,
            content: '',
            filePath: image.path,
            fileName: image.name,
            fileType: 'image',
          ));
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('选择图片失败: $e'), duration: const Duration(seconds: 2)),
        );
      }
    }
  }

  Future<void> _pickVideo() async {
    setState(() => _showAttachmentMenu = false);
    try {
      final picker = ImagePicker();
      final XFile? video = await picker.pickVideo(source: ImageSource.gallery);
      if (video != null) {
        setState(() {
          _messages.add(_Message(
            isUser: true,
            content: '',
            filePath: video.path,
            fileName: video.name,
            fileType: 'video',
          ));
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('选择视频失败: $e'), duration: const Duration(seconds: 2)),
        );
      }
    }
  }

  Future<void> _pickFile() async {
    setState(() => _showAttachmentMenu = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('文件上传功能开发中'), duration: Duration(seconds: 2)),
      );
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  // ── Bottom Input Area ───
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
            GestureDetector(
              onTap: () => setState(() => _showAttachmentMenu = !_showAttachmentMenu),
              child: Icon(Icons.add_circle_outline, size: 28, color: CozeColors.fgDim),
            ),
            const SizedBox(width: CozeSpacing.sm),
            Expanded(
              child: _isVoiceMode
                  ? GestureDetector(
                      onTap: () => setState(() => _isVoiceMode = false),
                      onLongPress: () => _showVoiceInputOverlay(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: CozeSpacing.md, vertical: CozeSpacing.md),
                        decoration: BoxDecoration(
                          color: CozeColors.chipGray,
                          borderRadius: CozeRadius.pillBorder,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.mic, size: 20, color: CozeColors.brand5),
                            SizedBox(width: 6),
                            Text('按住说话',
                                style: TextStyle(
                                    fontSize: CozeFontSize.s16, color: CozeColors.fgPrimary)),
                          ],
                        ),
                      ),
                    )
                  : TextField(
                      controller: _textController,
                      autofocus: false,
                      maxLines: 4,
                      minLines: 1,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (text) {
                        if (text.trim().isNotEmpty) {
                          setState(() {
                            _messages.add(_Message(isUser: true, content: text.trim()));
                          });
                          _textController.clear();
                          Future.delayed(const Duration(milliseconds: 100), () {
                            _scrollController.animateTo(
                              _scrollController.position.maxScrollExtent,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          });
                        }
                      },
                      onTap: () => setState(() => _isVoiceMode = false),
                      style: const TextStyle(fontSize: CozeFontSize.s16, color: CozeColors.fgPrimary),
                      decoration: InputDecoration(
                        hintText: '输入消息...',
                        hintStyle: const TextStyle(fontSize: CozeFontSize.s16, color: CozeColors.fgDim),
                        filled: true,
                        fillColor: CozeColors.chipGray,
                        contentPadding: const EdgeInsets.symmetric(horizontal: CozeSpacing.md, vertical: CozeSpacing.md),
                        border: OutlineInputBorder(
                          borderRadius: CozeRadius.pillBorder,
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: CozeRadius.pillBorder,
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: CozeRadius.pillBorder,
                          borderSide: BorderSide.none,
                        ),
                        isDense: true,
                      ),
                    ),
            ),
            const SizedBox(width: CozeSpacing.sm),
            GestureDetector(
              onTap: () {
                // Send text message
                final text = _textController.text.trim();
                if (text.isNotEmpty) {
                  setState(() {
                    _messages.add(_Message(isUser: true, content: text));
                  });
                  _textController.clear();
                  Future.delayed(const Duration(milliseconds: 100), () {
                    _scrollController.animateTo(
                      _scrollController.position.maxScrollExtent,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  });
                }
              },
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: CozeColors.brand5,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.send, size: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showVoiceInputOverlay() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return _VoiceInputDialog(
          onReleased: () {
            Navigator.pop(ctx);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('语音发送功能对接中'), duration: Duration(seconds: 1)),
            );
          },
        );
      },
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
  final String? filePath;
  final String? fileName;
  final String? fileType; // 'image', 'video', 'file'

  const _Message({
    required this.isUser,
    this.avatar,
    this.senderName,
    this.time,
    required this.content,
    this.hasMention = false,
    this.mentionText,
    this.filePath,
    this.fileName,
    this.fileType,
  });
}

class _AttachItem {
  final IconData icon;
  final String label;
  final bool hasRedDot;
  const _AttachItem(this.icon, this.label, this.hasRedDot);
}

class _VoiceInputDialog extends StatefulWidget {
  final VoidCallback onReleased;
  const _VoiceInputDialog({required this.onReleased});

  @override
  State<_VoiceInputDialog> createState() => _VoiceInputDialogState();
}

class _VoiceInputDialogState extends State<_VoiceInputDialog> {
  bool _isPressing = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        padding: const EdgeInsets.all(CozeSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTapDown: (_) {
                setState(() => _isPressing = true);
              },
              onTapUp: (_) {
                setState(() => _isPressing = false);
                widget.onReleased();
              },
              onTapCancel: () {
                setState(() => _isPressing = false);
                widget.onReleased();
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: CozeSpacing.xl),
                decoration: BoxDecoration(
                  color: _isPressing ? CozeColors.error.withOpacity(0.1) : CozeColors.chipGray,
                  borderRadius: CozeRadius.xxlBorder,
                ),
                child: Column(
                  children: [
                    Icon(
                      _isPressing ? Icons.mic : Icons.mic_none,
                      size: 48,
                      color: _isPressing ? CozeColors.error : CozeColors.fgSecondary,
                    ),
                    const SizedBox(height: CozeSpacing.md),
                    Text(
                      _isPressing ? '松开 结束录音' : '按住 开始说话',
                      style: TextStyle(
                        fontSize: CozeFontSize.s16,
                        color: _isPressing ? CozeColors.error : CozeColors.fgPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: CozeSpacing.md),
            const Text(
              '对接后端语音API后，按住说话即可直接发送语音消息',
              style: TextStyle(fontSize: CozeFontSize.s12, color: CozeColors.dimText),
            ),
          ],
        ),
      ),
    );
  }
}