-- 快速切换上下重力，直接落到天花板/地面；不支持侧墙。
function flip_start()
 if flip_effect then return end
 flip_effect={tick=0}
 player.attack_timer=0
end

function flip_update()
 local effect=flip_effect
 effect.tick=effect.tick+1
 if effect.tick==flip_config.midpoint then
  game.inverted=not game.inverted
  player.gravity=game.inverted and -1 or 1
  player_snap_to_support()
  player.flip_timer=player_config.flip_frames
  player.animation="flip"
  player.animation_tick=0
  for enemy in all(enemies) do enemy.vy=0 end
  projectiles={}

 end
 if effect.tick>=flip_config.frames then
  flip_effect=nil
  game.transition=12
 end
end

-- 自由重力能力用短光环和反向光线提示转向。
function flip_draw()
 if not flip_effect then return end
 local tick=flip_effect.tick
 local intensity=1-abs(2*tick/flip_config.frames-1)
 local x=player.x+player.w/2-view.x
 local y=player.y+player.h/2-view.y+16
 local radius=8+intensity*28
 circ(x,y,radius,12)
 circ(x,y,radius+4,13)
 local direction=game.inverted and -1 or 1
 for i=0,11 do
  local sx=(i*11+tick)%128
  local sy=16+(i*19+tick*direction*3)%112
  line(sx,sy,sx,mid(16,sy-direction*intensity*10,127),12)
 end
 rectfill(0,0,127,15,0)
 print("gravity rewrite",34,5,12)
 if abs(tick-flip_config.midpoint)<3 then rect(0,16,127,127,7) end
end
