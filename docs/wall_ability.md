# 已撤销的侧墙方案（历史记录）

用户澄清后已去掉侧墙吸附；当前规则见 [ceiling_flip.md](ceiling_flip.md)。以下仅记录旧方案。

# 直接倒立开局与吸附能力

## 当前实现

取消飞升演出，默认时钟塔 ceiling={x=56,y=8} 入口、向上重力，直接贴在天花板。
开场对白默认关闭，可在 start_config.intro 打开；告示与中文对话保留。

上：自由切换地板/天花板，告示附近阅读优先。距离侧墙 6 像素内按朝墙方向+上：吸附侧墙。
左右键沿支撑面走；左墙按右向下、右墙按右向上；Z 向外跳。侧墙上单独上回天花板，
再上切回地面。X 沿面向方向电击。切换只需 12 帧（0.2 秒），中点第 6 帧转向。

吸附通过四方向重力持续向实体表面施力实现，不会凭空定住。离开平台边缘后继续下落。
能力不依赖装置；角色图片、碰撞盒、跳跃方向、电击盒跟随支撑面。小怪仍只支持上下重力。
相邻墙角旋转碰撞盒时最多修正 18 像素寻找合法位置；空间不足时保持原方向，绝不嵌墙。
上下翻转不移动角色；地形、门洞、平台正逆依旧完全共用。

## 实际修改文件

| 文件 | 内容 |
| --- | --- |
| src/config.lua | 默认 ceiling、倒重力、关闭对白；12 帧过场；6 像素选墙距离 |
| src/rooms.lua | 共用 ceiling 入口；保留上轮顶部平台供后续地图设计 |
| src/main.lua | 去掉飞升调度和绘制，直接初始化倒立开局 |
| src/player.lua | 四方向重力、沿墙移动/向外跳、旋转碰撞盒与合法位置检查 |
| src/player_animation.lua | 侧墙 90 度绘制和四方向动作判断，复用已有图集 |
| src/room.lua | 换房/重生恢复当前重力方向和碰撞盒 |
| src/interactions.lua | 无装置自由翻转、方向键+上选择邻近侧墙，告示仍优先 |
| src/flip_effect.lua | 指定目标重力、快速光环过场，移除飞升引用 |
| src/combat.lua | 沿墙电击盒、二维墙体遮挡、沿重力反方向受伤弹起 |
| src/drawing.lua | 更新自由翻转与吸附提示 |
| src/opening_ascent.lua | 已删除，不再播放开场飞升 |
| reverie_the_inverted_tower.p8 | 删除飞升模块引用，仍保留原地图和角色素材 |
| assets/dialogue/stories.json、src/dialogue_data.lua | 对白改为直接顶层与自由吸附说明，重新生成字模 |
| tools/check_movement.lua | 保留已有回归，新增直接开局、自由翻转、双侧墙行走/跳跃/攻击测试 |
| tools/export_room_layout.lua | 移除已删除模块，重新导出入口与共用布局 |
| docs/current_map_layout.json、previews/current_map_*、layout_* | 按实际配置重新生成 |
| docs/previews/ability_*、native_wall_ability_check.txt | 原生开场/两侧墙截图与验收记录 |
| README.md、docs/design.md、room_architecture.md、flip_foundation.md、wall_ability.md | 同步现状和历史记录区分 |

架构：同一 room_tile 地形 → 玩家重力/相切行走轴 → 分像素碰撞 → 动作与电击转向；
交互选目标 → 快速过场提交重力。角色能力与地图配置独立，适合后续用平台、墙和天花板设计路线。

## 验证

普通 Lua 回归通过：四房正逆有效地图逐格一致，原有通道、对话、击败状态和战斗检查通过。
新增：直接倒立开局立即沿天花板走；无装置房间自由切换；左/右墙吸附不穿墙；
侧墙碰撞盒 18x8、沿墙行走、跳跃向外、电击盒朝沿墙方向；回地面恢复 8x18。
原生 PICO-8 验证上述开局、侧墙姿势/行走、绘制在帧预算内、无装置翻转，并检查截图。

检查命令：lua tools/check_movement.lua src。重载主卡带后运行即可。
本次改前备份：backups/before_wall_ability_20261014.zip。

## 未实现

没有自动绕过墙角、任意角度表面、可选附着材质或新增能力关卡；需要手动转向。
正式地图路线、Boss、通关目标、音效、磁盘存档仍待后续。旧飞升 GIF 仅作为历史预览。
