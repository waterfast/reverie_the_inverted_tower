# 房间与重力架构（2026-10-14）

## 数据与坐标

每间房只保存一套地形、门洞、平台、入口和摆件。rooms_configure 配置 normal，
reverse 只是同一表的兼容引用，禁止独立修改为第二张地图。
room_tile 先应用 doors、platforms、clear_areas，再直接读取卡带，完全不读 game.inverted。
绘制和碰撞都用 room_tile，正逆状态每格必须相同。世界坐标、镜头坐标、贴图朝向没有旋转。

game.inverted 决定 player.gravity（正常 1，倒置 -1）；重力加速度、跳跃、落地检测和受伤弹起
都按该方向计算。小怪的支撑检测和下落同样跟随重力。贴图上下翻转仅用于角色与小怪。
正常/逆状态可用不同调色板，但不能改变碰撞。灯台固定，火焰和火星逆着重力飘。

## 上下翻转

开场用 west 入口（24,230）和向下重力，猫雷正常站在地面，无飞升。
按上时告示阅读优先，否则切换上下重力。12 帧光环过场第 6 帧切换，并立即把角色
移动到重力方向最近的支撑面；保持横坐标，逐像素扫描，平台和地面都可挡住扫描。
左右始终水平移动，跳跃与当前重力反向。没有侧墙吸附、横向重力、爬墙或旋转碰撞盒。
角色一直使用 8x18 碰撞盒，图像只有正立/倒立。地形读取不随世界变化。

## 连接与入口

低处 1 ↔ 2 ↔ 3 ↔ 4，高处 2 右上 ↔ 4 左上，仍是原型的固定门洞。
只有 1 和 4 保留装置摆件，玩家在无装置房间仍可使用能力。门的方向、目标和入口不会随重力变动。
进入房间重建角色、小怪、镜头，保留当前重力、生命、无敌时间和击败记录。
倒重力入口允许在空中，随后自然落到天花板；本次不保证所有旧灰盒路线在倒重力下可达。

entries 是入口名字到 x/y 的映射；doors 有 x/y/w/h/direction/target/entry；
converters 有 x/y/w/h；talks 有 x/y/w/h/story；lamps 有 x/y；
enemies 有唯一 id、x/y、kind、hp、speed、damage（kind 为 melee/ranged/mage）。
platforms 为 8 像素厚的 x/y/w，clear_areas 为 x/y/w/h。坐标均为房间内部像素。

## 运行进度与调度

game.visited 仍分 normal/reverse，表示两种重力下是否访问过；game.defeated.normal
保存共用击败记录，键为 房间号:enemy.id。未击败敌人换房后重新生成，尚无位置持久化或磁盘存档。
死亡等待 45 帧后回本次入口；restart room 会退出对话和过场。
main 优先处理对话和过场，暂停物理、攻击、子弹和伤害，再处理战斗与移动。

## 检查

lua tools/check_movement.lua src：真实地图逐格一致、固定入口不穿墙、天花板落地/跳跃、
过场坐标生命保留及往返、可选转换器、通道连接不反弹、对话暂停翻页、小怪击败共享、
两类投射物和死亡保护。通道检查验证系统连接，不等于正式路线可以全程自然走到。
原生检查与截图见 previews/native_gravity_check.txt 与 native_ascent_check.txt、opening_ascent.gif（旧 gravity_transition.gif 是历史锥形版本）。
地图分区与素材保护见 map_editing.md。

最新文件清单、限制和验证记录见 ceiling_flip.md。旧飞升截图只作为历史记录。
