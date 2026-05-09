# TodoBar

**贴边而栖，召之即来。**

TodoBar 是一款 macOS 原生待办事项应用，以侧边栏形态常驻屏幕右缘。不占地盘、不挡视线，光标靠近时悄然滑入，移开后徐徐收回——你的任务始终触手可及，却从不打扰。

## 截图

<p align="center">
  <img src="screenshots/todo-panel.png" width="360" alt="TodoBar 任务面板" />
</p>

## 为什么做 TodoBar

市面上的待办应用，要么藏在 Dock 里需要切换，要么悬浮在桌面上碍手碍脚。TodoBar 选择另一种路径：**贴边隐匿**。它像 macOS 控制中心一样，屏幕边缘只露出一个精致的小把手，鼠标靠近时面板丝滑展开，离开后自动收起。不需要的时候，它几乎不存在。

## 功能一览

### 核心任务管理

- **今天 / 月计划** 双分区，日常与长远一目了然
- **自定义清单** 随时新建，按需归类
- **拖拽排序** 按住任务即可拖动重排，被拖项即时跟手，兄弟项 spring 让位
- **双击勾选** 可选模式，双击任务行直接切换完成状态
- **聚焦标记** 圆点标记重要任务，一眼定位优先级
- **今日进度** 顶部进度条实时显示当日完成率

### 侧边栏交互

- **贴边把手** 屏幕右侧浮动的侧边栏按钮，点击展开/收起面板
- **拖拽定位** 按住把手上下拖动，调整面板垂直位置
- **自动显示/隐藏** 鼠标靠近把手自动展开，离开后自动收起（可在设置中开关）
- **Slide + Blur 过渡** 面板以偏移 + 模糊 + 透明度三层联动的 Web 风格动画进出，与把手移动完美同步

### 设置面板

设置分为「通用」和「界面」两个标签页，覆盖所有可调参数：

**通用**
| 设置项 | 说明 |
|--------|------|
| 外观 | 浅色 / 深色主题切换，按钮颜色自动反转 |
| 语言 | 中文 / English，切换后界面即时翻译 |
| 双击整行勾选 | 开关：双击任务行切换完成状态 |
| 自动显示/隐藏 | 开关：鼠标靠近把手时自动展开面板 |
| 登录时启动 | 开关：开机自启 |

**界面**
| 设置项 | 范围 | 说明 |
|--------|------|------|
| 面板宽度 | 300–460 px | 侧边面板的整体宽度 |
| 可见标签 | 18–76 px | 收起时把手的可见宽度 |
| 按钮高度 | 52–128 px | 把手的垂直尺寸 |
| 垂直位置 | 8–68 % | 把手在屏幕上的垂直位置 |
| 行高 | 38–62 px | 每条任务的高度 |
| 行距 | 4–16 px | 任务之间的间距 |
| 文字大小 | 11–15 px | 任务文字尺寸 |
| 动效 | 80–520 ms | 动画时长，越小越快 |
| 圆角 | 10–30 px | 面板和卡片的圆角半径 |
| 表面 | 78–100 % | 面板背景不透明度 |

## UI 风格

TodoBar 的视觉语言刻意远离 macOS 原生控件的传统蓝灰调性，转而追求一种**克制但有态度**的设计感。

### 色彩体系：WebTheme

整个应用使用自建的 `WebTheme` 色彩系统，而非 Apple 系统色。两套主题各 7 个语义色值，通过 SwiftUI Environment 注入全局：

| 语义色             | 浅色模式      | 深色模式      | 用途              |
| --------------- | --------- | --------- | --------------- |
| `surface`       | `#FFFFFF` | `#16171A` | 面板主背景           |
| `surfaceSoft`   | `#F6F6F6` | `#202126` | 次级背景（进度条、未选中按钮） |
| `surfaceRaised` | `#FFFFFF` | `#181920` | 卡片/设置组浮起背景      |
| `ink`           | `#10111E` | `#F4F5F6` | 主文字、选中态         |
| `muted`         | `#777B84` | `#A4A8B0` | 辅助文字、未激活态       |
| `line`          | `#DEDFE2` | `#33363D` | 分割线、边框          |
| `lineStrong`    | `#C9CBD1` | `#4A4D55` | 悬浮边框、勾选框描边      |

这套配色的核心思路：**墨色为骨，灰线为界**。浅色模式下纯白底 + 墨黑字 + 冷灰线，深色模式下反转但保持同等对比度。不使用蓝色、绿色等语义色作为交互色——选中态就是黑白翻转，干脆利落。

### 按钮：五态流体交互

所有交互按钮遵循 **FluidButtonStyle**，覆盖五个完整状态：

| 状态       | 视觉反馈                                         |
| -------- | -------------------------------------------- |
| Default  | 透明背景，正常尺寸                                    |
| Hover    | 背景 `ink.opacity(0.05)` 浮现，轻微放大 1.02x，光标变手型   |
| Press    | 背景 `ink.opacity(0.12)` 加深，缩小 0.96x，透明度降至 0.9 |
| Focus    | 1.5px 描边 `ink.opacity(0.2)`                  |
| Disabled | 整体透明度 0.4                                    |

状态之间的切换使用 `spring(response: 0.2, dampingFraction: 0.7)` 按压回弹 + `easeOut(0.15)` 悬浮过渡，手感介于物理按键和触摸屏之间。

删除按钮（`ProMaxDeleteButtonStyle`）同样五态，但色系切换为红色，hover 时图标变红，按压时红底浮出。

### 开关：黑白色系

`BlackToggleStyle` 完全弃用 macOS 原生蓝色开关。开启态浅色模式为墨黑轨道 + 白色圆钮，深色模式为白色轨道 + 黑色圆钮——选中色始终与背景反转。关闭态淡灰底，深色模式圆钮为浅灰以降低对比。切换时圆钮以 spring 动画滑入。

### 设置按钮：黑白色块

标签页切换（通用 / 界面）、主题切换（浅色 / 深色）、语言切换（中文 / EN）均使用统一的黑白色块按钮——选中态浅色模式黑底白字、深色模式白底黑字，未选中态灰底 + 描边。不使用系统 segmented picker，不使用蓝色。

### 任务行：GlassRow 卡片

每条任务行使用 `glassRow` 样式：`surfaceRaised` 填充 + `line` 描边 + 轻微底部阴影，形成浮起感。悬浮时描边加深 + 整行上移 1px，删除按钮从右侧淡入。

### 动画哲学

TodoBar 的动画遵循三条原则：

1. **Web 式 Slide + Blur**：面板进出不是简单的 alpha 渐变，而是水平偏移 + 高斯模糊 + 透明度三参数联动，模拟 Web 端的 `transform + filter` 过渡
2. **Spring 物理**：所有交互动画使用 SwiftUI spring，`dampingFraction: 0.78` 提供恰到好处的回弹，不过弹也不死板
3. **同色系阴影**：浅色模式下阴影色使用 `theme.line` 而非 `black.opacity()`，消除白底上的"透明介质"光晕——阴影与背景同色系，视觉上消失但保留浮起感

### 透明窗口：零介质渲染

TodoBar 的面板窗口和把手浮层均为完全透明的 NSPanel。要实现"悬浮在桌面上、没有白色底衬"的效果，需要在 AppKit 层做大量处理：

- `NSPanel` 设置 `isOpaque = false` + `backgroundColor = .clear` + `hasShadow = false`
- `NSHostingView.layer.isOpaque = false` —— 防止 Core Animation 渲染白色底层
- 递归清空整个视图层级背景（包括 `NSTitlebarContainerView`）
- 使用 `.compositingGroup()` 防止描边抗锯齿在透明底上出血
- NSPanel frame 额外预留 `shadowBleed` 空间，防止阴影被裁剪

## 技术架构

```
TodoBar (SPM)
├── Sources/TodoBar/           # App 层
│   ├── App/
│   │   └── TodoBarApp.swift   # 入口，WindowGroup + AppDelegate
│   ├── Stores/
│   │   └── TodoStore.swift    # @MainActor ObservableObject，防抖持久化
│   └── Views/
│       ├── ContentView.swift          # 面板主体 + 把手 + 透明窗口配置
│       ├── TodoPanelView.swift        # 任务列表 + 拖拽排序
│       ├── SettingsView.swift         # 设置面板（通用 / 界面）
│       ├── FluidButtonStyle.swift     # 五态按钮 + 黑白开关
│       └── L.swift                    # i18n 字典映射
├── Sources/TodoBarCore/       # 核心模型层（独立 library）
│   └── TodoModels.swift       # TodoBoard / TodoTask / TodoSettings / TodoSection
├── Resources/
│   └── AppIcon.iconset/       # 应用图标
└── script/
    └── build_and_run.sh       # 构建 + 打包 .app + 启动
```

### 关键技术决策

| 决策    | 选型                            | 原因                                        |
| ----- | ----------------------------- | ----------------------------------------- |
| UI 框架 | SwiftUI + AppKit              | SwiftUI 布局 + AppKit 窗口级控制                 |
| 浮动把手  | 独立 NSPanel                    | WindowGroup 无法脱离主窗口独立浮动                   |
| 透明窗口  | NSPanel + 递归背景清空              | 系统默认半透明背景会形成白色介质                          |
| 数据持久化 | UserDefaults + JSONEncoder    | 轻量，无需数据库                                  |
| 保存策略  | 300ms 防抖                      | 拖拽排序期间不阻塞主线程                              |
| 动画驱动  | 纯 SwiftUI offset/blur/opacity | 避免与 NSAnimationContext 冲突                 |
| 把手动画  | CAMediaTimingFunction         | NSPanel frame 动画需显式贝塞尔曲线对齐 SwiftUI spring |

## 构建与运行

### 前置要求

- macOS 14.0 (Sonoma) 及以上
- Xcode 15.0 及以上（含 Swift 5.9+）
- Command Line Tools

### 一键构建启动

```bash
bash script/build_and_run.sh
```

脚本会自动完成：停止旧进程 → SwiftPM 编译 → 打包 `.app` → 生成图标 → 启动应用。

### 其他模式

```bash
bash script/build_and_run.sh --logs       # 启动并实时查看日志
bash script/build_and_run.sh --telemetry  # 启动并查看遥测日志
bash script/build_and_run.sh --verify     # 启动并验证进程
bash script/build_and_run.sh --debug      # 启动并在 lldb 中调试
```

### 手动构建

```bash
swift build --product TodoBar
```

## 开发

项目使用 Swift Package Manager 管理，无额外依赖。核心模型 `TodoBarCore` 作为独立 library，与 App 层解耦，方便复用和测试。

```bash
# 运行测试
swift test

# 类型检查
swift build
```

## 许可证

MIT
