# 求是潮手机站 V3 for watchOS

![Logo](QSCMobileV3/Assets.xcassets/AppIcon.appiconset/Icon-60@3x.png)

## Tech

- IDE：Xcode 9
- 语言：Swift 4
- 操作系统：watchOS 2.0+
- 包管理器：Carthage
- 版本发布：fastlane

### Life cycle
#### awake(withContext:)
- 保留
#### willActivate()
- 通过 WatchConnectivity 的 `sendMessage(_:replyHandler:errorHandler:)` 向 iOS 端发起获取事件请求
- 处理返回的请求，并在 DispatchQueue.main 上更新显示界面

### Get events
#### reqeust(eventsFor:)
- 参数 Date

## Usage

- 使用 Carthage 获取本项目依赖的第三方库：

```
carthage bootstrap --platform iOS --no-use-binaries
```

- 如果上一步编译不成功，可以考虑使用预编译的 https://git.zjuqsc.com/yzyzsun/third-party-frameworks/branches 对应分支覆盖 Carthage/Build/iOS 下的 framework 文件
- 建议使用最新版本的 Xcode 编译运行
- fastlane 的使用参见 [fastlane/README.md](fastlane/README.md)
