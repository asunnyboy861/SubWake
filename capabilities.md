# Capabilities Configuration

## Analysis
Based on operation guide analysis:
- "提醒" / "notification" / "alert" -> Push Notifications required
- "同步" / "sync" / "iCloud" -> iCloud capability required
- "家人" / "family" / "共享" / "share" -> iCloud + Family Sharing
- No health, camera, location, or watch features detected
- No in-app purchase (one-time paid download model)

## Auto-Configured Capabilities
| Capability | Status | Method |
|------------|--------|--------|
| Push Notifications | Configured | Xcode project (INFOPLIST key) |
| iCloud (CloudKit) | Configured | Xcode project (entitlements) |

## Manual Configuration Required
| Capability | Status | Steps |
|------------|--------|-------|
| iCloud Container | Pending | 1. Open Xcode > Signing & Capabilities > + Capability > iCloud 2. Check CloudKit 3. Create container: iCloud.com.zzoutuo.SubWake 4. Deploy to production in CloudKit Dashboard |
| Push Notifications Entitlement | Pending | 1. Open Xcode > Signing & Capabilities > + Capability > Push Notifications 2. Xcode will generate entitlements file automatically |

## No Configuration Needed
- HealthKit: Not required
- Camera/Photo Library: Not required
- Location Services: Not required
- Apple Watch: Not required
- Siri: Not required
- In-App Purchase: Not required (one-time paid download)
- Background Modes: Not required (local notifications only)

## Verification
- Build succeeded after configuration: Pending
- All entitlements correct: Pending
