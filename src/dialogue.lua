-- 内容与字模在 dialogue_data.lua，运行时只处理逐字、翻页与暂停。
function dialogue_start(id)
 local pages=stories[id]
 if not pages then return end
 dialogue={pages=pages,page=1,revealed=0,tick=0}
 player.attack_timer=0
end

function dialogue_count(page)
 local count=0
 for text in all(page.lines) do count=count+#text/2 end
 return count
end

function dialogue_update()
 local d=dialogue
 d.tick=d.tick+1
 local count=dialogue_count(d.pages[d.page])
 if d.tick%3==0 then d.revealed=min(count,d.revealed+1) end
 if btnp(controls.jump) or btnp(controls.attack) then
  if d.revealed<count then d.revealed=count
  elseif d.page<#d.pages then
   d.page=d.page+1
   d.revealed=0
  else dialogue=nil end
 end
end

function dialogue_glyph(id,x,y,color)
 local bitmap=dialogue_font[id]
 if not bitmap then return end
 for row=0,11 do
  local bits=tonum("0x"..sub(bitmap,row*3+1,row*3+3))
  for column=0,11 do
   if band(bits,2^(11-column))~=0 then pset(x+column,y+row,color) end
  end
 end
end

function dialogue_draw()
 if not dialogue then return end
 local page=dialogue.pages[dialogue.page]
 rectfill(2,67,125,125,1)
 rect(2,67,125,125,13)
 print(page.speaker,7,71,10)
 local remaining=dialogue.revealed
 for row=1,#page.lines do
  local text=page.lines[row]
  for index=1,#text/2 do
   if remaining>0 then
    dialogue_glyph(tonum("0x"..sub(text,index*2-1,index*2)),7+(index-1)*12,80+(row-1)*12,7)
    remaining=remaining-1
   end
  end
 end
 print("z/x >",99,119,6)
end
