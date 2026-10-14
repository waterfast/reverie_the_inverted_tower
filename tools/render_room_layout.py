"""根据实际 room_tile 导出数据绘制整房间总览，不手工猜测地形。"""
from pathlib import Path
import json
from PIL import Image, ImageDraw, ImageFont
ROOT=Path(__file__).resolve().parents[1]
PALETTE=['000000','1d2b53','7e2553','008751','ab5236','5f574f','c2c3c7','fff1e8','ff004d','ffa300','ffec27','00e436','29adff','83769c','ff77a8','ffccaa']
CART=(ROOT/'reverie_the_inverted_tower.p8').read_text(encoding='utf-8')
GFX=CART.split('__gfx__\n')[1].split('\n__')[0].splitlines()
LAYOUTS=json.loads((ROOT/'docs/current_map_layout.json').read_text(encoding='utf-8'))
FONT='C:/Windows/Fonts/msyh.ttc'
font=ImageFont.truetype(FONT,20); small=ImageFont.truetype(FONT,16); title=ImageFont.truetype(FONT,26)
names=['时钟塔','月影回廊','封印书库','无声钟室']
def room_image(room):
    inverted=room['inverted']
    out=Image.new('RGB',(room['width'],room['height']),'#'+PALETTE[2 if inverted else 1])
    for ty,row in enumerate(room['tiles']):
        for tx,sprite in enumerate(row):
            if not sprite: continue
            sx,sy=sprite%16*8,sprite//16*8
            for y in range(8):
                for x in range(8):
                    color=int(GFX[sy+y][sx+x],16)
                    if not color: continue
                    if inverted: color={1:2,5:13}.get(color,color)
                    out.putpixel((tx*8+x,ty*8+y),tuple(bytes.fromhex(PALETTE[color])))
    d=ImageDraw.Draw(out); color='#'+PALETTE[13 if inverted else 9]
    for door in room['doors']:
        x,y,w,h=door['x'],door['y'],door['w'],door['h']; direction=door['direction']
        d.rectangle((x,y,x+w-1,y+h-1),fill='black')
        d.line((x,y,x+w-1,y),fill=color);d.line((x,y+h-1,x+w-1,y+h-1),fill=color)
        d.line([(x+4-direction*2,y+10),(x+4+direction*2,y+12),(x+4-direction*2,y+14)],fill=color)
    for converter in room['converters']:
        x,y,h=converter['x'],converter['y'],converter['h']
        for cy in (y+11,y+h-21):
            d.ellipse((x+3,cy-9,x+21,cy+9),fill='black',outline=color)
            d.line([(x+12,cy-7),(x+12,cy),(x+17,cy+3)],fill='#29adff')
        for cy in range(y+28,y+h-28,6): d.point((x+12,cy),fill=color)
    for enemy in room['enemies']:
        # 总览标出生怪位置，运行时倒重力会自然向上落，不假造另一张地图。
        sid={'melee':192,'ranged':196,'mage':200}[enemy['kind']]
        sx,sy=sid%16*8,sid//16*8
        for py in range(16):
            for px in range(16):
                c=int(GFX[sy+py][sx+px],16)
                if c: out.putpixel((int(enemy['x'])-3+px,int(enemy['y'])-4+py),tuple(bytes.fromhex(PALETTE[c])))
    # 白点标出每个命名入口，不混入运行中的角色/敌人位置。
    for entry in room['entries'].values():
        x,y=entry['x']+4,entry['y']+9
        d.rectangle((x-2,y-3,x+2,y+3),outline='#00e436')
    return out
for inverted in (False,True):
    rooms=[r for r in LAYOUTS if r['inverted']==inverted]
    overview=Image.new('RGB',(1504,520),'#101826');d=ImageDraw.Draw(overview)
    d.text((28,16),('镜世界' if inverted else '表城')+' · 共用房间布局（仅重力方向不同）',font=title,fill='#fff1e8')
    origins=[(28,140),(596,268),(908,268),(1220,268)]
    for room,(x,y) in zip(rooms,origins):
        im=room_image(room);overview.paste(im,(x,y));d.rectangle((x-1,y-1,x+room['width'],y+room['height']),outline='#5f6d85')
        d.text((x,y-56),str(room['id'])+' '+names[room['id']-1],font=font,fill='#fff1e8')
        d.text((x,y-30),f"{room['width']}×{room['height']} · map({room['map_x']},{room['map_y']})",font=small,fill='#b3c0d3')
        im.resize((room['width']*3,room['height']*3),Image.Resampling.NEAREST).save(ROOT/f"docs/previews/layout_{'reverse' if inverted else 'normal'}_room_{room['id']}.png")
    # 三条地板层连接均为右门到左门。
    for left,right in zip(origins,origins[1:]):
        idx=origins.index(left); x1=left[0]+rooms[idx]['width']+6;x2=right[0]-6;y=384
        d.line((x1,y,x2,y),fill='#ffa300',width=2)
        d.line([(x1+5,y-4),(x1,y),(x1+5,y+4)],fill='#ffa300',width=2)
        d.line([(x2-5,y-4),(x2,y),(x2-5,y+4)],fill='#ffa300',width=2)
    # A 对应两个高处洞口；曲折连线避开中间房间。
    points=[(848,326),(875,326),(875,172),(1195,172),(1195,326),(1224,326)]
    d.line(points,fill='#29adff',width=2)
    d.text((928,144),'A：2 右上 <-> 4 左上',font=font,fill='#29adff')
    for x,y in (points[0],points[-1]):d.ellipse((x-3,y-3,x+3,y+3),fill='#29adff')
    d.text((28,427),'低层：1 <-> 2 <-> 3 <-> 4     高层捷径 A：2 右上 <-> 4 左上',font=font,fill='#fff1e8')
    d.text((28,464),'钟盘：双向转换器（↑）    红/黄/紫：近战/弓手/法师    绿框：安全入口    门洞：走入自动换房',font=small,fill='#b3c0d3')
    overview.save(ROOT/f"docs/previews/current_map_{'reverse' if inverted else 'normal'}.png")
print('Rendered both worlds from effective map data')
