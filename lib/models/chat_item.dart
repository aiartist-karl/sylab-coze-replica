class ChatListItem {
  final String avatar;
  final String name;
  final String preview;
  final String time;
  final bool isAgent;

  const ChatListItem({
    required this.avatar,
    required this.name,
    required this.preview,
    required this.time,
    this.isAgent = true,
  });
}

const List<ChatListItem> mockChatList = [
  ChatListItem(
    avatar: '🚀',
    name: '小篷',
    preview: '包包，刚出了个大事，我把你上次说的那个方案实现了，效果超出预期...',
    time: '2天前',
  ),
  ChatListItem(
    avatar: '⚔️',
    name: '修仙巨擎Reborn',
    preview: '暂无消息，快去聊聊吧',
    time: '32天前',
  ),
  ChatListItem(
    avatar: '🎬',
    name: '完美追捕',
    preview: '视频项目演示',
    time: '1分钟前',
  ),
  ChatListItem(
    avatar: '🤖',
    name: '代码助手Pro',
    preview: '你好！我是你的编程助手，有什么可以帮忙的？',
    time: '1小时前',
  ),
  ChatListItem(
    avatar: '📊',
    name: '数据分析师',
    preview: '已为您生成最新的数据报告...',
    time: '3天前',
  ),
  ChatListItem(
    avatar: '🎨',
    name: '创意画板',
    preview: '来看看我为你设计的插画方案',
    time: '5天前',
  ),
];
