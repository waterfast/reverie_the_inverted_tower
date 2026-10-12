# Reverie: The Inverted Tower

以猫雷 Nyaru 为主角的 PICO-8 同人箱庭探索原型。
当前包含四个房间、自动墙洞通道、高处捷径、多房间双向转换器与基础电击战斗。

## 获取项目

在 PICO-8 的 carts 目录克隆为 reverie 文件夹，以便使用下面的加载命令：

```text
git clone https://github.com/waterfast/reverie_the_inverted_tower.git reverie
```

仓库包含卡带、全部 src 文件、游戏角色素材、工具和中文文档。
运行时需要 PICO-8，保留卡带与 src 的相对位置；单独下载 .p8 不包含被引用的代码。
导入/修复图片工具需要 Python 和 Pillow，回归检查需要普通 Lua。
本地备份、缓存、导出文件与研究用参考设定图不提交到仓库。

## 打开与运行

用 VS Code 打开整个 reverie 文件夹。在 PICO-8 控制台输入：

```text
cd /
load reverie/reverie_the_inverted_tower
run
```

外部修改卡带后先重新 load，避免旧编辑器保存时覆盖新地图和素材。
只改 src 代码时，保存后 Ctrl+R；在 PICO-8 修改图像或地图后 Ctrl+S。

## 操作

- 左右：移动。
- Z：跳跃。
- X：短距离电击，可在空中使用。
- 上：转换器旁切换表城/镜世界，同一个转换器可以往返。
- 通道：沿左右墙上的开口走进去，自动换房，不需要按上。
- 下+Z：开发用回入口，回复生命，保留世界状态、探索记录与击败记录。
- 暂停菜单中的 sprite gallery：动作素材总览，Z/X 返回游戏。
- 暂停菜单中的 restart room：重进当前房间。

当前重力始终向下，翻转的是世界地形。X 已用于战斗。
生命值上限 5；受伤后有 1 秒无敌和短暂击退。生命耗尽后在当前入口重生。
换房与切换世界不回血；每个世界分别记录击败的敌人，重进房间不会复活守卫。

## 当前流程

时钟塔右侧墙洞 → 月影回廊 → 封印书库 → 无声钟室。
左侧通道可以返回；回廊右上与钟室左上通道互相连接，形成捷径。
四间房都在中间偏左设置转换器，走近按上切换，两边均可返回。
地图和砖块旋转 180 度，出口和安全落点按世界独立配置。
高处测试台阶有少量地形覆盖，正式关卡设计时可删改，未覆盖卡带中的手绘地图。

## 文件职责

| 文件或目录 | 内容 |
| --- | --- |
| reverie_the_inverted_tower.p8 | 地图、图像、flag、声音和代码引用 |
| src/config.lua | 手感、控制和图集参数 |
| src/rooms.lua | 各房间的存储位置、尺寸、两种世界的门和入口 |
| src/room.lua | 房间进入、地形读取、地图碰撞 |
| src/interactions.lua | 自动通道、双向转换器和显示 |
| src/combat.lua | 电击时序、命中、生命、无敌与重生 |
| src/enemies.lua | 守卫生成、巡逻、接触伤害与显示 |
| src/view.lua | 镜头跟随和边界限制 |
| src/player.lua | 移动、跳跃和碰撞响应 |
| src/player_animation.lua | 动作选择、角色绘制、素材预览 |
| src/drawing.lua | 地图和界面绘制 |
| src/main.lua | 更新/绘制调度和暂停菜单 |
| assets/sprites/ | 动作源图、局部图集、完整精灵表 |
| assets/references/ | 公开角色形象参考 |
| assets/audio/ | 声音草稿和参考 |
| docs/ | 设计、架构、地图编辑、素材来源和检查截图 |
| tools/ | 导入、修复、初次建图和回归检查，不参与游戏运行 |
| exports/ | 导出成品 |
| backups/ | 修改前的完整备份 |

## 阅读顺序

- docs/room_architecture.md：房间目录、三层数据、坐标和世界复用。
- docs/map_editing.md：各房间在地图编辑器中的位置与碰撞 flag。
- docs/feasibility.md：7 天范围与关卡可达性评估。
- docs/character_assets.md：角色图集与导入方式。
- docs/design.md：当前目标和待设计内容。

## 修复角色素材

角色的可靠局部图集是 assets/sprites/nyaru_actions_24.png。
如果误改了精灵表，在开发电脑安装 Python 和 Pillow 后运行：

```text
python tools/restore_character.py
```

工具只恢复角色图集区域，不改变地图或其他素材；之后在 PICO-8 重新 load。
修改关卡时不要重新运行 seed_map.py 或 add_rooms.py，这些工具用于初次创建。

## 检查

安装普通 Lua 后，在项目根目录运行：

```text
lua tools/check_movement.lua src
```

覆盖两种世界的所有入口与通道、转换器往返、生命保留、高处台阶路线、
单次电击只命中一次、墙体遮挡、敌人击败记录、受伤无敌与重生。
另用 PICO-8 本体验证加载和实际绘制。

## 实际范围

这是可玩的架构与灰盒地图。基础战斗已经实现，敌人暂用简单像素守卫。
武器解锁、Boss、最终通关目标、音效和磁盘存档尚未实现。
初始时钟塔保留原地图，正式探索路线和难度还需要继续细化。
