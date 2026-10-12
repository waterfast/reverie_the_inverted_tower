-- 地图几何只保存一次；门、转换器、敌人和少量补充平台按世界配置。
-- 坐标都是房间内的像素。门贴左右边界，entry 是目标房间的安全落点。
rooms={
 {map_x=0,map_y=0,columns=64,rows=32,
  normal={name="clock tower",color=1},
  reverse={name="fallen tower",color=2}},
 {map_x=64,map_y=0,columns=32,rows=16,
  normal={name="moon passage",color=1},
  reverse={name="eclipse passage",color=2}},
 {map_x=96,map_y=0,columns=32,rows=16,
  normal={name="sealed archive",color=1},
  reverse={name="forgotten archive",color=2}},
 {map_x=64,map_y=16,columns=32,rows=16,
  normal={name="silent bell",color=1},
  reverse={name="awakened bell",color=2}}
}

-- 目前先用对称的出口搭系统；之后直接分别编辑 normal/reverse 数据。
-- 不合并两侧的表，避免修改逆城时意外改到表城。
function rooms_configure()
 for id=1,#rooms do
  local definition=rooms[id]
  local width=definition.columns*8
  local floor=definition.rows*8-8
  for world=1,2 do
   local state=definition.normal
   if world==2 then state=definition.reverse end
   state.entries={west={x=24,y=floor-18},east={x=width-40,y=floor-18},
    converter={x=116,y=floor-18}}
   state.doors={}
   if id>1 then
    add(state.doors,{x=0,y=floor-24,w=8,h=24,direction=-1,
     target=id-1,entry="east"})
   end
   if id<#rooms then
    add(state.doors,{x=width-8,y=floor-24,w=8,h=24,direction=1,
     target=id+1,entry="west"})
   end
   state.converters={{x=112,y=floor-32,w=24,h=32,entry="converter"}}
   -- 每个世界有独立的敌人位置与击败记录；角色生命值跨房间保留。
   local enemy_x=184
   if id==1 then enemy_x=192 end
   if world==2 then enemy_x=enemy_x+24 end
   state.enemies={{id="guard",x=enemy_x,y=floor-12,hp=2,speed=0.45,
    color=8,damage=1}}
   if world==2 then state.enemies[1].color=13 end
   state.platforms={}
   state.clear_areas={}
   -- 每条横向连接都成对配置：右出口对应目标左入口，反向同理。
   -- 高处捷径：回廊右上 <-> 钟室左上，不再把两间房的右门互相连接。
   if id==2 then
    state.clear_areas={{x=80,y=24,w=176,h=80}}
    state.entries.high_east={x=216,y=54}
    add(state.doors,{x=248,y=48,w=8,h=24,direction=1,
     target=4,entry="high_west"})
    state.platforms={
     {x=80,y=104,w=24}, {x=112,y=88,w=24},
     {x=152,y=72,w=24}, {x=192,y=72,w=64}
    }
   elseif id==4 then
    -- 左上入口有接地平台；清空区域避开 x=0 的边墙，只由门洞打开墙。
    state.clear_areas={{x=8,y=24,w=168,h=80}}
    state.entries.high_west={x=24,y=54}
    add(state.doors,{x=0,y=48,w=8,h=24,direction=-1,
     target=2,entry="high_east"})
    state.platforms={
     {x=0,y=72,w=64}, {x=80,y=72,w=24},
     {x=112,y=88,w=24}, {x=144,y=104,w=24}
    }
   end
  end
 end
end

