"""从已确认的局部 PNG 恢复角色，不改地图、flag 或角色区域外的素材。"""
import re
from PIL import Image
from import_character import ROOT, CART, ATLAS_X, ATLAS_SIZE, nearest_color, embed_atlas

atlas = Image.open(ROOT / "assets/sprites/nyaru_actions_24.png").convert("RGBA")
assert atlas.size == (ATLAS_SIZE, ATLAS_SIZE)
text = CART.read_text(encoding="utf-8")
raw = re.search(r"(?ms)^__gfx__\n(.*?)(?=^__[a-z]+__\s*$|\Z)", text).group(1).splitlines()
changed = 0
for y in range(ATLAS_SIZE):
    for x in range(ATLAS_SIZE):
        r, g, b, alpha = atlas.getpixel((x, y))
        expected = nearest_color((r, g, b)) if alpha else 0
        current = int(raw[y][x + ATLAS_X], 16) if y < len(raw) else 0
        changed += current != expected
embed_atlas(atlas)
print(f"Restored {changed} changed character pixels; map and other sprite regions preserved.")
