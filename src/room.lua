function room_world_key()
 if game.inverted then return "reverse" end
 return "normal"
end

-- 使用卡带地图中的不同矩形区域作为房间，不在运行时覆盖手绘地图。
function room_enter(id,entry)
 local definition=rooms[id]
 local state=definition.normal
 room={id=id,definition=definition,state=state,
  width=definition.columns*room_config.tile_size,
  height=definition.rows*room_config.tile_size}
 game.entry=entry or "west"
 local spawn=state.entries[game.entry] or state.entries.west
 local invincible=0
 if player then invincible=player.invincible end
 player_init()
 player.invincible=invincible
 player.x=spawn.x
 player.y=spawn.y
 player.gravity=game.inverted and -1 or 1
 if game.entry=="east" or game.entry=="high_east" then player.facing=-1 end
 -- 倒重力入口仍沿用同一坐标，允许自然落到上方支撑面。
 player.grounded=room_blocked(player.x,player.y+player.gravity,player.w,player.h)
 enemies_init()
 view_init()
 game.transition=12
 local visited=game.visited.normal
 if game.inverted then visited=game.visited.reverse end
 visited[id]=true
end

-- 统一的地形读取入口：绘制和碰撞都必须使用它，避免画面与实体错位。
function room_tile(tile_x,tile_y)
 local definition=room.definition
 if tile_x<0 or tile_y<0 or tile_x>=definition.columns
  or tile_y>=definition.rows then return 0 end
 -- 先应用共用通道和平台，再读卡带；此过程完全不读取世界状态。
 -- 绘制和碰撞同时读取这些覆盖，不能只画一个黑洞却仍然撞墙。
 for door in all(room.state.doors) do
  if tile_x*8>=door.x and tile_x*8<door.x+door.w
   and tile_y*8>=door.y and tile_y*8<door.y+door.h then return 0 end
 end
 for platform in all(room.state.platforms) do
  if tile_y*8==platform.y and tile_x*8>=platform.x
   and tile_x*8<platform.x+platform.w then return 15 end
 end
 for area in all(room.state.clear_areas) do
  if tile_x*8>=area.x and tile_x*8<area.x+area.w
   and tile_y*8>=area.y and tile_y*8<area.y+area.h then return 0 end
 end
 return mget(definition.map_x+tile_x,definition.map_y+tile_y)
end

function room_blocked(x,y,w,h)
 -- 地图外当作墙壁；擦掉边界砖也不会掉出房间。
 if x<0 or y<0 or x+w>room.width or y+h>room.height then return true end
 local size=room_config.tile_size
 local left=flr(x/size)
 local top=flr(y/size)
 local right=ceil((x+w)/size)-1
 local bottom=ceil((y+h)/size)-1
 for tile_y=top,bottom do
  for tile_x=left,right do
   if fget(room_tile(tile_x,tile_y),room_config.solid_flag) then return true end
  end
 end
 return false
end
