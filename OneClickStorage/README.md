# One Click Storage Mod - 一键入箱模组

## 简介 Description

这是一个独立的饥荒（Don't Starve）模组，为游戏添加了一键入箱功能。该功能灵感来源于Taxue模组，现在作为独立模组提供，兼容多种容器类型。

This is a standalone Don't Starve mod that adds one-click storage functionality. Inspired by the Taxue mod, it now works as an independent mod compatible with multiple container types.

## 功能特性 Features

### 核心功能 Core Features
- **一键入箱**: 按下快捷键，自动将物品存入附近的箱子
- **智能识别**: 只存放箱子中已有类型的物品
- **多容器支持**: 同时处理多个附近的容器
- **背包支持**: 同时处理玩家物品栏和背包中的物品
- **地面物品**: 可选择是否收集地面上的物品

### One-Click Storage Features
- **Quick Storage**: Press hotkey to automatically store items into nearby containers
- **Smart Detection**: Only stores items that match existing items in containers
- **Multi-Container**: Processes multiple nearby containers simultaneously
- **Backpack Support**: Handles both inventory and backpack items
- **Floor Items**: Optional collection of items from the ground

## 兼容性 Compatibility

### 支持的容器 Supported Containers
1. **Portable Cellar (便携地窖)** - 完全兼容Portable Cellar模组
2. **Vanilla Chest (原版箱子)** - 支持游戏原版的箱子
3. **Vanilla Ice Box (原版冰箱)** - 支持游戏原版的冰箱

### 游戏版本 Game Versions
- Don't Starve (饥荒)
- Reign of Giants (巨人统治)
- Shipwrecked (海难)
- Hamlet (哈姆雷特)

注意: 此模组不支持 Don't Starve Together (联机版)
Note: This mod does NOT support Don't Starve Together

## 配置选项 Configuration Options

### 按键设置 Key Binding
- **默认按键**: Z
- **可选按键**: R, T, Y, U, G, H, J, Z, X, C, V, B, N, K, L, O, P

### 搜索范围 Search Range
- **可选范围**: 10, 15, 20, 25, 30
- **默认值**: 20

### 功能开关 Feature Toggles
- **包含地面物品**: 是否收集地面物品 (默认: 是)
- **支持便携地窖**: 是否兼容Portable Cellar (默认: 是)
- **支持原版箱子**: 是否兼容原版箱子 (默认: 是)
- **支持原版冰箱**: 是否兼容原版冰箱 (默认: 是)

## 使用方法 Usage

1. **启动模组**: 在游戏模组菜单中启用本模组
2. **配置按键**: 在模组配置中设置你喜欢的快捷键
3. **准备容器**: 在容器中放入至少一种物品作为"模板"
4. **触发功能**: 站在容器附近，按下配置的快捷键
5. **完成存储**: 模组会自动将匹配的物品存入容器

### Steps to Use
1. **Enable Mod**: Enable this mod in the game's mod menu
2. **Configure Key**: Set your preferred hotkey in mod configuration
3. **Prepare Container**: Place at least one item type in container as "template"
4. **Trigger Function**: Stand near containers and press the configured hotkey
5. **Complete Storage**: The mod automatically stores matching items

## 工作原理 How It Works

### 存储逻辑 Storage Logic
1. **扫描容器**: 查找指定范围内的所有有效容器
2. **识别模板**: 读取容器中已有的物品类型
3. **匹配物品**: 在玩家物品栏、背包和地面查找匹配的物品
4. **智能堆叠**: 优先堆叠到已有物品，再占用空格子
5. **反馈信息**: 通过角色对话显示操作结果

### Process Flow
1. **Scan Containers**: Find all valid containers within range
2. **Read Template**: Read existing item types in containers
3. **Match Items**: Find matching items in inventory, backpack, and ground
4. **Smart Stacking**: Stack to existing items first, then use empty slots
5. **Feedback**: Show operation results through character dialogue

## 实现细节 Implementation Details

### 基于Taxue模组 Based on Taxue Mod
本模组的核心功能改编自Taxue模组的一键入箱机制，主要改进包括:
- 独立模组架构，不依赖特定人物
- 扩展容器支持，兼容原版容器
- 优化代码结构，提高可维护性
- 增加配置选项，提供更好的自定义体验

This mod's core functionality is adapted from Taxue mod's one-click storage mechanism, with improvements including:
- Standalone architecture, no character dependency
- Extended container support for vanilla containers
- Optimized code structure for better maintainability
- Added configuration options for better customization

### 技术特性 Technical Features
- 支持可堆叠和不可堆叠物品
- 处理物品腐烂度保持
- 容器满时智能部分堆叠
- 排除特殊物品(如super_package)
- 视觉反馈特效

## 安装方法 Installation

1. 下载模组文件夹 `OneClickStorage`
2. 将文件夹放入游戏的 `mods` 目录
3. 启动游戏并在模组菜单中启用

1. Download the `OneClickStorage` folder
2. Place the folder in the game's `mods` directory
3. Launch the game and enable the mod in the mods menu

## 已知问题 Known Issues

- 图标文件为占位文件，需要替换为实际图标
- 某些特殊容器可能不被识别(可通过配置禁用)

- Icon files are placeholders, need to be replaced with actual icons
- Some special containers might not be recognized (can be disabled in config)

## 更新日志 Changelog

### v1.0 (2025-01-13)
- 初始版本发布
- 实现核心一键入箱功能
- 支持Portable Cellar、原版箱子和冰箱
- 添加完整配置选项

### v1.0 (2025-01-13)
- Initial release
- Implemented core one-click storage functionality
- Support for Portable Cellar, vanilla chest and ice box
- Added full configuration options

## 致谢 Credits

- **原始实现**: Taxue模组作者
- **模组改编**: 基于Taxue模组的一键入箱功能
- **Portable Cellar**: 感谢iceamei的Portable Cellar模组

- **Original Implementation**: Taxue mod author
- **Mod Adaptation**: Based on Taxue mod's one-click storage feature
- **Portable Cellar**: Thanks to iceamei for Portable Cellar mod

## 许可 License

本模组基于Taxue模组的实现进行改编，仅供学习和个人使用。

This mod is adapted from Taxue mod's implementation, for learning and personal use only.

## 支持 Support

如有问题或建议，请在相关论坛发帖讨论。

For issues or suggestions, please post in relevant forums.

---

享受游戏！Enjoy the game!
