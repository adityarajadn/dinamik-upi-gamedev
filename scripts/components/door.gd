class_name Door
extends Area2D
## Pintu gedung di jalanan. Prompt muncul saat player dekat (GDD 3.1 #2).

@export_file("*.tscn") var target_scene: String = ""
@export var return_spawn_x: float = 0.0

var _tween: Tween

@onready var prompt: Control = $Prompt


func _ready() -> void:
	prompt.visible = false
	prompt.modulate.a = 0.0


func set_highlighted(is_highlighted: bool) -> void:
	if _tween and _tween.is_running():
		_tween.kill()
	prompt.visible = true
	_tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_tween.tween_property(prompt, "modulate:a", 1.0 if is_highlighted else 0.0, 0.15)
	if not is_highlighted:
		_tween.tween_callback(func() -> void: prompt.visible = false)
