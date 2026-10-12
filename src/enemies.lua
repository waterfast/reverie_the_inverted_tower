-- 当前只有地面守卫：巡逻、边缘转向、受击停顿与接触伤害。
-- 美术先用原生像素绘制；以后替换 enemy_draw，不影响行为或房间数据。
function enemies_init()
 enemies={}
 local defeated=game.defeated[room_world_key()]
 for spawn in all(room.state.enemies) do
  if not defeated[room.id..":"..spawn.id] then
   add(enemies,{id=spawn.id,x=spawn.x,y=spawn.y,w=10,h=12,
    hp=spawn.hp,max_hp=spawn.hp,speed=spawn.speed,color=spawn.color,
    damage=spawn.damage,direction=-1,hurt_timer=0,vy=0})
  end
 end
end

function enemies_update()
 for enemy in all(enemies) do
  if enemy.hp>0 then
   if enemy.hurt_timer>0 then
    enemy.hurt_timer=enemy.hurt_timer-1
   else
    local next_x=enemy.x+enemy.direction*enemy.speed
    local foot_x=next_x
    if enemy.direction>0 then foot_x=next_x+enemy.w-1 end
    if room_blocked(next_x,enemy.y,enemy.w,enemy.h)
     or not room_blocked(foot_x,enemy.y+enemy.h+1,1,1) then
     enemy.direction=-enemy.direction
    else
     enemy.x=next_x
    end
   end
   -- 初次落地允许配置在空中；分像素下降，避免穿透平台。
   enemy.vy=min(3,enemy.vy+0.18)
   local remaining=enemy.vy
   while remaining>0 do
    local step=min(1,remaining)
    if room_blocked(enemy.x,enemy.y+step,enemy.w,enemy.h) then
     enemy.vy=0
     break
    end
    enemy.y=enemy.y+step
    remaining=remaining-step
   end
  end
 end
end

function enemies_contact()
 for enemy in all(enemies) do
  if enemy.hp>0 and boxes_overlap(player,enemy) then
   local direction=1
   if player.x+player.w/2<enemy.x+enemy.w/2 then direction=-1 end
   player_take_damage(enemy.damage,direction)
  end
 end
end

function enemies_draw()
 for enemy in all(enemies) do
  if enemy.hp>0 then
   local x=flr(enemy.x)
   local y=flr(enemy.y)
   local color=enemy.color
   if enemy.hurt_timer>0 then color=7 end
   rectfill(x+1,y+3,x+8,y+9,color)
   rectfill(x+2,y,x+7,y+4,5)
   line(x+3,y+2,x+6,y+2,10)
   line(x+1,y+11,x+3,y+11,6)
   line(x+6,y+11,x+8,y+11,6)
   for heart=1,enemy.hp do pset(x+heart*3,y-3,8) end
  end
 end
end
