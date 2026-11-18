"""Bake hand-drawn source art in assets/ into game-ready PNGs in assets/baked_processed/.

Source art is huge (characters up to ~6000x13000 px), so every file is resized here
once instead of being imported at full size. Re-run after changing source art:

    python tools/bake_assets.py

Motor parts keep their shared 4093x2894 canvas (paper-doll alignment) and are
scaled uniformly, so all non-wheel parts stack at the same position in Godot.
Wheels are cropped to the wheel itself because they are placed twice (front/rear).
"""
from pathlib import Path

from PIL import Image, ImageEnhance

ROOT = Path(__file__).resolve().parent.parent / "assets"
OUT = ROOT / "baked_processed"

MOTOR_CANVAS_W = 1200  # 4093 -> 1200 (scale ~0.2932)
CHAR_H = 640           # matches AnimatedSprite offset (0, -320)

CHAR = "NPC Karakter + MONTir _"
MONTIR = f"{CHAR}/SI Montir & bapak spare part_"
PERINTILAN = "Asset Perintilan"


def load(rel: str) -> Image.Image:
    return Image.open(ROOT / rel).convert("RGBA")


def crop(im: Image.Image) -> Image.Image:
    # Ambang alpha: beberapa file punya piksel nyaris transparan di luar gambar.
    box = im.getchannel("A").point(lambda v: 255 if v > 20 else 0).getbbox()
    return im.crop(box) if box else im


def fit_h(im: Image.Image, h: int) -> Image.Image:
    return im.resize((max(1, round(im.width * h / im.height)), h), Image.LANCZOS)


def fit_w(im: Image.Image, w: int) -> Image.Image:
    return im.resize((w, max(1, round(im.height * w / im.width))), Image.LANCZOS)


def fit_box(im: Image.Image, size: int) -> Image.Image:
    s = size / max(im.width, im.height)
    return im.resize((max(1, round(im.width * s)), max(1, round(im.height * s))), Image.LANCZOS)


def hue_shift(im: Image.Image, degrees: float) -> Image.Image:
    r, g, b, a = im.split()
    h, s, v = Image.merge("RGB", (r, g, b)).convert("HSV").split()
    h = h.point(lambda x: int(x + degrees * 255 / 360) % 256)
    rgb = Image.merge("HSV", (h, s, v)).convert("RGB")
    return Image.merge("RGBA", (*rgb.split(), a))


def darken(im: Image.Image, factor: float) -> Image.Image:
    a = im.getchannel("A")
    rgb = ImageEnhance.Brightness(im.convert("RGB")).enhance(factor)
    rgb = ImageEnhance.Color(rgb).enhance(0.6)
    rgb.putalpha(a)
    return rgb


def stack(folder: str, names: list[str]) -> Image.Image:
    out = None
    for n in names:
        im = load(f"{folder}/{n}.PNG")
        out = im if out is None else Image.alpha_composite(out, im)
    return out


def motor(rel: str) -> Image.Image:
    return fit_w(load(f"motor/{rel}"), MOTOR_CANVAS_W)


REF_W = 2000  # lebar gambar referensi di tools/motor_refs


def motor_xf(rel: str, s: float, tx: float, ty: float) -> Image.Image:
    """Tempatkan part ke kanvas motor dengan transform yang diukur dari gambar
    referensi (tools/motor_refs, lebar 2000): ref = s * sumber + (tx, ty)."""
    src = load(f"motor/{rel}")
    k = MOTOR_CANVAS_W / REF_W
    canvas_h = round(src.height * MOTOR_CANVAS_W / src.width)
    out = Image.new("RGBA", (MOTOR_CANVAS_W, canvas_h), (0, 0, 0, 0))
    scaled = src.resize((round(src.width * s * k), round(src.height * s * k)), Image.LANCZOS)
    out.alpha_composite(scaled, (round(tx * k), round(ty * k)))
    return out


def wheel(rel: str) -> Image.Image:
    im = crop(load(f"motor/velg/{rel}"))
    return im.resize((round(im.width * MOTOR_CANVAS_W / 4093), round(im.height * MOTOR_CANVAS_W / 4093)), Image.LANCZOS)


def char(rel: str) -> Image.Image:
    return fit_h(crop(load(f"{CHAR}/{rel}")), CHAR_H)


JOBS = {
    # --- Motor (paper-doll, shared canvas) ---
    # Rangka per tipe body (PartData.frame_type). Transform diukur dari referensi.
    "mot_base_frame": lambda: motor_xf("casis/Chassis Standar (Rangka Bawaan).png", 0.319, 399.7, 311.7),
    "mot_frame_sport": lambda: motor_xf("casis/Chassis Sport Tubular (Tralis).png", 0.319, 399.7, 311.7),
    "mot_frame_bebek": lambda: motor_xf("casis bebek/tier 2.png", 0.381, 312.2, 244.7),
    "part_bd_01": lambda: motor("body/Body Bebek Harian Kusam.png"),
    "part_bd_02": lambda: motor("body/Body Retro Classic Mint.png"),
    "part_bd_03": lambda: motor("body/Body Custom Naked Matte.png"),
    "part_bd_04": lambda: motor("body/Body Sporty Street Bold.png"),
    "part_bd_05": lambda: motor("body/Body Aerokit Full Carbon.png"),
    "part_ex_01": lambda: motor("knalpot/Knalpot Standar Berkarat A.png"),
    "part_ex_02": lambda: motor("knalpot/Knalpot Bobokan Chrome.png"),
    "part_ex_03": lambda: motor("knalpot/Knalpot Carbon Hexagonal.png"),
    "part_ex_04": lambda: motor("knalpot/Knalpot Dual-Underseat Twin.png"),
    "part_ex_05": lambda: motor("knalpot/Knalpot Racing Kolong Titanium.png"),
    "part_en_01": lambda: motor("mesin/Mesin Karbu 110cc Kotor.png"),
    "part_en_02": lambda: motor("mesin/Mesin Injeksi 125cc Bersih.png"),
    # Tidak ada aset tier 3: varian warna dari Injeksi 125cc.
    "part_en_03": lambda: hue_shift(motor("mesin/Mesin Injeksi 125cc Bersih.png"), 180),
    "part_en_04": lambda: motor("mesin/Mesin DOHC 150cc Gold.png"),
    "part_en_05": lambda: motor("mesin/Mesin Twin 250cc Turbo.png"),
    # Tidak ada aset tier 1: bohlam kuning yang digelapkan (redup).
    "part_lt_01": lambda: darken(motor("lampu/Lampu Bohlam Kaca Kuning.png"), 0.55),
    "part_lt_02": lambda: motor("lampu/Lampu Bohlam Kaca Kuning.png"),
    "part_lt_03": lambda: motor("lampu/Lampu Daymaker LED Projector.png"),
    "part_lt_04": lambda: motor("lampu/Lampu Dual Eye LED Agresif.png"),
    # Tidak ada aset tier 5: varian neon dari Dual Eye.
    "part_lt_05": lambda: hue_shift(motor("lampu/Lampu Dual Eye LED Agresif.png"), 150),
    "part_wh_01": lambda: wheel("Velg Jari-Jari 17 Karat.png"),
    "part_wh_02": lambda: wheel("Velg Racing Palang 5 Putih.png"),
    "part_wh_03": lambda: wheel("Velg Retro Monoblock Chrome.png"),
    "part_wh_04": lambda: wheel("Velg Forged Candy Blue.png"),
    # Tidak ada aset tier 5: varian pink dari Forged Candy Blue.
    "part_wh_05": lambda: hue_shift(wheel("Velg Forged Candy Blue.png"), 100),
    # --- Karakter ---
    "char_montir_idle": lambda: char("SI Montir & bapak spare part_/idle pose (1).png"),
    "char_montir_side": lambda: char("SI Montir & bapak spare part_/pose samping.png"),
    "char_montir_walk_a": lambda: char("SI Montir & bapak spare part_/walk .png"),
    "char_montir_walk_b": lambda: char("SI Montir & bapak spare part_/walk (1).png"),
    "char_montir_wrench": lambda: char("SI Montir & bapak spare part_/wrench .png"),
    "char_montir_panic": lambda: char("SI Montir & bapak spare part_/panic pose .png"),
    "char_montir_reflect": lambda: char("SI Montir & bapak spare part_/reflect pose .png"),
    "char_kohjaya_idle": lambda: char("SI Montir & bapak spare part_/idle pose .png"),
    "char_kohjaya_smile": lambda: char("SI Montir & bapak spare part_/happy pose .png"),
}

CLIENTS = {
    "sport": ("Anak sport_", {"idle": "idle pose ", "happy": "hapyy pose ", "angry": "angry pose ", "panic": "panic pose "}),
    "racing": ("Anak racing", {"idle": "idle pose ", "happy": "happy pose", "angry": "angry pose ", "panic": "panic pose "}),
    "bapak": ("Bapak bapak", {"idle": "idle pose ", "happy": "hapyy pose ", "angry": "angry pose ", "panic": "panic pose "}),
    "emak": ("Emak emak_", {"idle": "idle pose ", "happy": "happy pose ", "angry": "anggry pose ", "panic": "panic pose "}),
    "mahasiswa": ("Mahasiswa", {"idle": "idle pose ", "happy": "happy pose ", "angry": "anggry pose ", "panic": "panic pose "}),
}
for key, (folder, poses) in CLIENTS.items():
    for pose, fname in poses.items():
        JOBS[f"char_{key}_{pose}"] = (lambda f=folder, n=fname: char(f"{f}/{n}.png"))

JOBS.update({
    # --- Background ---
    "bg_workshop_interior": lambda: load("Background Area Dalam Bengkel/Sample/IMG_8889.PNG"),
    "bg_shop_interior": lambda: load("Background Area Dalam Spare Part/Sample/BACKGROUND FULL.PNG"),
    "bg_street_mid": lambda: load("Background Latar Game/Pagi/Sample/IMG_8999.PNG"),
    "bg_street_sky": lambda: load("Background Latar Game/Pagi/Aset/IMG_8983.PNG"),
    # Lapisan parallax street hub (Pagi): langit, awan, bangunan+trotoar (bidang player).
    "bg_street_clouds": lambda: stack("Background Latar Game/Pagi/Aset", ["IMG_8984", "IMG_8985", "IMG_8986", "IMG_8987"]),
    "bg_street_buildings": lambda: stack("Background Latar Game/Pagi/Aset", ["IMG_8959", "IMG_8975", "IMG_8978", "IMG_8988"]),
    "bg_street_mid_sore": lambda: load("Background Latar Game/Sore/sample/IMG_8995.PNG"),
    "bg_street_mid_malam": lambda: load("Background Latar Game/Malam/Sample/IMG_8981.PNG"),
    # --- Props ---
    "prop_table": lambda: fit_w(crop(load(f"{PERINTILAN}/Meja/MEJA KAYU.PNG")), 1000),
    "prop_jar_full": lambda: fit_h(crop(load(f"{PERINTILAN}/Toples dan Uang/TOPLES FULL RAKIT.PNG")), 256),
    "prop_jar_empty": lambda: fit_h(crop(load(f"{PERINTILAN}/Toples dan Uang/TOPLES FULL KOSONG.PNG")), 256),
    # --- FX ---
    "fx_smoke_cloud": lambda: fit_w(crop(load(f"{PERINTILAN}/Efek/Efek Asap Obeng_/EFEK ASAP.PNG")), 600),
    "fx_screwdriver_teal": lambda: fit_box(crop(load(f"{PERINTILAN}/Efek/Efek Asap Obeng_/OBENG 1.PNG")), 200),
    "fx_screwdriver_orange": lambda: fit_box(crop(load(f"{PERINTILAN}/Efek/Efek Asap Obeng_/OBENG 2.PNG")), 200),
    "fx_screwdriver_blue": lambda: fit_box(crop(load(f"{PERINTILAN}/Efek/Efek Asap Obeng_/OBENG 3.PNG")), 200),
    "fx_screwdriver_red": lambda: fit_box(crop(load(f"{PERINTILAN}/Efek/Efek Asap Obeng_/OBENG 4.PNG")), 200),
    # --- UI ---
    "ui_speech_bubble": lambda: fit_w(crop(load(f"{PERINTILAN}/Efek/Efek Bubble Chat/BUBBLE CHATT KOTAK 2.PNG")), 600),
    "icon_coins": lambda: fit_box(crop(load(f"{PERINTILAN}/Toples dan Uang/KOIN.PNG")), 128),
    "icon_banknotes": lambda: fit_box(crop(load(f"{PERINTILAN}/Toples dan Uang/UANG LEMBAR.PNG")), 128),
    "icon_smiley": lambda: fit_box(crop(load(f"{PERINTILAN}/Efek/Efek Stiker/SMILE.PNG")), 128),
    "icon_lightning": lambda: fit_box(crop(load(f"{PERINTILAN}/Efek/Efek Stiker/PETIR.PNG")), 128),
    "icon_flower": lambda: fit_box(crop(load(f"{PERINTILAN}/Efek/Efek Stiker/BUNGA.PNG")), 128),
    "icon_screwdriver": lambda: fit_box(crop(load(f"{PERINTILAN}/Efek/Efek Asap Obeng_/OBENG 1.PNG")), 128),
})


def main() -> None:
    OUT.mkdir(exist_ok=True)
    for name, job in JOBS.items():
        im = job()
        im.save(OUT / f"{name}.png", optimize=True)
        print(f"{name}.png {im.size}")


if __name__ == "__main__":
    main()
