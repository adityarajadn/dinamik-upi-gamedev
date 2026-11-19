extends Node2D
## Cutscene pembuka: langit + judul -> turun ke jalan -> pan kiri ke kanan lihat antrean
## di depan bengkel yang masih tutup -> rolling door naik, montir di dalam -> masuk Workshop.
## Klik / tombol apa saja untuk skip.

const StreetBackdrop: GDScript = preload("res://scripts/components/street_backdrop.gd")
const SCENE_WORKSHOP: String = "res://scenes/levels/workshop.tscn"

@export var title_hold: float = 1.6
@export var descend_duration: float = 2.2
@export var pan_duration: float = 4.0
@export var door_open_duration: float = 1.4

var _finished: bool = false

@onready var camera: Camera2D = %Camera2D
@onready var title: Control = %Title
@onready var backdrop: Node2D = %StreetBackdrop
@onready var queue_clients: Array[Node] = %QueueClients.get_children()
@onready var skip_hint: Label = %SkipHint


func _ready() -> void:
	if not GameState.is_session_active:
		GameState.new_game()
	GameState.set_clock_running(false)
	AudioManager.play_music(&"street")
	# Pagi, bengkel & toko masih tutup.
	backdrop.set_time(&"pagi", false)
	backdrop.set_door_open(StreetBackdrop.Shutter.WORKSHOP, false, false)
	backdrop.set_door_open(StreetBackdrop.Shutter.PARTS, false, false)
	_fill_queue()
	_play()


func _unhandled_input(event: InputEvent) -> void:
	var pressed: bool = (event is InputEventKey and event.pressed and not event.echo) \
		or (event is InputEventMouseButton and event.pressed)
	if pressed:
		get_viewport().set_input_as_handled()
		_finish()


## NPC antre di cutscene = klien yang benar-benar sedang antre hari ini.
func _fill_queue() -> void:
	for i: int in range(queue_clients.size()):
		var sprite: Sprite2D = queue_clients[i] as Sprite2D
		sprite.visible = i < GameState.queue.size()
		if sprite.visible:
			sprite.texture = GameState.queue[i].profile.texture_idle


func _play() -> void:
	var tween: Tween = create_tween()
	tween.tween_interval(title_hold)
	# Turun dari langit ke ujung kiri jalan.
	tween.tween_property(camera, "position", Vector2(960.0, 540.0), descend_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.parallel().tween_property(title, "modulate:a", 0.0, descend_duration * 0.6)
	# Pan kiri ke kanan menyusuri antrean, berhenti di depan bengkel.
	tween.tween_property(camera, "position:x", 1900.0, pan_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_interval(0.5)
	tween.tween_callback(AudioManager.play_sfx.bind(&"door", 0.0))
	tween.tween_callback(func() -> void: backdrop.set_door_open(StreetBackdrop.Shutter.WORKSHOP, true))
	tween.tween_interval(0.01)
	tween.parallel().tween_property(camera, "zoom", Vector2.ONE * 1.35, door_open_duration).set_trans(Tween.TRANS_SINE)
	tween.tween_interval(backdrop.door_duration + 0.6)
	tween.tween_callback(_finish)


func _finish() -> void:
	if _finished:
		return
	_finished = true
	skip_hint.visible = false
	SceneTransitionManager.change_scene(SCENE_WORKSHOP, "fade")
