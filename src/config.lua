-- 集中放可调参数：先改这里，再运行游戏观察手感。
-- 游戏固定用 _update60，每次更新约为 1/60 秒。
player_config={
 spawn_x=24,spawn_y=230,
 -- 碰撞盒比整张图片窄，头发和裙摆不会卡在平台边缘。
 width=8,height=18,
 move_speed=1.4,
 jump_speed=3.2,
 gravity_force=0.18,
 max_fall_speed=3,
 flip_frames=12
}

controls={left=0,right=1,interact=2,down=3,jump=4,attack=5}

-- 24x24 图片占精灵表的 3x3 个小格，能保留头发、角和女仆装特征。
-- 编号必须指向整张图片的左上角，不能简单地每次加 1。
-- 从 x=8 开始存放，保留用户原有的左上角素材。
character_art={size=24,atlas_x=8,atlas_y=0,columns=4}

-- 地图编辑器里的一个格子是 8x8 像素。
-- 每个房间的尺寸和素材区域由 rooms.lua 配置。
room_config={tile_size=8,solid_flag=0}
view_config={width=128,height=112,hud_height=16}
