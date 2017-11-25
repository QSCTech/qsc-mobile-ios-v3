# 求是潮手机站 V3 for iOS

![Logo](QSCMobileV3/Assets.xcassets/AppIcon.appiconset/Icon-60@3x.png)

## 技术

- IDE：Xcode 9.1
- 语言：Swift 4.0.2
- 操作系统：iOS 9+, watchOS 2+
- 包管理器：Carthage
- 版本发布：fastlane

## 使用

- 从 GitLab 将本项目克隆到本地
- 在项目根目录下，使用 Carthage 获取本项目依赖的第三方库：

```
brew install carthage
carthage bootstrap --platform iOS --no-use-binaries
```

- 建议使用最新版本的 Xcode 编译运行
- fastlane 的使用参见 [fastlane/README.md](fastlane/README.md)

## 贡献

- 本项目的默认分支为 `master`，这个分支会停在最近一个发布的版本上，同时这也是一个[保护分支](/help/user/project/protected_branches)
- 开发分支为 `dev`，这个分支的所有提交都会在下一个版本发布
- 如果希望贡献代码，请基于 `master` 创建一个自己的分支，并在完成时向 `dev` 提交 Merge Request
