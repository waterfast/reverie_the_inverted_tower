# 上下翻转直接到支撑面（当前规则）

已删除侧墙能力。开场恢复时钟塔原来的 west 入口（24,230），正常向下重力；按上切换上下重力，在快速光环过场中点
直接到上方天花板或下方地面。横坐标不变，逐像素扫描到最近实体；若上方有平台，
停在平台底面，不穿过平台。默认 12 帧过场（0.2 秒）。
左右始终水平行走，Z 与重力反向跳跃，X 水平电击；告示附近上优先阅读。
没有爬墙、侧墙吸附、横向重力，也没有飞升过程。

## 实际文件和架构

- src/player.lua：恢复上下重力运动，增加 player_snap_to_support 逐像素找支撑面。
- src/player_animation.lua：删除 90 度绘制，恢复正立/倒立图像和动作判断。
- src/flip_effect.lua：中点反重力并直接贴到支撑面，保留快速光环。
- src/interactions.lua：去掉方向键选侧墙，只有上下翻转与告示阅读。
- src/room.lua、src/main.lua：移除四方向重力状态，固定 8x18 碰撞盒。
- src/combat.lua：恢复水平电击、向当前重力反方向弹起，保留原攻击与受伤规则。
- src/config.lua、src/drawing.lua：删除侧墙参数和提示。
- assets/dialogue/stories.json、src/dialogue_data.lua：对白和字模同步为上下翻转说明。
- tools/check_movement.lua：去掉侧墙测试，增加瞬间天花板/地面落位和无侧墙模式验证。
- docs/previews/native_ceiling_flip_check.txt、ceiling_flip_result.png：原生验证与截图。
- README.md、docs/design.md、room_architecture.md、flip_foundation.md、wall_ability.md、ceiling_flip.md：同步当前规则，旧方案标为历史。

架构：交互触发 → 过场中点反上下重力 → player_move 按像素寻找支撑 → 镜头更新 → 正常走跳。
地图仍是同一套 room_tile，不增加或移动平台，也不重建怪物、回复生命。

## 已验证与未实现

普通 Lua 回归通过：四房有效地图逐格相同、瞬间贴顶/落地不穿实体、横坐标保留、
角色固定尺寸、按着左键也不会选侧墙、正常开场可行走；原对话、通道、战斗和生命检查通过。
原生 PICO-8 验证直接贴顶、立即站稳、倒立跳跃、切回地面；见 native_ceiling_flip_check.txt。

正式地图路线、Boss、音效、通关和存档仍未实现。侧墙吸附已撤销，旧侧墙截图只是历史。
本次改前备份：backups/before_remove_wall_20261014.zip。重新加载主卡带运行即可。

## 正常出生与推送前检查

默认 start_config 改回 room=1、entry="west"、inverted=false、intro=false；
原始出生点 x=24、y=230，生命为 5，落地站稳。翻转规则维持不变。
实际修改 src/config.lua、tools/check_movement.lua、assets/dialogue/stories.json 与生成的
src/dialogue_data.lua；README 和当前设计/架构文档同步。新增默认配置断言与原生开局检查。
