# Coze Replica

Flutter replica of the Coze App with pixel-perfect UI matching the real design system.

## Design System
- Colors extracted from Coze APK CSS reverse engineering
- Spacing, radius, typography tokens matching real app
- Light theme fully implemented

## Pages
- **Home**: User bar + credits banner + quick actions + chat list
- **Skill Store**: Tab switching + category chips + skill cards
- **Device Management**: Device cards with status
- **Chat**: AI message bubbles + attachment menu + press-to-talk input

## Build
```bash
flutter build apk
flutter build ios --no-codesign
```
