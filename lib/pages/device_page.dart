import 'package:flutter/material.dart';
import '../theme/coze_colors.dart';
import '../theme/coze_theme.dart';
import '../models/device_item.dart';

class DevicePage extends StatelessWidget {
  const DevicePage({super.key});

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
        title: const Text('设备',
            style: TextStyle(
                fontSize: CozeFontSize.s18,
                fontWeight: FontWeight.bold,
                color: CozeColors.fgPrimary)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, size: 24, color: CozeColors.fgPrimary),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(CozeSpacing.lg, CozeSpacing.lg, CozeSpacing.lg, CozeSpacing.sm),
            child: Text('个人设备',
                style: TextStyle(fontSize: CozeFontSize.s14, color: CozeColors.fgDim)),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: CozeSpacing.lg),
              itemCount: mockDevices.length,
              separatorBuilder: (_, __) => const SizedBox(height: CozeSpacing.sm),
              itemBuilder: (context, index) => _buildDeviceCard(mockDevices[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceCard(DeviceItem device) {
    return Container(
      padding: const EdgeInsets.all(CozeSpacing.md),
      decoration: BoxDecoration(
        color: CozeColors.bgMax,
        borderRadius: CozeRadius.xxlBorder,
        border: Border.all(color: CozeColors.tagGray),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: CozeColors.chipGray,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(child: Text(device.iconEmoji, style: const TextStyle(fontSize: 20))),
          ),
          const SizedBox(width: CozeSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(device.name,
                          style: const TextStyle(
                              fontSize: CozeFontSize.s16,
                              fontWeight: FontWeight.bold,
                              color: CozeColors.fgPrimary)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: CozeSpacing.sm, vertical: 2),
                      decoration: BoxDecoration(
                        color: CozeColors.tagGray,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(device.status,
                          style: const TextStyle(
                              fontSize: CozeFontSize.s12,
                              color: CozeColors.bgMax,
                              fontWeight: FontWeight.w500)),
                    ),
                  ],
                ),
                const SizedBox(height: CozeSpacing.xs),
                Text(device.system,
                    style: const TextStyle(fontSize: CozeFontSize.s14, color: CozeColors.dimText)),
                const SizedBox(height: CozeSpacing.xs),
                const Text('详情 >',
                    style: TextStyle(fontSize: CozeFontSize.s14, color: CozeColors.dimText)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
