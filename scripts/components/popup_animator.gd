class_name PopupAnimator
extends Node
## Animasi masuk/keluar panel (fade + scale). Pasang sebagai child dari Control target.

signal shown
signal hidden

@export var target_path: NodePath = ^".."
@export var duration: float = 0.25
@export var start_scale: float = 0.85

var _tween: Tween

@onready var target: Control = get_node(target_path) as Control


func show_popup() -> void:
	if not is_instance_valid(target):
		return
	_kill()
	target.pivot_offset = target.size * 0.5
	target.scale = Vector2.ONE * start_scale
	target.modulate.a = 0.0
	target.visible = true
	_tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_tween.tween_property(target, "scale", Vector2.ONE, duration)
	_tween.tween_property(target, "modulate:a", 1.0, duration * 0.8)
	_tween.chain().tween_callback(shown.emit)


func hide_popup() -> void:
	if not is_instance_valid(target) or not target.visible:
		return
	_kill()
	target.pivot_offset = target.size * 0.5
	_tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	_tween.tween_property(target, "scale", Vector2.ONE * start_scale, duration * 0.7)
	_tween.tween_property(target, "modulate:a", 0.0, duration * 0.7)
	_tween.chain().tween_callback(func() -> void:
		target.visible = false
		target.scale = Vector2.ONE
		hidden.emit())


func _kill() -> void:
	if _tween and _tween.is_running():
		_tween.kill()
