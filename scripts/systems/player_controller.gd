class_name PlayerController
extends CharacterBody2D
## Root player jalanan: koordinasi movement, animasi, interaksi.

@onready var movement: SideScrollMovement = $PlayerMovement
@onready var animation: PlayerAnimation = $PlayerAnimation
@onready var interaction: PlayerInteraction = $PlayerInteraction


func _ready() -> void:
	movement.initialize(self)


func _physics_process(delta: float) -> void:
	movement.physics_update(delta)
	move_and_slide()
	animation.update_animation(velocity)


func set_controls_enabled(enabled: bool) -> void:
	movement.can_move = enabled
	interaction.can_interact = enabled
	if not enabled:
		velocity = Vector2.ZERO
