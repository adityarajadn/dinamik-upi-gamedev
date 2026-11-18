class_name UIButtonAnimation
extends Button
## Animasi hover/press untuk Button (standar 11.2) + bunyi klik opsional.

@export var hover_scale: float = 1.05
@export var press_scale: float = 0.94
@export var animation_duration: float = 0.12
@export var play_click_sound: bool = true

var base_scale: Vector2 = Vector2.ONE
var current_tween: Tween


func _ready() -> void:
	base_scale = scale
	_update_pivot()
	resized.connect(_update_pivot)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	focus_entered.connect(_on_mouse_entered)
	focus_exited.connect(_on_mouse_exited)
	button_down.connect(_on_button_down)
	button_up.connect(_on_button_up)
	pressed.connect(_on_pressed)


func _update_pivot() -> void:
	pivot_offset = size * 0.5


func _animate_scale(target_scale: Vector2) -> void:
	if current_tween and current_tween.is_running():
		current_tween.kill()
	current_tween = create_tween()
	current_tween.set_trans(Tween.TRANS_CUBIC)
	current_tween.set_ease(Tween.EASE_OUT)
	current_tween.tween_property(self, "scale", target_scale, animation_duration)


func _on_mouse_entered() -> void:
	if disabled:
		return
	_animate_scale(base_scale * hover_scale)


func _on_mouse_exited() -> void:
	_animate_scale(base_scale)


func _on_button_down() -> void:
	if disabled:
		return
	_animate_scale(base_scale * press_scale)


func _on_button_up() -> void:
	if disabled:
		return
	if get_global_rect().has_point(get_global_mouse_position()):
		_animate_scale(base_scale * hover_scale)
	else:
		_animate_scale(base_scale)


func _on_pressed() -> void:
	if play_click_sound:
		AudioManager.play_sfx(&"click")
