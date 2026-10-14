# 前两轮翻转基建记录（2026-10-14）

本文件记录前两轮实现，开场飞升/锥形效果已替换，最新实现与验收以 [ceiling_flip.md](ceiling_flip.md) 为准。

## 已实现结果

世界切换现在只反重力。四间房的地形、出口、平台和清空区域逐格一致，角色不再被传送。
重力过场现用光环和反向光线，中点切重力，默认 72 帧（1.2 秒）。灯台固定，火焰反向。
转换器只有时钟塔和钟室有，其他房间仍可通行。开局对白后自动飞到时钟塔顶部落脚平台，默认 180 帧（3 秒），结束为正常向下重力和行走。
先横移至 x=96 的无障碍竖井，升至 y=12，再落在 top={x=56,y=22}；平台 y=40、x=16..88，
仅用于演出验收，正式顶层设计可替换。game.entry 设为 top，死亡/重进房间回到顶部。

中文对话支持逐字显示、Z/X 补全和翻页；对话中暂停移动、战斗和伤害。
开局告示与猫雷回应、装置说明、旧证词共三段，可以重读。每页三行，每行九字。
运行时通过 ASCII 字号和内嵌 12x12 点阵画中文，避免 PICO-8 默认字体缺字；
编辑 assets/dialogue/stories.json 后运行 python tools/build_dialogue.py，默认读取 Windows 宋体。

三类原创兜帽小怪共六张 16x16 帧：近战持盾剑巡逻、远程弓手预警后发箭、法师预警后发瞄准弹。
子弹撞墙消失；三类都可电击、接触伤害并跟随倒重力。尚未制作 Boss。
火羽徽记兜帽形象已获用户确认，粉丝正式称呼没有填入。

## 修改文件与职责

| 实际文件 | 实现或更新内容 |
| --- | --- |
| reverie_the_inverted_tower.p8 | 引用新模块；嵌入六张小怪帧、灯台、告示，保留地图与猫雷 |
| src/rooms.lua | 一套实体布局、部分房间装置、三类敌人、告示和灯台配置 |
| src/room.lua | 取消两轴反读、共用地形、按当前重力初始化玩家 |
| src/config.lua | 开局房间/入口、对白和飞升开关、飞行阶段/目标、重力过场参数 |
| src/interactions.lua | 告示交互、触发过场、装置上下操作端绘制 |
| src/opening_ascent.lua | 开场三阶段飞升、镜头跟随、残影、顶部正常落地和控制恢复 |
| src/flip_effect.lua | 光环和反向光线、冻结模拟、中点改重力 |
| src/dialogue.lua | 逐字、翻页、字模绘制、暂停游戏 |
| src/dialogue_data.lua | 工具生成的中文字模与 ASCII 编码对白 |
| assets/dialogue/stories.json | 可编辑中文剧情草稿 |
| src/decorations.lua | 固定灯台、反向火焰火星、告示显示 |
| src/enemies.lua | 三类生成、反重力移动、预警发射、子弹碰撞、图集动画 |
| src/combat.lua | 共用击败记录、重力方向受伤弹起、重生退出对话/过场 |
| src/drawing.lua | 地形不翻贴图、更新交互提示 |
| src/main.lua | 对话/过场优先调度，接入摆件与覆盖绘制 |
| assets/sprites/enemies_props.png | 96x32 透明素材表，六帧小怪与两种摆件 |
| tools/build_enemy_art.py | 手绘像素定义、受保护图集导入、素材预览生成 |
| tools/build_dialogue.py | JSON 中文剧情分页、点阵字库生成（Pillow） |
| tools/check_movement.lua | 按新重力规则维护回归检查，直接读取真实地图 |
| tools/export_room_layout.lua | 共用布局导出，补充灯台与告示数据 |
| tools/render_room_layout.py | 去掉总览中旧的旋转，更新装置和敌人显示 |
| docs/current_map_layout.json | 从实际 room_tile 重新导出的正逆布局 |
| docs/previews/current_map_*、layout_* | 重新生成共用地图总览和分房预览 |
| docs/previews/gravity_*、flip_cone、dialogue_intro、enemies_props | 原生画面、动画和素材预览 |
| docs/previews/native_gravity_check.txt | 原生检查通过记录 |
| README.md、docs/room_architecture.md、map_editing.md、design.md、asset_sources.md | 更新运行、职责、编辑方式、范围和来源 |

整体架构：卡带保存地图/图集 → rooms 配置内容 → room 提供共用碰撞 → player/enemies 计算重力运动 →
combat 结算 → main 调度；dialogue、opening_ascent 与 flip_effect 暂停模拟并独立绘制。没有接数据库或服务端。

## 已验证

- 普通 Lua 回归通过：所有四房有效地图逐格相同、入口不穿墙、倒重力随换房保留。
- 原地过场：36 帧前不改重力，中点反向，72 帧后恢复；玩家和小怪对象、坐标、生命保留。
- 角色落到天花板，倒立跳跃方向向下，装置可以切回正常重力。
- 所有配置门洞在两种重力下触发目标入口且不反弹（放到洞口验证连接）。
- 对话暂停移动战斗，按键补全、翻页正常；电击一次一伤、击败记录跨重力共用。
- 弓箭直射、法术带纵向瞄准、投射物撞墙消失；受伤无敌、死亡重生保护通过。
- 原生 PICO-8 实际加载、逐格地形比对、过场坐标断言、天花板落地通过。
- 原生截图已检查：中文可读、角色倒立、素材正确、飞升与重力光环显示正确；GIF 已输出。

## 仍未实现或待设计

正式地图、所有逆重力路线的自然可达性、Boss、粉丝正式称呼、音效、
最终胜负目标、对话选项和磁盘存档未实现。原型台阶保留，未把用户草图定成关卡。
子弹在切换中清除；未击败小怪换房后重置位置，击败状态只在本次运行保留。

## 运行与备份

PICO-8 重新 load reverie/reverie_the_inverted_tower 后 run；开场 Z/X 阅读，上操作告示/装置。
检查命令 lua tools/check_movement.lua src。备份 backups/before_gravity_foundation_20261014.zip。

## 用户澄清后的追加修改与验收

“上锥”实际指“上升”。已移除锥形收拢的运行代码，重力过场改光环，开场改为猫雷飞上顶层。
新增 src/opening_ascent.lua；修改 src/main.lua 接演出调度/绘制、src/config.lua 配飞行、
src/rooms.lua 加共用顶部平台和 top 入口、src/combat.lua 重生退出演出、src/flip_effect.lua 改光环。
卡带新增引用，tools/check_movement.lua 增飞升测试，export_room_layout.lua 接新模块，
docs/current_map_layout.json 与地图总览重新生成；README 和相关中文文档同步更新。

普通 Lua 和原生 PICO-8 均通过：对白结束自动飞升；180 帧每帧碰撞盒不穿墙/平台；
飞行期间输入不控制角色、敌人不移动、生命不变化；到顶后向下重力、落地、正常走路/跳跃；
重生在 top 且不重复播放演出。正逆有效地图仍逐格相同。
原生证据：previews/native_ascent_check.txt、opening_ascent.gif、opening_ascent.png、
summit_landing.png、gravity_pulse.png。旧 flip_cone.png 和 gravity_transition.gif 留为历史预览。
澄清前备份：backups/before_opening_ascent_20261014.zip。
