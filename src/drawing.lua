-- 每个可见格子经过同一读取接口，包含世界旋转、出口开口和补充平台。
function room_draw()
 local size=room_config.tile_size
 local left=flr(view.x/size)
 local top=flr(view.y/size)
 local right=min(left+ceil(view_config.width/size),room.definition.columns-1)
 local bottom=min(top+ceil(view_config.height/size),room.definition.rows-1)
 if game.inverted then pal(1,2) pal(5,13) end
 for y=top,bottom do
  for x=left,right do
   local sprite=room_tile(x,y)
   if sprite~=0 then spr(sprite,x*size,y*size) end
  end
 end
 pal()
end

function hud_draw()
 rectfill(0,0,127,15,0)
 local world="n "
 if game.inverted then world="r " end
 print(world..room.state.name,2,1,6)
 for i=1,combat_config.max_hp do
  local color=5
  if i<=game.hp then color=8 end
  rectfill(98+i*5,2,100+i*5,5,color)
 end
 local hint="up flip / z jump x zap"
 if room_interaction_target() then
  hint="up: interact / flip"
 end
 if game.death_timer>0 then hint="defeated... respawning" end
 print(hint,2,9,7)
 if game.transition>6 then rect(0,16,127,127,13) end
end
