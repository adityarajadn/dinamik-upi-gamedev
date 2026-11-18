class_name SideScrollMovement
extends Node
## Gerak horizontal tanpa gravitasi (GDD 3.3). Root memanggil physics_update lalu move_and_slide.

@export var move_speed: float = 220.0
@export var acceleration_time: float = 0.05

var body: CharacterBody2D
var can_move: bool = true


func initialize(target_body: CharacterBody2D) -> void:
	body = target_body


func physics_update(delta: float) -> void:
	if not is_instance_valid(body):
		return
	var direction: float = Input.get_axis("move_left", "move_right") if can_move else 0.0
	var target_speed: float = direction * move_speed
	var step: float = move_speed / maxf(acceleration_time, 0.001) * delta
	body.velocity.x = move_toward(body.velocity.x, target_speed, step)
	body.velocity.y = 0.0
