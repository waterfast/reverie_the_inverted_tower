"""将生成的动作图编码成 PICO-8 精灵表；保留图集区域以外的数据。

此工具做确定性的尺寸、调色板与卡带格式转换，不生成或重绘角色。
运行前关闭旧卡带或先保存；运行后在 PICO-8 中重新 load。
"""

from pathlib import Path
import json
import re
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "assets/sprites/nyaru_actions_source_v1.png"
CART = ROOT / "reverie_the_inverted_tower.p8"
OUTPUT = ROOT / "assets/sprites"
FRAME_SIZE = 24
ATLAS_SIZE = FRAME_SIZE * 4
ATLAS_X = 8
PALETTE_HEX = [
    "000000", "1d2b53", "7e2553", "008751", "ab5236", "5f574f",
    "c2c3c7", "fff1e8", "ff004d", "ffa300", "ffec27", "00e436",
    "29adff", "83769c", "ff77a8", "ffccaa",
]
PALETTE = [tuple(bytes.fromhex(color)) for color in PALETTE_HEX]
NAMES = [
    "idle_0", "idle_1", "run_0", "run_1", "run_2", "run_3",
    "jump_0", "jump_1", "fall_0", "fall_1", "flip_0", "flip_1",
    "attack_0", "attack_1", "hurt_0", "hurt_1",
]


def nearest_color(rgb):
    # 0 号色留给透明背景，角色轮廓映射到深蓝，避免被 spr 擦掉。
    return min(range(1, 16), key=lambda index: sum(
        (rgb[channel] - PALETTE[index][channel]) ** 2 for channel in range(3)
    ))


def convert_frames():
    source = Image.open(SOURCE).convert("RGBA")
    # 透明图输出可能裁掉外围空白，因此用比例分格，允许尺寸不是 4 的倍数。
    cell_w, cell_h = source.width / 4, source.height / 4
    atlas = Image.new("RGBA", (ATLAS_SIZE, ATLAS_SIZE), (0, 0, 0, 0))
    records = []
    for frame, name in enumerate(NAMES):
        column, row = frame % 4, frame // 4
        cell = source.crop((round(column * cell_w), round(row * cell_h),
                            round((column + 1) * cell_w), round((row + 1) * cell_h)))
        # 忽略生成图外围接近透明的毛边，避免压缩时把空白当成角色。
        bounds = cell.getchannel("A").point(lambda a: 255 if a >= 128 else 0).getbbox()
        if bounds is None:
            raise ValueError(f"第 {frame} 帧为空")
        content = cell.crop(bounds)
        scale = min((FRAME_SIZE - 2) / content.width, (FRAME_SIZE - 2) / content.height)
        width = max(1, round(content.width * scale))
        height = max(1, round(content.height * scale))
        # 最近邻保留原图的色块对比，再量化成调色板纯色，不引入模糊。
        reduced = content.resize((width, height), Image.Resampling.NEAREST)
        tile = Image.new("RGBA", (FRAME_SIZE, FRAME_SIZE), (0, 0, 0, 0))
        left, top = (FRAME_SIZE - width) // 2, FRAME_SIZE - 1 - height
        for y in range(height):
            for x in range(width):
                r, g, b, alpha = reduced.getpixel((x, y))
                if alpha >= 96:
                    tile.putpixel((left + x, top + y), PALETTE[nearest_color((r, g, b))] + (255,))
        atlas.paste(tile, (column * FRAME_SIZE, row * FRAME_SIZE))
        records.append({"frame": frame, "name": name,
                        "sprite_id": row * 48 + 1 + column * 3})
    atlas.save(OUTPUT / "nyaru_actions_24.png")
    atlas.resize((576, 576), Image.Resampling.NEAREST).save(OUTPUT / "nyaru_actions_preview.png")
    (OUTPUT / "nyaru_frames.json").write_text(json.dumps(records, indent=2), encoding="utf-8")
    return atlas


def embed_atlas(atlas):
    text = CART.read_text(encoding="utf-8")
    match = re.search(r"(?ms)^__gfx__\r?\n(.*?)(?=^__[a-z]+__\s*$|\Z)", text)
    if match is None:
        raise ValueError("卡带缺少 __gfx__ 部分")
    existing = match.group(1).splitlines()
    rows = []
    for y in range(128):
        line = existing[y].strip() if y < len(existing) else ""
        if len(line) > 128 or any(char not in "0123456789abcdef" for char in line):
            raise ValueError("现有精灵数据格式不正确")
        rows.append(list(line.ljust(128, "0")))
    before = [row[:] for row in rows]
    for y in range(ATLAS_SIZE):
        for x in range(ATLAS_SIZE):
            r, g, b, alpha = atlas.getpixel((x, y))
            color = nearest_color((r, g, b)) if alpha else 0
            rows[y][x + ATLAS_X] = format(color, "x")
    # 明确验证写入只影响角色图集区域，用户原有左上角素材保留。
    for y in range(128):
        for x in range(128):
            if not (ATLAS_X <= x < ATLAS_X + ATLAS_SIZE and y < ATLAS_SIZE):
                assert before[y][x] == rows[y][x]
    sprite_data = "\n".join("".join(row) for row in rows) + "\n"
    CART.write_text(text[:match.start(1)] + sprite_data + text[match.end(1):], encoding="utf-8")

    # 该 PNG 与卡带精灵表完全一致，可在 PICO-8 中手动重新导入。
    sheet = Image.new("RGB", (128, 128))
    for y, row in enumerate(rows):
        for x, char in enumerate(row):
            sheet.putpixel((x, y), PALETTE[int(char, 16)])
    sheet.save(OUTPUT / "nyaru_pico8_sheet.png")


if __name__ == "__main__":
    embed_atlas(convert_frames())
    print("Imported 16 frames; original graphics outside the character area preserved.")
