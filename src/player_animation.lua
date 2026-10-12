-- 所有动作共用一套朝右的原图；朝左和倒立通过 spr 的翻转参数实现。
-- frames 存的是图集中第几帧（从 0 开始），不是 PICO-8 精灵编号。
character_animations={
 idle={frames={0,1},speed=24},
 run={frames={2,3,4,5},speed=7},
 jump={frames={6,7},speed=10},
 fall={frames={8,9},speed=10},
 flip={frames={10,11},speed=6},
 attack={frames={12,13},speed=9},
 hurt={frames={14,15},speed=9}
}

-- 把图集帧号转成精灵表的左上角编号。转换成sprteID = 16*y+x
function character_sprite_id(frame)
 local column=frame%character_art.columns
 local row=flr(frame/character_art.columns)
 local tiles=character_art.size/8
 local tile_x=character_art.atlas_x/8+column*tiles
 local tile_y=character_art.atlas_y/8+row*tiles
 return tile_y*16+tile_x
end

function player_animation_update()
 local state="idle"
 if player.hurt_timer>0 or game.death_timer>0 then
  state="hurt"
 elseif player.attack_timer>0 then
  state="attack"
 elseif player.flip_timer>0 then
  state="flip"
 elseif not player.grounded then
  -- vy 与重力反向表示上升；重力倒置后仍适用。
  if player.vy*player.gravity<0 then state="jump"
  else state="fall" end
 elseif player.vx~=0 then
  state="run"
 end

 if state~=player.animation then
  player.animation=state
  player.animation_tick=0
 else
  player.animation_tick=player.animation_tick+1
 end
end

function player_draw()
 -- 受伤闪烁只影响显示，不改变碰撞或无敌计时。
 if player.invincible>0 and flr(player.invincible/4)%2==0 then return end
 local animation=character_animations[player.animation]
 local index=flr(player.animation_tick/animation.speed)%#animation.frames+1
 local sprite=character_sprite_id(animation.frames[index])
 local size=character_art.size
 local draw_x=flr(player.x+(player.w-size)/2)
 -- 图片最后一行透明，因此需要一像素对齐补偿，让鞋底贴住平台。
 local draw_y=flr(player.y+player.h-size+1)
 -- 正立时脚底对齐碰撞盒底边，倒立时对齐碰撞盒顶边。
 if player.gravity<0 then draw_y=flr(player.y)-1 end
 if player.flip_timer>0 then
  circ(player.x+player.w/2,player.y+player.h/2,
   8+(player_config.flip_frames-player.flip_timer)/2,12)
 end
 spr(sprite,draw_x,draw_y,size/8,size/8,player.facing<0,player.gravity<0)
end

-- 暂停菜单可打开动作总览；攻击/受伤判定在 combat.lua，动画只负责显示。
function character_gallery_draw()
 cls(1)
 print("nyaru / sprite gallery",2,2,7)
 print("z/x: back to game",2,10,6)
 for row=0,3 do
  local y=24+row*26
  for column=0,3 do
   local frame=row*4+column
   spr(character_sprite_id(frame),8+column*29,y,3,3)
  end
 end
end
