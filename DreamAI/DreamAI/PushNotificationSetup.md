# Apple Push Notification Setup for DreamAI

This guide explains how to set up and use Apple Push Notification service (APNs) in the DreamAI app.

## Overview

The app is now configured to handle push notifications with the following features:
- Automatic permission requests
- Device token registration and display
- Notification handling in foreground and background
- Integrated notification settings in existing UI
- Easy device token copying for testing

## Files Added/Modified

### New Files:
1. `Core/Managers/PushNotificationManager.swift` - Main notification manager
2. `Core/Managers/AppDelegate.swift` - App delegate for notification callbacks
3. `Model/NotificationPayload.swift` - Notification payload structure

### Modified Files:
1. `DreamAIApp.swift` - Added AppDelegate and PushNotificationManager
2. `DreamAI.entitlements` - Added time-sensitive notifications capability
3. `Features/Permissions/Settings/View/PermissionsSettingsUI.swift` - Integrated notification toggle and device token display
4. `Features/Profile/View/UI/ProfileSettingsSection.swift` - Added notification toggle and device token copying

## Setup Instructions

### 1. Apple Developer Portal Setup

1. **Create Push Notification Certificate:**
   - Go to [Apple Developer Portal](https://developer.apple.com)
   - Navigate to Certificates, Identifiers & Profiles
   - Select your app identifier
   - Enable Push Notifications capability
   - Create a new certificate for APNs

2. **Download and Install Certificate:**
   - Download the `.p12` certificate
   - Install it in Keychain Access
   - Export as `.pem` file for server use

### 2. Xcode Project Configuration

1. **Capabilities:**
   - Ensure "Push Notifications" capability is enabled
   - Verify "Background Modes" includes "Remote notifications"

2. **Provisioning Profile:**
   - Update provisioning profile to include push notification entitlement
   - Ensure it matches your app identifier

## Getting Your Device Token

### Method 1: From Permissions Screen
1. Open the app and go through the permissions flow
2. Enable notifications using the toggle
3. The device token will be displayed below the wake-up time picker
4. Copy the full token for testing

### Method 2: From Profile Settings
1. Go to Profile → Settings
2. Tap on the notification row to copy the device token to clipboard
3. The token will be displayed in a shortened format with "..." suffix

## Using Apple's Notification Dashboard

Based on the [Apple documentation](https://developer.apple.com/documentation/usernotifications/sending-notification-requests-to-apns), here's how to send notifications:

### 1. Access the Dashboard
- Go to [Apple Developer Portal](https://developer.apple.com)
- Navigate to Certificates, Identifiers & Profiles
- Select your app identifier
- Click on "Push Notifications" section

### 2. Send a Test Notification
1. **Enter Device Token:** Paste the device token you copied from the app
2. **Format Payload:** Use one of the sample payloads below
3. **Send:** Click send to deliver the notification

### 3. Sample Payloads for Testing

#### Dream Reminder:
```json
{
  "aps": {
    "alert": {
      "title": "Time to Record Your Dream",
      "body": "Don't forget to capture today's dream before it fades away",
      "subtitle": "DreamAI Reminder"
    },
    "badge": 1,
    "sound": "default",
    "category": "DREAM_REMINDER",
    "thread-id": "dream-reminders"
  },
  "custom_data": {
    "type": "dream_reminder",
    "action": "create_dream"
  }
}
```

#### Interpretation Ready:
```json
{
  "aps": {
    "alert": {
      "title": "Dream Interpretation Ready",
      "body": "Your interpretation for 'Last Night's Dream' is now available",
      "subtitle": "DreamAI Analysis"
    },
    "badge": 1,
    "sound": "default",
    "category": "INTERPRETATION_READY",
    "thread-id": "interpretations"
  },
  "custom_data": {
    "type": "interpretation_ready",
    "action": "view_interpretation",
    "dream_title": "Last Night's Dream"
  }
}
```

#### Weekly Insights:
```json
{
  "aps": {
    "alert": {
      "title": "Weekly Dream Insights",
      "body": "Discover patterns and insights from your dreams this week",
      "subtitle": "DreamAI Weekly Report"
    },
    "badge": 1,
    "sound": "default",
    "category": "WEEKLY_INSIGHTS",
    "thread-id": "weekly-insights"
  },
  "custom_data": {
    "type": "weekly_insights",
    "action": "view_insights"
  }
}
```

## Implementation Details

### PushNotificationManager Features:
- **Permission Management:** Requests and tracks notification permissions
- **Token Registration:** Handles device token registration with APNs
- **Token Display:** Shows device token in UI for easy copying
- **Notification Handling:** Processes incoming notifications
- **Foreground Display:** Shows notifications even when app is active
- **Background Processing:** Handles notifications when app is in background

### UI Integration:
- **Permissions Screen:** Toggle for enabling notifications + device token display
- **Profile Settings:** Notification toggle + tap to copy device token
- **Real-time Status:** Shows registration status and authorization state

### Notification Categories:
The app defines these notification categories for different actions:
- `DREAM_REMINDER` - Daily dream recording reminders
- `INTERPRETATION_READY` - When dream analysis is complete
- `WEEKLY_INSIGHTS` - Weekly dream pattern reports

### Custom Data:
Each notification can include custom data for app-specific actions:
- `type` - Notification type identifier
- `action` - Action to perform when notification is tapped
- Additional context data as needed

## Testing Workflow

1. **Enable Notifications:**
   - Open app and go to permissions screen
   - Toggle notifications on
   - Grant permission when prompted

2. **Get Device Token:**
   - Copy the device token from the permissions screen
   - Or tap the notification row in profile settings

3. **Send Test Notification:**
   - Go to Apple Developer Portal
   - Use the notification dashboard
   - Paste device token and payload
   - Send notification

4. **Verify Reception:**
   - Check if notification appears on device
   - Verify app handles notification properly
   - Test both foreground and background scenarios

## Troubleshooting

### Common Issues:

1. **Device token not available:**
   - Ensure notifications are enabled in app
   - Check internet connection
   - Verify APNs certificate is valid
   - Ensure app has proper entitlements

2. **Notifications not appearing:**
   - Check notification permissions in Settings
   - Verify device token is correct
   - Ensure app is not in Do Not Disturb mode
   - Check notification payload format

3. **Background notifications not working:**
   - Verify "Remote notifications" background mode is enabled
   - Check that notification payload includes required fields
   - Ensure app is properly registered for background processing

### Debug Information:
- Device token is displayed in both permissions and profile screens
- Registration status is shown in real-time
- Console logs show detailed registration and notification events
- Tap notification row in profile to copy token to clipboard

## Next Steps

1. **Backend Integration:** Implement server-side token storage and notification sending
2. **Analytics:** Track notification engagement and effectiveness
3. **Personalization:** Allow users to customize notification preferences
4. **Rich Notifications:** Add images and interactive buttons to notifications

## Resources

- [Apple Push Notification Service Documentation](https://developer.apple.com/documentation/usernotifications)
- [APNs HTTP/2 API](https://developer.apple.com/documentation/usernotifications/sending-notification-requests-to-apns)
- [Push Notification Best Practices](https://developer.apple.com/design/human-interface-guidelines/ios/user-interaction/notifications/) 