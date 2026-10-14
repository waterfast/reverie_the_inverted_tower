-- 三类火羽徽记兜帽小怪；图集帧位于 192..203，数据驱动生成。
function enemies_init()
 enemies={}
 local defeated=game.defeated.normal
 projectiles={}
 for spawn in all(room.state.enemies) do
  if not defeated[room.id..":"..spawn.id] then
   add(enemies,{id=spawn.id,x=spawn.x,y=spawn.y,w=10,h=12,
    hp=spawn.hp,max_hp=spawn.hp,speed=spawn.speed,color=spawn.color,
    damage=spawn.damage,kind=spawn.kind or "melee",direction=-1,hurt_timer=0,vy=0,cooldown=60})
  end
 end
end

-- 普通巡逻检测当前重力侧的支撑；法师与弓手停步瞄准、先预警再发射。
function enemies_update()
 local gravity=game.inverted and -1 or 1
 for enemy in all(enemies) do
  if enemy.hp>0 then
   enemy.cooldown=max(0,enemy.cooldown-1)
   local dx=player.x-enemy.x
   local aiming=enemy.kind~="melee" and abs(dx)<104
    and abs(player.y-enemy.y)<42 and attack_visible(enemy)
   if enemy.hurt_timer>0 then
    enemy.hurt_timer=enemy.hurt_timer-1
   elseif aiming then
    enemy.direction=sgn(dx)
    if enemy.cooldown==0 then
     enemy_shoot(enemy)
     enemy.cooldown=enemy.kind=="mage" and 135 or 100
    end
   else
    local next_x=enemy.x+enemy.direction*enemy.speed
    local foot_x=next_x
    if enemy.direction>0 then foot_x=next_x+enemy.w-1 end
    local foot_y=enemy.y-1
    if gravity>0 then foot_y=enemy.y+enemy.h+1 end
    if room_blocked(next_x,enemy.y,enemy.w,enemy.h)
     or not room_blocked(foot_x,foot_y,1,1) then
     enemy.direction=-enemy.direction
    else enemy.x=next_x end
   end
   enemy.vy=mid(-3,enemy.vy+0.18*gravity,3)
   local remaining=abs(enemy.vy)
   local direction=sgn(enemy.vy)
   while remaining>0 do
    local step=min(1,remaining)*direction
    if room_blocked(enemy.x,enemy.y+step,enemy.w,enemy.h) then
     enemy.vy=0
     break
    end
    enemy.y=enemy.y+step
    remaining=remaining-abs(step)
   end
  end
 end
 projectiles_update()
end

function enemy_shoot(enemy)
 local x=enemy.x+enemy.w/2
 local y=enemy.y+enemy.h/2
 local speed=enemy.kind=="mage" and 1.1 or 1.8
 local vy=0
 if enemy.kind=="mage" then
  vy=mid(-0.8,(player.y+player.h/2-y)/max(8,abs(player.x-x))*speed,0.8)
 end
 add(projectiles,{x=x,y=y,w=3,h=3,vx=enemy.direction*speed,
  vy=vy,life=110,kind=enemy.kind})
end

function projectiles_update()
 for shot in all(projectiles) do
  shot.x=shot.x+shot.vx
  shot.y=shot.y+shot.vy
  shot.life=shot.life-1
  local blocked=room_blocked(shot.x,shot.y,shot.w,shot.h)
  if not blocked and boxes_overlap(player,shot) then
   player_take_damage(1,sgn(shot.vx))
   shot.life=0
  end
  if blocked or shot.life<=0 then del(projectiles,shot) end
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
 local inverted=game.inverted
 for enemy in all(enemies) do
  if enemy.hp>0 then
   local sprite=192
   if enemy.kind=="ranged" then sprite=196 end
   if enemy.kind=="mage" then sprite=200 end
   sprite=sprite+flr(game.tick/14)%2*2
   local x=flr(enemy.x)-3
   local y=flr(enemy.y)-4
   if inverted then y=flr(enemy.y) end
   if enemy.hurt_timer>0 then pal(8,7) pal(9,7) pal(13,7) end
   spr(sprite,x,y,2,2,enemy.direction<0,inverted)
   pal()
   local heart_y=inverted and enemy.y+enemy.h+3 or enemy.y-7
   for heart=1,enemy.hp do pset(enemy.x+heart*3,heart_y,8) end
   if enemy.kind~="melee" and enemy.cooldown<24 then
    circ(enemy.x+5,enemy.y+6,8-enemy.cooldown/6,10)
   end
  end
 end
 for shot in all(projectiles) do
  if shot.kind=="mage" then
   circfill(shot.x+1,shot.y+1,2,13)
   pset(shot.x+1,shot.y+1,7)
  else line(shot.x-shot.vx*3,shot.y,shot.x+2,shot.y,10) end
 end
end
