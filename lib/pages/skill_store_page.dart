import 'package:flutter/material.dart';
import '../theme/coze_colors.dart';
import '../theme/coze_theme.dart';
import '../models/skill_item.dart';

class SkillStorePage extends StatefulWidget {
  const SkillStorePage({super.key});

  @override
  State<SkillStorePage> createState() => _SkillStorePageState();
}

class _SkillStorePageState extends State<SkillStorePage> {
  int _selectedTab = 0;
  int _selectedCategory = 0;

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
        title: const Text('技能商店',
            style: TextStyle(
                fontSize: CozeFontSize.s18,
                fontWeight: FontWeight.bold,
                color: CozeColors.fgPrimary)),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, size: 22, color: CozeColors.fgDim),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 22, color: CozeColors.fgDim),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          _buildTabBar(),
          _buildCategoryChips(),
          Expanded(child: _buildSkillList()),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: CozeSpacing.lg, vertical: CozeSpacing.sm),
      decoration: BoxDecoration(
        color: const Color(0xFFE0E0E0),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [_tabItem('精选', 0), _tabItem('我的技能', 1)],
      ),
    );
  }

  Widget _tabItem(String label, int index) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: CozeSpacing.sm),
          decoration: BoxDecoration(
            color: isSelected ? CozeColors.bgMax : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [const BoxShadow(color: Color(0x0A000000), offset: Offset(0, 1), blurRadius: 3)]
                : null,
          ),
          child: Center(
            child: Text(label,
                style: TextStyle(
                    fontSize: CozeFontSize.s14,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: CozeColors.fgPrimary)),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChips() {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: CozeSpacing.lg),
        itemCount: skillCategories.length,
        separatorBuilder: (_, __) => const SizedBox(width: CozeSpacing.sm),
        itemBuilder: (context, index) {
          final isSelected = _selectedCategory == index;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = index),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: CozeSpacing.lg, vertical: CozeSpacing.sm),
              decoration: BoxDecoration(
                color: isSelected ? CozeColors.tagDark : CozeColors.bgMax,
                borderRadius: CozeRadius.pillBorder,
                border: isSelected ? null : Border.all(color: CozeColors.strokePrimary),
              ),
              child: Center(
                child: Text(skillCategories[index],
                    style: TextStyle(
                        fontSize: CozeFontSize.s14,
                        color: isSelected ? Colors.white : CozeColors.fgPrimary,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal)),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSkillList() {
    return ListView.separated(
      padding: const EdgeInsets.all(CozeSpacing.lg),
      itemCount: mockSkills.length,
      separatorBuilder: (_, __) => const SizedBox(height: CozeSpacing.md),
      itemBuilder: (context, index) => _buildSkillCard(mockSkills[index]),
    );
  }

  Widget _buildSkillCard(SkillItem skill) {
    return Container(
      padding: const EdgeInsets.all(CozeSpacing.md),
      decoration: BoxDecoration(
        color: CozeColors.cardGray,
        borderRadius: CozeRadius.xxlBorder,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: CozeColors.bgSecondary,
              borderRadius: CozeRadius.xlBorder,
            ),
            child: Center(child: Text(skill.iconEmoji, style: const TextStyle(fontSize: 32))),
          ),
          const SizedBox(width: CozeSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(skill.name,
                    style: const TextStyle(
                        fontSize: CozeFontSize.s16,
                        fontWeight: FontWeight.bold,
                        color: CozeColors.fgPrimary)),
                const SizedBox(height: CozeSpacing.xs),
                Text(skill.description,
                    style: const TextStyle(
                        fontSize: CozeFontSize.s14, color: CozeColors.fgDim, height: 1.4),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: CozeSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: CozeSpacing.sm, vertical: 2),
                  decoration: BoxDecoration(
                    color: CozeColors.tagGray,
                    borderRadius: CozeRadius.pillBorder,
                  ),
                  child: Text(skill.tag,
                      style: const TextStyle(fontSize: CozeFontSize.s10, color: CozeColors.fgDim)),
                ),
                const SizedBox(height: CozeSpacing.sm),
                Wrap(
                  spacing: CozeSpacing.xs,
                  runSpacing: CozeSpacing.xs,
                  children: skill.subSkills
                      .map((s) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: CozeSpacing.sm, vertical: 3),
                            decoration: BoxDecoration(
                              border: Border.all(color: CozeColors.strokePrimary),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(s,
                                style: const TextStyle(
                                    fontSize: CozeFontSize.s10, color: CozeColors.fgDim)),
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
