# Reverie: The Inverted Tower

以猫雷为主角的 PICO-8 翻转主题同人 Game Jam 原型。
当前四间灰盒房共用实体地图，世界切换只反转重力，从原来地面入口正常开始，翻转后直接到天花板或地面，带中文对话和三类小怪。

## 运行

在 PICO-8 控制台输入：

```text
cd /
load reverie/reverie_the_inverted_tower
run
```

外部修改卡带后请先重新 load，避免旧编辑器保存覆盖新素材。
卡带依赖 src 相对路径，不能只复制 .p8。开场在原来的地面入口正常出生，立即可移动；上读告示，Z/X 补全、翻页。

## 操作

- 左右移动，Z 跳跃，X 电击。倒重力时 Z 从天花板向下跳。
- 上：切换地板/天花板；靠近告示时优先阅读。能力不依赖转换器。
- 翻转后直接贴到上方天花板或下方地面，左右仍水平行走，Z 向支撑面外跳。
- 沿墙洞走入自动换房；下+Z 回复生命并回本房入口。
- 暂停菜单 sprite gallery 查看猫雷图集；restart room 重进当前房间。

翻转保持横坐标和生命，直接到重力方向最近的支撑面；平台也算支撑，不能穿过实体。
不支持侧墙吸附、爬墙或横向重力。地形不旋转，击败的小怪不复活。

重生/换房仍用配置的固定入口；倒重力下从入口自然向上落，正式关卡可达性待设计。

## 后续编辑入口

- src/rooms.lua：房间、门、平台、装置、灯、告示、小怪位置，只有一套布局。
- src/config.lua：start_config 控制入口/开局重力/对白，flip_config 调快速过场。
- assets/dialogue/stories.json：中文剧情，修改后运行 python tools/build_dialogue.py。
- 精灵 192/194 近战、196/198 弓手、200/202 法师；224 灯台、226 告示。
- tools/build_enemy_art.py：像素原稿与素材导入；保护已有不同像素，避免覆盖用户新素材。

开局飞升已移除；正常出生于时钟塔 west 入口（24,230），能力过场 12 帧（0.2 秒）。正式整塔关卡和 Boss 未实现。
火羽陷害白菜的台词是游戏虚构剧情草稿。小怪暂为原创火羽徽记兜帽形象，兜帽形象已获用户确认，粉丝正式称呼仍未填入。

## 架构与验收

[当前上下翻转修改和完整验收](docs/ceiling_flip.md) 包含实际文件职责、验证证据和未完成范围。
[房间架构](docs/room_architecture.md)、[地图编辑](docs/map_editing.md) 用于后续关卡设计。

```text
lua tools/check_movement.lua src
lua tools/export_room_layout.lua src
python tools/render_room_layout.py
```

Python 素材工具依赖 Pillow；普通 Lua 检查读取真实地图；原生 PICO-8 检查同时验证绘制。
本次原生截图、过场 GIF 和日志在 docs/previews，历史截图保留为旧版本参考。
修改前备份在 backups/before_gravity_foundation_20261014.zip，不自动提交或推送。
