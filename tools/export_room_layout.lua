-- 普通 Lua 检查真实卡带地图与房间逻辑。用法：lua tools/check_movement.lua src
abs=math.abs; min=math.min; max=math.max; flr=math.floor; ceil=math.ceil
sgn=function(x) return x<0 and -1 or 1 end
mid=function(a,b,c) return max(min(a,c),min(max(a,c),b)) end
all=function(t) local i=0; return function() i=i+1; return t[i] end end
local held,pressed={},{}
btn=function(n) return held[n] or false end
btnp=function(n) return pressed[n] or false end
local noop=function() end
cls=noop; line=noop; circ=noop; circfill=noop; rect=noop; rectfill=noop
pset=noop; spr=noop; clip=noop; camera=noop; map=noop; pal=noop; menuitem=noop
local log=print; print=noop
local root=arg[1] or 'src'
local file=assert(io.open(root..'/../reverie_the_inverted_tower.p8','rb'))
local text=file:read('*a'):gsub('\r','')..'\n__end__\n'; file:close()
local raw=assert(text:match('__map__\n(.-)\n__'))
local flag_text=assert(text:match('__gff__\n(.-)\n__')):gsub('%s','')
local cells={}; local row=0
for line in raw:gmatch('[^\n]+') do
 cells[row]={}
 for column=0,127 do cells[row][column]=tonumber(line:sub(column*2+1,column*2+2),16) or 0 end
 row=row+1
end
mget=function(x,y) return cells[y] and cells[y][x] or 0 end
fget=function(id,flag)
 local flags=tonumber(flag_text:sub(id*2+1,id*2+2),16) or 0
 return math.floor(flags/2^flag)%2==1
end
add=table.insert
for _,name in ipairs({'config','rooms','room','view','player_animation','player','interactions','combat','enemies','drawing','dialogue_data','dialogue','flip_effect','decorations','main'}) do
 dofile(root..'/'..name..'.lua')
end
-- 从运行中的 room_tile 导出有效地形，包含共用门洞和所有覆盖。
local function json(value)
 local kind=type(value)
 if kind=='number' or kind=='boolean' then return tostring(value) end
 if kind=='string' then return string.format('%q',value) end
 local parts={}
 if #value>0 then
  for _,item in ipairs(value) do parts[#parts+1]=json(item) end
  return '['..table.concat(parts,',')..']'
 end
 for key,item in pairs(value) do parts[#parts+1]=json(key)..':'..json(item) end
 return '{'..table.concat(parts,',')..'}'
end
_init()
local layouts={}
for _,inverted in ipairs({false,true}) do
 game.inverted=inverted
 for id,definition in ipairs(rooms) do
  room_enter(id,'west')
  local tiles={}
  for y=0,definition.rows-1 do
   local row={}
   for x=0,definition.columns-1 do row[#row+1]=room_tile(x,y) end
   tiles[#tiles+1]=row
  end
  layouts[#layouts+1]={id=id,inverted=inverted,name=room.state.name,
   width=room.width,height=room.height,map_x=definition.map_x,map_y=definition.map_y,
   tiles=tiles,doors=room.state.doors,entries=room.state.entries,
   converters=room.state.converters,enemies=room.state.enemies,
   lamps=room.state.lamps,talks=room.state.talks}
 end
end
local output=assert(io.open(root..'/../docs/current_map_layout.json','w'))
output:write(json(layouts)); output:close()
log('Exported effective room layouts')
