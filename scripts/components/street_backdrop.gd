extends Node2D
## Latar jalan berlapis (aset "Background Latar Game"): langit, awan, bangunan, trotoar,
## toko bengkel & sparepart + rolling door. Ganti pagi/sore/malam mengikuti jam GameState.

enum Shutter { WORKSHOP, PARTS }

const TIMES: Array[StringName] = [&"pagi", &"sore", &"malam"]
const DOOR_NODES: Dictionary = {
	Shutter.WORKSHOP: "DoorWorkshopClosed",
	Shutter.PARTS: "DoorPartsClosed",
}

## Ikut jam in-game (otomatis ganti latar). Matikan untuk cutscene yang mengatur sendiri.
@export var follow_clock: bool = true
## Jam (menit) mulai sore & malam. 14:00 dan 18:00.
@export var sore_start_minutes: int = 840
@export var malam_start_minutes: int = 1080
@export var fade_duration: float = 2.0
@export var door_duration: float = 1.2

var current_time: StringName = &""
var _fade_tween: Tween

@onready var sets: Dictionary = {&"pagi": %Pagi, &"sore": %Sore, &"malam": %Malam}


func _ready() -> void:
	_share_signs()
	set_time(time_for_minutes(GameState.get_clock_minutes()) if follow_clock else &"pagi", false)
	if follow_clock:
		GameState.clock_changed.connect(_on_clock_changed)


func time_for_minutes(minutes: int) -> StringName:
	if minutes >= malam_start_minutes:
		return &"malam"
	if minutes >= sore_start_minutes:
		return &"sore"
	return &"pagi"


func set_time(time_id: StringName, animate: bool = true) -> void:
	if time_id == current_time or not sets.has(time_id):
		return
	var previous: Node2D = sets.get(current_time)
	current_time = time_id
	var target: Node2D = sets[time_id]
	if _fade_tween and _fade_tween.is_running():
		_fade_tween.kill()
	for id: StringName in TIMES:
		var layer: Node2D = sets[id]
		layer.visible = layer == target or (animate and layer == previous)
	move_child(target, get_child_count() - 1) # set baru digambar paling atas
	if not animate or previous == null:
		target.modulate.a = 1.0
		return
	# Set baru di atas set lama, fade in, lalu set lama disembunyikan.
	target.modulate.a = 0.0
	_fade_tween = create_tween()
	_fade_tween.tween_property(target, "modulate:a", 1.0, fade_duration)
	_fade_tween.tween_callback(func() -> void: previous.visible = false)


## Rolling door tertutup digulung ke atas (scale y -> 0, origin di sisi atas) di semua set waktu.
func set_door_open(door: int, open: bool, animate: bool = true) -> Tween:
	var tween: Tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	for id: StringName in TIMES:
		var closed: Sprite2D = (sets[id] as Node2D).get_node(DOOR_NODES[door]) as Sprite2D
		var target_scale: float = 0.0 if open else 1.0
		if animate:
			tween.tween_property(closed, "scale:y", target_scale, door_duration)
		else:
			closed.scale.y = target_scale
	if not animate:
		tween.kill()
		return null
	return tween


func _on_clock_changed(_day: int, minutes: int) -> void:
	set_time(time_for_minutes(minutes))


## Papan nama toko (node berakhiran "Title") cuma ditaruh di satu set di editor.
## Salin ke set waktu lain supaya tulisannya selalu tampil pagi/sore/malam.
func _share_signs() -> void:
	var source: Node2D = null
	for id: StringName in TIMES:
		var layer: Node2D = sets[id]
		for child: Node in layer.get_children():
			if String(child.name).ends_with("Title"):
				source = layer
				break
		if source:
			break
	if source == null:
		return
	for child: Node in source.get_children():
		if not String(child.name).ends_with("Title"):
			continue
		for id: StringName in TIMES:
			var layer: Node2D = sets[id]
			if layer != source and layer.get_node_or_null(NodePath(child.name)) == null:
				var copy: Node = child.duplicate()
				layer.add_child(copy)
