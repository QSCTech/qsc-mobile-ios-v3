# 求是潮手机站 V3 for iOS

## Tech

- IDE：Xcode 8
- 语言：Swift 3
- 操作系统：iOS 9+
- 包管理器：Carthage
- 版本发布：fastlane

## Usage

- 使用 Carthage 获取本项目依赖的第三方库：

```
carthage bootstrap --platform iOS --no-use-binaries
```

- 如果上一步编译不成功，可以考虑使用预编译的 https://git.zjuqsc.com/yzyzsun/third-party-frameworks/branches 对应分支覆盖 Carthage/Build/iOS 下的 framework 文件
- 建议使用最新版本的 Xcode 编译运行
- fastlane 的使用参见 [fastlane/README.md](fastlane/README.md)
