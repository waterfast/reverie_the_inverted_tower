-- 通道自动触发；只有转换器需要按上。换房冷却与方向检查避免来回弹。
function boxes_overlap(a,b)
 return a.x+a.w>b.x and a.x<b.x+b.w
  and a.y+a.h>b.y and a.y<b.y+b.h
end

function interaction_near(object)
 return boxes_overlap(player,{x=object.x-7,y=object.y,w=object.w+14,h=object.h})
end

function room_interaction_target()
 for converter in all(room.state.converters) do
  if interaction_near(converter) then return converter,"converter" end
 end
 return nil,nil
end

function room_interact()
 if game.transition>0 or game.death_timer>0 then return false end
 local object=room_interaction_target()
 if not object then return false end
 -- 两边都可用。不继承原坐标，因为旋转后原处可能变成实体墙。
 game.inverted=not game.inverted
 room_enter(room.id,object.entry)
 player.flip_timer=player_config.flip_frames
 return true
end

function room_check_portals()
 if game.transition>0 or game.death_timer>0 then return false end
 for door in all(room.state.doors) do
  if boxes_overlap(player,door) and player.vx*door.direction>0 then
   room_enter(door.target,door.entry)
   return true
  end
 end
 return false
end

function interactions_draw()
 local color=9
 if game.inverted then color=13 end
 for door in all(room.state.doors) do
  -- 开放的拱洞，没有门板；上下边框标示可通行的位置。
  rectfill(door.x,door.y,door.x+door.w-1,door.y+door.h-1,0)
  line(door.x,door.y,door.x+door.w-1,door.y,color)
  line(door.x,door.y+door.h-1,door.x+door.w-1,door.y+door.h-1,color)
  local center=door.x+4
  line(center-door.direction*2,door.y+10,center+door.direction*2,door.y+12,color)
  line(center+door.direction*2,door.y+12,center-door.direction*2,door.y+14,color)
 end
 for converter in all(room.state.converters) do
  rectfill(converter.x,converter.y+24,converter.x+23,converter.y+31,5)
  circfill(converter.x+12,converter.y+11,9,0)
  circ(converter.x+12,converter.y+11,9,color)
  line(converter.x+12,converter.y+11,converter.x+12,converter.y+4,12)
  line(converter.x+12,converter.y+11,converter.x+17,converter.y+14,12)
 end
end
