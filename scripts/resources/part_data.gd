class_name PartData
extends Resource
## Konfigurasi satu varian komponen motor (GDD 3.4 & 9.1).
## Data statis bersama: jangan simpan state runtime di sini.

enum Slot { BODY, EXHAUST, ENGINE, WHEELS, LIGHT }

const SLOT_NAMES: Dictionary = {
	Slot.BODY: "Body",
	Slot.EXHAUST: "Exhaust",
	Slot.ENGINE: "Engine",
	Slot.WHEELS: "Wheels",
	Slot.LIGHT: "Light",
}

const TIER_NAMES: Dictionary = {
	1: "Cheap A",
	2: "Cheap B",
	3: "Mid A",
	4: "Mid B",
	5: "Premium",
}

@export var part_id: StringName = &"BD-01"
@export var slot: Slot = Slot.BODY
@export var display_name: String = "Part"
@export_range(1, 5) var tier: int = 1
@export var cost_price: int = 0
@export var selling_price: int = 0
@export var value_score: int = 10
@export var texture: Texture2D
## Khusus slot BODY: tipe rangka yang dipakai (menentukan sprite rangka & posisi mesin).
@export_enum("Sport", "Bebek") var frame_type: int = 0
## Khusus slot BODY: titik tengah lampu depan, dalam piksel gambar referensi 2000x1414
## (tools/motor_refs). Sprite lampu ditaruh di sini.
@export var headlight_pos: Vector2 = Vector2(600, 300)


var _icon: Texture2D


## Ikon UI: texture dipotong ke area yang terisi, karena sprite part memakai kanvas
## motor penuh (paper-doll) sehingga bagian part-nya kecil di tengah area kosong.
func get_icon() -> Texture2D:
	if _icon != null or texture == null:
		return _icon if _icon != null else texture
	var image: Image = texture.get_image()
	if image == null:
		_icon = texture
		return _icon
	if image.is_compressed():
		image.decompress()
	var used: Rect2i = image.get_used_rect()
	if used.size == Vector2i.ZERO or used.size == image.get_size():
		_icon = texture
		return _icon
	var atlas: AtlasTexture = AtlasTexture.new()
	atlas.atlas = texture
	atlas.region = Rect2(used)
	_icon = atlas
	return _icon


func get_slot_name() -> String:
	return SLOT_NAMES.get(slot, "?")


func get_tier_name() -> String:
	return TIER_NAMES.get(tier, "?")


static func slot_to_name(target_slot: int) -> String:
	return SLOT_NAMES.get(target_slot, "?")
