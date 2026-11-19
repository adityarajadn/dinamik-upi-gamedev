class_name PlayerAnimation
extends Node
## Memilih animasi berdasarkan kecepatan dan arah hadap.
## Saat jalan, sprite digoyang kiri-kanan (rotasi) supaya terasa melangkah.

@export var sprite_path: NodePath
@export var walk_threshold: float = 10.0
## Sudut goyang maksimum saat jalan (derajat).
@export var wobble_angle_deg: float = 6.0
## Jumlah goyangan per detik.
@export var wobble_speed: float = 2.5
## Kecepatan kembali ke tegak saat berhenti.
@export var wobble_return_speed: float = 12.0

var _wobble_time: float = 0.0
var _last_step_side: int = 0

@onready var sprite: AnimatedSprite2D = get_node(sprite_path) as AnimatedSprite2D


func update_animation(velocity: Vector2) -> void:
	if not is_instance_valid(sprite):
		return
	var delta: float = get_process_delta_time() if not Engine.is_in_physics_frame() else get_physics_process_delta_time()
	if absf(velocity.x) > walk_threshold:
		sprite.flip_h = velocity.x > 0.0 ## sprite default menghadap kiri
		if sprite.animation != &"walk":
			sprite.play(&"walk")
		_wobble_time += delta
		var wave: float = sin(_wobble_time * TAU * wobble_speed)
		sprite.rotation = deg_to_rad(wobble_angle_deg) * wave
		# SFX langkah tiap kali goyangan pindah sisi (= satu langkah kaki).
		var side: int = 1 if wave >= 0.0 else -1
		if side != _last_step_side:
			_last_step_side = side
			AudioManager.play_sfx(&"step", 0.12)
	else:
		if sprite.animation != &"idle":
			sprite.play(&"idle")
		_wobble_time = 0.0
		_last_step_side = 0
		sprite.rotation = lerpf(sprite.rotation, 0.0, clampf(wobble_return_speed * delta, 0.0, 1.0))
