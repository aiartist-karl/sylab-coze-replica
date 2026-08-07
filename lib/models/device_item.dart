class DeviceItem {
  final String name;
  final String system;
  final String status;
  final String iconEmoji;

  const DeviceItem({
    required this.name,
    required this.system,
    required this.status,
    this.iconEmoji = '📱',
  });
}

const List<DeviceItem> mockDevices = [
  DeviceItem(
    name: 'iPhone 15 Pro',
    system: 'iOS 17.4',
    status: '离线',
    iconEmoji: '📱',
  ),
  DeviceItem(
    name: 'MacBook Air M3',
    system: 'macOS Sonoma 14.3',
    status: '离线',
    iconEmoji: '💻',
  ),
  DeviceItem(
    name: 'Pixel Watch 2',
    system: 'Wear OS 4',
    status: '离线',
    iconEmoji: '⌚',
  ),
];
