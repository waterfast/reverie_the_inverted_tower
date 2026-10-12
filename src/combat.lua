-- 战斗时间以帧计。一次攻击记住方向和命中过的敌人，防止逐帧重复伤害。
combat_config={max_hp=5,startup=4,active=6,recovery=12,range=18,
 damage=1,invincible=60,hurt_frames=16,respawn_frames=45}

function combat_init_player()
 player.attack_timer=0
 player.attack_direction=1
 player.attack_hits={}
 player.invincible=0
 player.hurt_timer=0
 player.knockback=0
end

function attack_box()
 local x=player.x+player.w
 if player.attack_direction<0 then x=player.x-combat_config.range end
 return {x=x,y=player.y+3,w=combat_config.range,h=13}
end

function attack_active()
 local age=combat_config.startup+combat_config.active+combat_config.recovery-player.attack_timer
 return player.attack_timer>0 and age>=combat_config.startup
  and age<combat_config.startup+combat_config.active
end

function combat_update_player()
 player.invincible=max(0,player.invincible-1)
 player.hurt_timer=max(0,player.hurt_timer-1)
 player.attack_timer=max(0,player.attack_timer-1)
 if btnp(controls.attack) and player.attack_timer==0 and player.hurt_timer==0 then
  player.attack_timer=combat_config.startup+combat_config.active+combat_config.recovery
  player.attack_direction=player.facing
  player.attack_hits={}
 end
end

-- 用地形采样截断电击，墙后面的敌人不会被隔墙击中。
function attack_visible(enemy)
 local y=player.y+10
 local start_x=player.x+player.w/2
 local end_x=enemy.x+enemy.w/2
 local direction=sgn(end_x-start_x)
 for distance=0,abs(end_x-start_x),2 do
  if room_blocked(start_x+distance*direction,y,1,1) then return false end
 end
 return true
end

function combat_resolve_attack()
 if not attack_active() then return end
 local hitbox=attack_box()
 for enemy in all(enemies) do
  if enemy.hp>0 and not player.attack_hits[enemy.id]
   and boxes_overlap(hitbox,enemy) and attack_visible(enemy) then
   player.attack_hits[enemy.id]=true
   enemy.hp=max(0,enemy.hp-combat_config.damage)
   enemy.hurt_timer=12
   enemy.direction=player.attack_direction
   if enemy.hp==0 then
    game.defeated[room_world_key()][room.id..":"..enemy.id]=true
   end
  end
 end
end

function player_take_damage(amount,direction)
 if player.invincible>0 or game.death_timer>0 then return false end
 game.hp=max(0,game.hp-amount)
 player.invincible=combat_config.invincible
 player.hurt_timer=combat_config.hurt_frames
 player.knockback=direction*2
 player.vy=-2
 player.attack_timer=0
 player.animation="hurt"
 player.animation_tick=0
 if game.hp==0 then game.death_timer=combat_config.respawn_frames end
 return true
end

function player_respawn()
 game.hp=combat_config.max_hp
 game.death_timer=0
 room_enter(room.id,game.entry)
 -- 重生后留一秒保护，避免入口附近立即再次受伤。
 player.invincible=combat_config.invincible
end

function combat_draw()
 if not attack_active() then return end
 local hitbox=attack_box()
 local y=hitbox.y+6
 line(hitbox.x,y,hitbox.x+hitbox.w-1,y,12)
 for offset=0,hitbox.w-4,4 do
  line(hitbox.x+offset,y-3,hitbox.x+offset+2,y+3,10)
 end
end
