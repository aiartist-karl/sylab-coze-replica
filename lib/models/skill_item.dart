class SkillItem {
  final String name;
  final String description;
  final String tag;
  final List<String> subSkills;
  final String iconEmoji;

  const SkillItem({
    required this.name,
    required this.description,
    required this.tag,
    this.subSkills = const [],
    this.iconEmoji = '📦',
  });
}

const List<SkillItem> mockSkills = [
  SkillItem(
    name: '小红书爆款笔记生成器',
    description: '一键生成小红书风格的爆款笔记，包含标题、正文、标签，支持多种话题和场景模板',
    tag: '技能包',
    subSkills: ['标题生成', '正文润色', '标签推荐', '封面设计'],
    iconEmoji: '📝',
  ),
  SkillItem(
    name: '金融数据分析师',
    description: '专业金融数据分析技能，支持股票行情查询、基金分析、财报解读、投资建议等',
    tag: '技能包',
    subSkills: ['股票查询', '基金分析', '财报解读'],
    iconEmoji: '📈',
  ),
  SkillItem(
    name: 'AI视频创作工坊',
    description: '从脚本到成片，全流程AI视频创作。支持分镜设计、配音生成、字幕添加',
    tag: '技能包',
    subSkills: ['脚本生成', '配音', '字幕', '剪辑'],
    iconEmoji: '🎥',
  ),
  SkillItem(
    name: '法律知识助手',
    description: '提供法律条文查询、案例分析、合同审查等法律服务，覆盖民事、刑事、行政等领域',
    tag: '技能包',
    subSkills: ['条文查询', '合同审查', '案例检索'],
    iconEmoji: '⚖️',
  ),
  SkillItem(
    name: '科研论文助手',
    description: '辅助科研工作者进行文献检索、论文摘要、数据分析、图表生成等科研工作',
    tag: '技能包',
    subSkills: ['文献检索', '摘要生成', '数据分析'],
    iconEmoji: '🔬',
  ),
];

const List<String> skillCategories = [
  '全部', '自媒体', '金融', '法律', '互联网', '科研', '教育', '健康',
];
