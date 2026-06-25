# 設計：Handler 優先 + 套件兜底（v-next）

評價邀請在「使用者同意評分」後的處理，採兩層責任鏈：

- **使用者自訂 handler（最高優先）**：有設就交給使用者管，套件不接手。
- **套件預設處理（兜底）**：使用者沒設 handler、或 handler「交還」時，由套件逐平台處理
  （`system` 原生評分 / `storeListing` 直接開商店頁，缺資訊自動退回）。

仿 HTML `onclick="return handler();"`：使用者 handler 的回傳值決定「停手」或「交還套件繼續」。

---

## 1. 平台限制（設計動機）

| 平台 | 原生 `requestReview()` | 直接開商店 `openStoreListing()` |
|------|------------------------|-------------------------------|
| iOS / macOS | `SKStoreReviewController`，每 365 天約 3 次、超過靜默、**無法偵測**是否顯示；TestFlight 常不顯示 | **需 App Store 數字 id**；需 app 已上架 |
| Android | Play In-App Review，有配額、超過靜默、不可偵測 | 不需 id，用 applicationId（套件名）自動開 Play 頁 |
| Windows | — | 需 `microsoftStoreId` |

- 偵測「是否被節流」不可行 → 明確點擊評分時「直接開商店頁」較可靠。
- iOS 需 id 而 Android 不需要、上架狀態也可能不同 → 行為應可**逐平台**設定。
- 啟用 storeListing 卻缺 id（或未上架）→ 至少退回 `requestReview()`，不要「按了沒反應」。

---

## 2. 責任鏈

```
使用者同意評分
   │
   ├─ 有設 onReviewRequest（使用者 handler）？
   │      └─ 執行 → 看回傳值：
   │             • true（已處理，停手）  → 結束，套件不接手
   │             • false（交還套件繼續） → 往下走套件預設
   │
   └─ 沒設 handler，或 handler 回傳 false
          └─ 套件預設處理（逐平台 system / storeListing，缺資訊 fallback）
```

---

## 3. 使用者 handler 契約

```dart
/// 使用者自訂「同意評分後」的處理。
/// 回傳值決定流程：
///   true  ＝ 已處理完、請「停手」（套件不再跑預設）
///   false ＝ 做完了但「交還」套件，請接著跑套件預設（逐平台）
typedef ReviewRequestHandler = FutureOr<bool> Function(ReviewContext ctx);

class ReviewContext {
  final TargetPlatform platform;   // 目前平台，讓 handler 分流
  final String appVersion;
  /// 便利：handler 內想「先做自己的事、再請套件去商店」時呼叫；呼叫後通常 return true。
  final Future<void> Function() runPackageDefault;
  const ReviewContext({
    required this.platform,
    required this.appVersion,
    required this.runPackageDefault,
  });
}
```

範例：

```dart
// (a) 完全自管：做完 return true（套件停手）
onReviewRequest: (ctx) async { await myFlow(); return true; },

// (b) 先記事件、再交還套件去商店
onReviewRequest: (ctx) async { log('agreed'); return false; },

// (c) iOS 自管、Android 交給套件
onReviewRequest: (ctx) async {
  if (ctx.platform == TargetPlatform.iOS) { await myIos(); return true; }
  return false;
},
```

---

## 4. 套件預設處理（兜底）：逐平台 + 缺資訊 fallback

```dart
enum ReviewMode { system, storeListing }

class PlatformReviewConfig {
  final ReviewMode mode;
  /// storeListing 所需商店識別：
  /// - iOS/macOS：App Store 數字 id（必填，缺→退回 system）
  /// - Android：applicationId（可選，null＝自動套件名）
  /// - Windows：microsoftStoreId（必填，缺→退回 system）
  final String? storeId;
  const PlatformReviewConfig.system() : mode = ReviewMode.system, storeId = null;
  const PlatformReviewConfig.storeListing({this.storeId}) : mode = ReviewMode.storeListing;
}
```

掛進 `ReviewConfig`（iOS / Android 獨立、皆預設 system＝向下相容）：

```dart
ReviewConfig(
  appVersion: ...,
  minUsageTime: ...,
  onReviewRequest: ...,                 // 可選：使用者 handler（最高優先）
  ios:     const PlatformReviewConfig.storeListing(storeId: '...'),
  android: const PlatformReviewConfig.system(),   // 兩平台可不同
)
```

解析 / fallback：
- `mode == system` → `requestReview()`。
- `mode == storeListing`：
  - iOS/macOS：有 `storeId` → `openStoreListing(appStoreId: storeId)`；**無 → 退回 `requestReview()` + 警告**。
  - Android：`openStoreListing()`（有 applicationId 用之、否則自動套件名）。
  - Windows：有 `microsoftStoreId` → 開商店；無 → 退回 `requestReview()`。
  - `openStoreListing` 丟例外（如未上架 404）→ 退回 `requestReview()`。

行為對照：

| 平台 | mode | store id | 行為 |
|------|------|----------|------|
| iOS | system | — | `requestReview()` |
| iOS | storeListing | 有 | `openStoreListing(appStoreId)` |
| iOS | storeListing | 無 | fallback `requestReview()` + 警告 |
| Android | system | — | `requestReview()` |
| Android | storeListing | 無/有 | `openStoreListing()`（自動套件名 / 指定值） |
| Windows | storeListing | 無 id | fallback `requestReview()` |

---

## 5. 解析流程（pseudo）

```dart
Future<void> _onAgree(ReviewContext ctx) async {
  final h = config.onReviewRequest;
  if (h != null) {
    if (await h(ctx)) return;            // true＝停手
  } else if (config.onReviewRequested != null) {
    await config.onReviewRequested!();   // legacy（void）＝視為已處理
    return;
  }
  await _runPackageDefault(ctx);         // 兜底：逐平台 system / storeListing + fallback
}
```

---

## 6. 向下相容
- 既有 `onReviewRequested`（`Future<void>`）保留：視為「已處理（停手）」，等同舊版「使用者全自管」。
  可標 `@Deprecated('改用 onReviewRequest 回傳 bool，或設 ios/android 由套件兜底')`。
- 三者皆未設（無 handler、無 ios/android）→ 兩平台預設 `system`（行為等同舊版）。

---

## 7. 待辦 / 命名待定
- [ ] `onReviewRequest` 回傳 `bool`（handled）語意是否夠清楚，或改回傳 `enum ReviewFlow { stop, fallThrough }`。
- [ ] `ReviewContext.runPackageDefault` 是否外露。
- [ ] Android Play In-App Review 配額/靜默/偵測限制的最新官方描述。
- [ ] `openStoreListing` 在無 Google Play 服務裝置（含部分 ROM）的行為與 fallback。
- [ ] 命名：`storeId` vs 平台專屬欄位；`ios`/`android` 欄位 vs `Map<TargetPlatform, PlatformReviewConfig>`。
- [ ] `markEngagement()` API：把「使用時間補到門檻、立即重判」正式化（取代 `debugSimulateUsage` 權宜）。
- [ ] macOS / Windows 路徑（mac App Store id、`microsoftStoreId`）。
