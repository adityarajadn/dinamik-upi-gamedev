extends Node2D
## SC-01 Street Hub: jalan A/D, lihat antrean (maks 5), masuk Toko / Bengkel.

## Animasi "napas" NPC antre: hanya scale vertikal.
@export var queue_squash_amount: float = 0.04

const StreetBackdrop: GDScript = preload("res://scripts/components/street_backdrop.gd")

@onready var player: PlayerController = $Player
@onready var backdrop: Node2D = $StreetBackdrop
@onready var hud: GameHUD = $HUD
@onready var queue_spots: Array[Node] = $QueueSpots.get_children()


func _ready() -> void:
	if not GameState.is_session_active:
		GameState.new_game()
	# Saat main, bengkel & toko sparepart buka (rolling door terangkat).
	backdrop.set_door_open(StreetBackdrop.Shutter.WORKSHOP, true, false)
	backdrop.set_door_open(StreetBackdrop.Shutter.PARTS, true, false)
	player.global_position.x = GameState.street_spawn_x
	player.reset_physics_interpolation() ## teleport spawn: jangan di-interpolasi dari posisi scene
	player.interaction.interact_requested.connect(_on_interact_requested)
	hud.exit_requested.connect(func() -> void: pass)
	GameState.queue_changed.connect(_on_queue_changed)
	_on_queue_changed(GameState.get_waiting_count())
	_start_queue_bobbing()
	GameState.set_clock_running(true)
	AudioManager.play_music(&"street")
	if GameState.day == 1 and GameState.clients_served_total == 0 and GameState.day_time < 5.0:
		hud.show_toast("A/D untuk jalan, E untuk masuk Bengkel (kiri) atau Toko Sparepart (kanan)")


func _on_interact_requested(door: Door) -> void:
	player.set_controls_enabled(false)
	GameState.street_spawn_x = door.return_spawn_x
	AudioManager.play_sfx(&"door")
	SceneTransitionManager.change_scene(door.target_scene, "fade")


func _on_queue_changed(_waiting_count: int) -> void:
	for i: int in range(queue_spots.size()):
		var spot: Node2D = queue_spots[i] as Node2D
		var has_client: bool = i < GameState.queue.size()
		spot.visible = has_client
		if not has_client:
			continue
		var order: ClientOrder = GameState.queue[i]
		(spot.get_node("Client") as Sprite2D).texture = order.profile.texture_idle
		(spot.get_node("Motor") as MotorPreview).show_order(order)
		(spot.get_node("NameTag") as Label).text = order.profile.client_name


func _start_queue_bobbing() -> void:
	for i: int in range(queue_spots.size()):
		var client: Sprite2D = (queue_spots[i] as Node2D).get_node("Client") as Sprite2D
		var base_scale_y: float = client.scale.y
		var base_y: float = client.position.y
		var squash: Callable = func(value: float) -> void:
			# Geser y supaya kaki (sisi bawah sprite) tetap menapak saat scale vertikal berubah.
			var height: float = float(client.texture.get_height()) if client.texture else 0.0
			var feet_local: float = client.offset.y + (height * 0.5 if client.centered else height)
			client.scale.y = value
			client.position.y = base_y - feet_local * (value - base_scale_y)
		var tween: Tween = create_tween().set_loops()
		tween.tween_interval(0.15 * i)
		tween.tween_method(squash, base_scale_y, base_scale_y * (1.0 + queue_squash_amount), 0.6).set_trans(Tween.TRANS_SINE)
		tween.tween_method(squash, base_scale_y * (1.0 + queue_squash_amount), base_scale_y, 0.6).set_trans(Tween.TRANS_SINE)
