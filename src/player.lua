-- 只处理角色状态和运动；图片选择与绘制在 player_animation.lua。
function player_init()
 local config=player_config
 player={
  x=config.spawn_x,y=config.spawn_y,
  w=config.width,h=config.height,
  vx=0,vy=0,
  gravity=1, -- 1 向下，-1 向上。
  facing=1, -- 1 面向右，-1 面向左。
  grounded=false,flip_timer=0,
  animation="idle",animation_tick=0
 }
 combat_init_player()
end

-- 每次移动最多一个像素，速度再快也不会跨过薄平台。
-- 先移动 X 再移动 Y，使墙壁和地板碰撞的职责明确。
function player_move(axis,amount)
 local remaining=abs(amount)
 local direction=sgn(amount)
 while remaining>0 do
  local step=min(1,remaining)*direction
  local next_x=player.x
  local next_y=player.y
  if axis=="x" then
   next_x=next_x+step
  else
   next_y=next_y+step
  end

  if room_blocked(next_x,next_y,player.w,player.h) then
   -- 平台边界是整数。贴齐边界，避免小数坐标留下肉眼可见的缝。
   if direction>0 then
    player[axis]=-flr(-player[axis])
   else
    player[axis]=flr(player[axis])
   end
   if axis=="x" then
    player.vx=0
   else
    player.vy=0
    -- 撞到头顶不算落地；必须沿当前重力方向撞上实体。
    if direction==player.gravity then player.grounded=true end
   end
   return
  end

  player.x=next_x
  player.y=next_y
  remaining=remaining-abs(step)
 end
end

function player_update()
 local config=player_config
 if player.flip_timer>0 then player.flip_timer=player.flip_timer-1 end

 local input=0
 if btn(controls.left) then input=input-1 end
 if btn(controls.right) then input=input+1 end
 -- 当前采用直接起步/停止，方便先测试翻转路线。
 player.vx=input*config.move_speed
 if player.hurt_timer>0 then
  player.vx=player.knockback*player.hurt_timer/combat_config.hurt_frames
 end
 if input~=0 and player.attack_timer==0 then player.facing=input end

 if btnp(controls.jump) and player.grounded and player.hurt_timer==0 then
  -- 跳跃方向永远与重力相反，倒立时也可从天花板起跳。
  player.vy=-config.jump_speed*player.gravity
  player.grounded=false
 end

 player.vy=mid(-config.max_fall_speed,
  player.vy+config.gravity_force*player.gravity,
  config.max_fall_speed)
 -- 每帧重新检测支撑，走出平台边缘会自然开始下落。
 player.grounded=false
 player_move("x",player.vx)
 player_move("y",player.vy)
 player_animation_update()
end
