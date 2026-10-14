"""手绘网格式像素素材，写入空闲图集；不改猫雷与地图 tile。"""
from pathlib import Path
import re
from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[1]
PALETTE = ['000000','1d2b53','7e2553','008751','ab5236','5f574f','c2c3c7','fff1e8',
           'ff004d','ffa300','ffec27','00e436','29adff','83769c','ff77a8','ffccaa']


def enemy(kind, frame):
    art = Image.new('P', (16, 16), 0)
    draw = ImageDraw.Draw(art)
    color = {'melee': 8, 'ranged': 9, 'mage': 13}[kind]
    # 同族面罩、火羽徽记，武器和剪影区分职责。
    draw.polygon([(4,3),(7,1),(10,3),(11,8),(3,8)],fill=1)
    draw.polygon([(5,3),(7,2),(9,3),(10,6),(4,6)],fill=color)
    draw.rectangle((5,5,9,7),fill=5)
    draw.point((6,6),fill=10); draw.point((8,6),fill=10)
    draw.polygon([(4,8),(10,8),(11,13),(3,13)],fill=color)
    draw.line((4,9,3,12),fill=1); draw.line((10,9,11,12),fill=1)
    draw.line((7,9,7,11),fill=10); draw.point((8,10),fill=7)
    draw.rectangle((4-frame,14,5,15),fill=6)
    draw.rectangle((9,14,10+frame,15),fill=6)
    if kind == 'melee':
        draw.polygon([(1,8),(4,8),(4,12),(2,14),(0,12)],fill=6)
        draw.line((2,9,2,12),fill=8)
        draw.line((12,8,12,13),fill=4)
        draw.line((11,9,14,9),fill=10)
        draw.line((12,3+frame,12,8),fill=7)
        draw.point((13,4+frame),fill=6)
    elif kind == 'ranged':
        draw.arc((10,4,15,13),-80,80,fill=10)
        draw.line((13,5,13,12),fill=4)
        draw.line((10,8+frame,15,8+frame),fill=7)
        draw.rectangle((2,7,3,11),fill=4)
        draw.line((1,5,3,8),fill=6)
    else:
        draw.polygon([(3,4),(6,0),(9,4)],fill=13)
        draw.line((10,4,12,4),fill=13)
        draw.line((13,5,13,15),fill=4)
        draw.ellipse((11,1+frame,15,5+frame),fill=12)
        draw.point((13,2+frame),fill=7)
        draw.point((7,1),fill=10)
    return art


def main():
    cart = ROOT / 'reverie_the_inverted_tower.p8'
    text = cart.read_text(encoding='utf-8')
    match = re.search(r'(?ms)^__gfx__\n(.*?)(?=^__[a-z]+__|\Z)', text)
    rows = [list(row.ljust(128,'0')) for row in match.group(1).splitlines()]
    while len(rows) < 128:
        rows.append(list('0'*128))
    sheet = Image.new('P',(96,32),0)
    for kind_index, kind in enumerate(['melee','ranged','mage']):
        for frame in range(2):
            sheet.paste(enemy(kind,frame),(kind_index*32+frame*16,0))
    draw = ImageDraw.Draw(sheet)
    draw.rectangle((3,30,12,31),fill=5)
    draw.line((7,23,7,30),fill=6)
    draw.rectangle((3,20,12,22),fill=4)
    draw.line((4,16,11,16),fill=6)
    draw.line((4,16,4,20),fill=6); draw.line((11,16,11,20),fill=6)
    draw.rectangle((19,19,28,28),fill=4)
    draw.rectangle((20,20,27,26),fill=15)
    draw.line((23,28,23,31),fill=5)
    draw.line((21,22,26,22),fill=4); draw.line((21,24,25,24),fill=4)
    for y in range(32):
        for x in range(96):
            if rows[y+96][x] not in ('0', format(sheet.getpixel((x,y)), 'x')):
                raise ValueError('目标图集不为空，请先确认未占用素材（不自动覆盖）。')
    for y in range(32):
        for x in range(96):
            rows[y+96][x] = format(sheet.getpixel((x,y)), 'x')
    text = text[:match.start(1)]+'\n'.join(''.join(row) for row in rows)+'\n'+text[match.end(1):]
    cart.write_text(text,encoding='utf-8')
    sheet.putpalette([channel for color in PALETTE for channel in bytes.fromhex(color)])
    rgba=sheet.convert('RGBA')
    alpha = Image.new('L', sheet.size)
    alpha.putdata([0 if value == 0 else 255 for value in sheet.getdata()])
    rgba.putalpha(alpha)
    rgba.save(ROOT / 'assets/sprites/enemies_props.png')
    preview=Image.new('RGB',(96,48),'#1d2b53')
    preview.paste(rgba,(0,8),rgba)
    preview.resize((768,384),Image.Resampling.NEAREST).save(ROOT / 'docs/previews/enemies_props.png')


if __name__ == '__main__':
    main()
