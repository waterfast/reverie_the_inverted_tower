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
for _,name in ipairs({'config','rooms','room','view','player_animation','player','interactions','combat','enemies','drawing','main'}) do
 dofile(root..'/'..name..'.lua')
end
local function step(n) for _=1,n do _update60(); pressed={} end end
local function check(condition,message) assert(condition,message) end
_init(); step(15)
check(player.grounded and player.y==230,'initial spawn')
-- 所有世界入口都不能穿墙，且必须有地面支撑。
for _,inverted in ipairs({false,true}) do
 game.inverted=inverted
 for id,definition in ipairs(rooms) do
  local state=inverted and definition.reverse or definition.normal
  for entry in pairs(state.entries) do
   room_enter(id,entry)
   check(not room_blocked(player.x,player.y,player.w,player.h),'clear spawn '..id..' '..entry..' '..tostring(inverted))
   check(player.grounded,'supported spawn '..id..' '..entry)
   _draw()
  end
  -- 通道实际走入；目标入口放开按键后不能立即返回。
  for _,door in ipairs(state.doors) do
   room_enter(id,'west'); game.transition=0
   player.x=door.direction>0 and door.x-player.w+1 or door.x+door.w-1
   player.y=door.y+door.h-player.h
   player.vx=door.direction
   check(not room_blocked(player.x,player.y,player.w,player.h),'clear portal '..id)
   check(room_check_portals(),'automatic portal')
   check(room.id==door.target and game.entry==door.entry,'portal destination')
   held={}; step(20)
   check(room.id==door.target,'arrival does not bounce')
  end
  room_enter(id,'converter'); game.transition=0
  local old_world=game.inverted
  game.hp=3
  check(room_interact(),'converter enters')
  check(game.inverted~=old_world and game.hp==3,'world change preserves health')
  game.transition=0
  check(room_interact() and game.inverted==old_world,'converter returns')
  check(not room_blocked(player.x,player.y,player.w,player.h),'safe conversion')
 end
end
-- 核验真实水平走入门，而非只调用入口函数。
_init(); player.x=480; player.invincible=600
held[1]=true; step(24); held={}
check(room.id==2,'walk right through tower wall')
step(15); held[0]=true; step(24); held={}
check(room.id==1,'walk back through passage wall')
-- 每扇出口都有位置相对的反向通道，防止把右门连接到另一个右门。
for _,inverted in ipairs({false,true}) do
 game.inverted=inverted
 for id,definition in ipairs(rooms) do
  local state=inverted and definition.reverse or definition.normal
  for _,door in ipairs(state.doors) do
   local target=inverted and rooms[door.target].reverse or rooms[door.target].normal
   local entry=target.entries[door.entry]
   local expected=door.direction>0 and 24 or rooms[door.target].columns*8-40
   check(entry.x==expected,'opposite-wall arrival')
   local paired=false
   for _,back in ipairs(target.doors) do
    if back.target==id and back.direction==-door.direction and back.y==door.y then paired=true end
    -- 时钟塔高度不同，低门只要求双方都位于各自地板。
    if back.target==id and back.direction==-door.direction
     and door.y==definition.rows*8-32 and back.y==rooms[door.target].rows*8-32 then paired=true end
   end
   check(paired,'paired return portal')
  end
 end
 -- 真实爬台阶走入高门，回廊从左向右，钟室从右向左。
 for _,id in ipairs({2,4}) do
  room_enter(id,id==2 and 'west' or 'east'); player.invincible=1000
  local direction=id==2 and 1 or -1
  held[direction==1 and 1 or 0]=true
  local launches=id==2 and {38,94,126,164} or {178,148,116,86}
  local launch=1
  for frame=1,260 do
   if launches[launch] and player.grounded and (player.x-launches[launch])*direction>=0 then
    pressed[4]=true; launch=launch+1
   end
   step(1)
   if room.id~=id then break end
  end
  held={}
  local expected_entry=id==2 and 'high_west' or 'high_east'
  check(room.id==6-id and game.entry==expected_entry,'reachable high exit '..id..' '..tostring(inverted))
 end
 -- 复现用户一直按右的情况：不能在 2/4 之间反复跳转。
 room_enter(2,'high_east'); player.invincible=1000
 held[1]=true; step(120); held={}
 check(room.id==4,'holding right cannot cycle through shortcut')
 room_enter(4,'high_west'); player.invincible=1000
 held[0]=true; step(120); held={}
 check(room.id==2,'holding left cannot cycle through shortcut')
end
-- 单次挥击只扣一次；恢复结束才能再次攻击，死亡记忆按世界分开。
_init(); room_enter(2,'west'); game.transition=0
local enemy=enemies[1]
player.x=enemy.x-20; player.y=enemy.y+enemy.h-player.h; player.facing=1
pressed[5]=true; step(1)
check(player.animation=='attack','attack animation')
step(9); check(enemy.hp==1,'one hit per swing')
step(15); pressed[5]=true; step(10)
check(enemy.hp==0,'second swing defeats guard')
room_enter(2,'west'); check(#enemies==0,'defeated guard stays defeated')
game.inverted=true; room_enter(2,'west'); check(#enemies==1,'mirror enemy separate')
-- 穿墙攻击不成立。只在测试内插入砖，不更改卡带。
game.inverted=false; game.defeated.normal={}; room_enter(2,'west')
enemy=enemies[1]; player.x=152; player.y=102; enemy.x=172
local previous=cells[14][84]; cells[14][84]=14
check(not attack_visible(enemy),'wall blocks zap')
cells[14][84]=previous
-- 受伤无敌、死亡等待和回复生命的入口重生。
_init(); player_take_damage(1,-1)
check(game.hp==4 and player.attack_timer==0,'damage')
check(not player_take_damage(1,1) and game.hp==4,'invulnerability')
step(60); check(player_take_damage(4,1) and game.hp==0,'lethal damage')
step(combat_config.respawn_frames)
check(game.hp==5 and game.death_timer==0 and player.invincible>0,'respawn')
check(player.x==24 and player.grounded,'respawn at entrance')
log('PASS: spawns, portals, reversible converters, high routes, attacks, walls, persistent enemies, damage and respawn')
