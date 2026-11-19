class_name MotorVisual
extends Node2D
## Motor paper-doll 5 slot (GDD 3.4 / 9.2). Sprite & hotspot sudah ada di scene.

signal slot_clicked(slot: int)

@export var hotspot_radius: float = 110.0
@export var drop_radius: float = 220.0

var _pulse_tweens: Dictionary = {}

@onready var slot_sprites: Dictionary = {
	PartData.Slot.BODY: [%Body],
	PartData.Slot.EXHAUST: [%Exhaust],
	PartData.Slot.ENGINE: [%Engine],
	PartData.Slot.WHEELS: [%RearWheel, %FrontWheel],
	PartData.Slot.LIGHT: [%Headlight],
}
@onready var hotspots: Dictionary = {
	PartData.Slot.BODY: %BodyHotspot,
	PartData.Slot.EXHAUST: %ExhaustHotspot,
	PartData.Slot.ENGINE: %EngineHotspot,
	PartData.Slot.WHEELS: %WheelsHotspot,
	PartData.Slot.LIGHT: %LightHotspot,
}
@onready var tags: Dictionary = {
	PartData.Slot.BODY: %BodyTag,
	PartData.Slot.EXHAUST: %ExhaustTag,
	PartData.Slot.ENGINE: %EngineTag,
	PartData.Slot.WHEELS: %WheelsTag,
	PartData.Slot.LIGHT: %LightTag,
}


## Posisi label slot relatif terhadap hotspot-nya (koordinat lokal motor, sebelum mirror).
const TAG_OFFSETS: Dictionary = {
	PartData.Slot.BODY: Vector2(0, -70),
	PartData.Slot.EXHAUST: Vector2(0, -70),
	PartData.Slot.ENGINE: Vector2(0, 0),
	PartData.Slot.WHEELS: Vector2(0, 125),
	PartData.Slot.LIGHT: Vector2(0, -75),
}


func _ready() -> void:
	%Headlight.visible = false ## preview lampu disembunyikan
	_fix_mirrored_tags()
	for slot: int in hotspots.keys():
		var area: Area2D = hotspots[slot]
		area.input_event.connect(_on_hotspot_input.bind(slot))
		area.mouse_entered.connect(_on_hotspot_hover.bind(slot, true))
		area.mouse_exited.connect(_on_hotspot_hover.bind(slot, false))


func show_order(order: ClientOrder) -> void:
	visible = order != null
	if order == null:
		return
	for slot: int in slot_sprites.keys():
		set_part(slot, order.current_parts[slot])
		var tag: Label = tags[slot]
		var ordered: bool = order.is_slot_ordered(slot)
		tag.text = ("* %s *" if ordered else "%s") % PartData.slot_to_name(slot).to_upper()
		tag.add_theme_color_override("font_color", Color(1, 0.902, 0) if ordered else Color(0.85, 0.85, 0.9))
	_layout_tags()


## Label slot ditaruh di tengah-atas/bawah hotspot masing-masing, ikut layout body.
func _layout_tags() -> void:
	for slot: int in tags.keys():
		var tag: Label = tags[slot]
		tag.reset_size()
		tag.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		tag.pivot_offset = Vector2(tag.size.x * 0.5, 0.0)
		var anchor: Vector2 = (hotspots[slot] as Area2D).position + TAG_OFFSETS[slot]
		tag.position = anchor - Vector2(tag.size.x * 0.5, tag.size.y * 0.5)


func set_part(slot: int, part: PartData) -> void:
	for sprite: Sprite2D in slot_sprites[slot]:
		sprite.texture = part.texture
		apply_facing(sprite)
	if slot == PartData.Slot.BODY:
		apply_body_layout(%Frame, %Engine, %Headlight, part)
		(hotspots[PartData.Slot.LIGHT] as Area2D).position = %Headlight.position


## Rangka & mesin mengikuti tipe body (diukur dari gambar referensi di tools/motor_refs).
## Posisi dalam koordinat lokal motor (motor di-mirror scale.x = -1).
const FRAME_TEXTURES: Array[Texture2D] = [
	preload("res://assets/baked_processed/mot_frame_sport.png"),
	preload("res://assets/baked_processed/mot_frame_bebek.png"),
]
const ENGINE_POSITIONS: Array[Vector2] = [Vector2(11.96, 84.9), Vector2(5.54, 114.3)]
const ENGINE_SCALES: Array[float] = [0.5086, 0.4441]
## Kanvas part 1200 px = gambar referensi 2000 px; sprite part di-scale 0.7.
const REF_TO_LOCAL: float = 0.6 * 0.7
const REF_CENTER: Vector2 = Vector2(1000, 707)
const HEADLIGHT_SCALE: float = 0.3


static func apply_body_layout(frame: Sprite2D, engine: Sprite2D, headlight: Sprite2D, body: PartData) -> void:
	var offset: Vector2 = (body.headlight_pos - REF_CENTER) * REF_TO_LOCAL
	headlight.position = Vector2(-offset.x, offset.y) ## motor di-mirror
	headlight.scale = Vector2.ONE * HEADLIGHT_SCALE
	var frame_type: int = clampi(body.frame_type, 0, FRAME_TEXTURES.size() - 1)
	frame.texture = FRAME_TEXTURES[frame_type]
	apply_facing(frame)
	engine.position = ENGINE_POSITIONS[frame_type]
	engine.scale = Vector2.ONE * ENGINE_SCALES[frame_type]


## Semua sprite final menghadap kiri. Placeholder "generated" masih menghadap kanan,
## jadi motor di-mirror (scale.x negatif di scene) dan aset baked dibalik lagi lewat flip_h.
static func apply_facing(sprite: Sprite2D) -> void:
	if sprite.texture == null:
		return
	sprite.flip_h = not sprite.texture.resource_path.contains("/generated/")


func _fix_mirrored_tags() -> void:
	if scale.x >= 0.0:
		return
	for tag: Label in tags.values():
		tag.pivot_offset = Vector2(tag.size.x * 0.5, 0.0)
		tag.scale.x = -1.0


func set_hotspots_enabled(enabled: bool) -> void:
	for area: Area2D in hotspots.values():
		area.input_pickable = enabled


func get_slot_position(slot: int) -> Vector2:
	return (hotspots[slot] as Area2D).global_position


func is_point_on_slot(slot: int, world_point: Vector2) -> bool:
	return get_slot_position(slot).distance_to(world_point) <= drop_radius


func highlight_slot(slot: int, enabled: bool) -> void:
	if _pulse_tweens.has(slot):
		(_pulse_tweens[slot] as Tween).kill()
		_pulse_tweens.erase(slot)
	for sprite: Sprite2D in slot_sprites[slot]:
		sprite.modulate = Color.WHITE
		if enabled:
			var tween: Tween = create_tween().set_loops()
			tween.tween_property(sprite, "modulate", Color(1.6, 1.4, 0.6), 0.35)
			tween.tween_property(sprite, "modulate", Color.WHITE, 0.35)
			_pulse_tweens[slot] = tween


func bounce(slot: int) -> void:
	for sprite: Sprite2D in slot_sprites[slot]:
		var base_scale: Vector2 = sprite.scale
		var tween: Tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		sprite.scale = base_scale * 1.25
		tween.tween_property(sprite, "scale", base_scale, 0.35)


func _on_hotspot_input(_viewport: Node, event: InputEvent, _shape_idx: int, slot: int) -> void:
	var mouse_event: InputEventMouseButton = event as InputEventMouseButton
	if mouse_event and mouse_event.pressed and mouse_event.button_index == MOUSE_BUTTON_LEFT:
		slot_clicked.emit(slot)


func _on_hotspot_hover(slot: int, hovered: bool) -> void:
	var tag: Label = tags[slot]
	for sprite: Sprite2D in slot_sprites[slot]:
		HoverOutline.set_hovered(sprite, hovered)
	var size: float = 1.2 if hovered else 1.0
	tag.scale = Vector2(signf(tag.scale.x) * size, size)
