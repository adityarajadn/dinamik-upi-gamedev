extends CanvasLayer
## Transisi scene reusable. API: await SceneTransitionManager.change_scene(path, "fade").

signal transition_finished

const EFFECTS: PackedStringArray = ["fade", "swipe_left", "swipe_right", "instant"]

@export var fade_duration: float = 0.35
@export var swipe_duration: float = 0.4

var is_transitioning: bool = false

@onready var transition_rect: ColorRect = $TransitionRoot/TransitionRect


func _ready() -> void:
	transition_rect.modulate.a = 0.0
	transition_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE


func change_scene(scene_path: String, effect: String = "fade") -> void:
	if is_transitioning:
		return
	if not EFFECTS.has(effect):
		push_warning("SceneTransitionManager: efek '%s' tidak dikenal, pakai fade" % effect)
		effect = "fade"
	if not ResourceLoader.exists(scene_path):
		push_error("SceneTransitionManager: scene '%s' tidak ditemukan" % scene_path)
		return
	is_transitioning = true
	transition_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	await _cover(effect)
	get_tree().paused = false
	var error: Error = get_tree().change_scene_to_file(scene_path)
	if error != OK:
		push_error("SceneTransitionManager: gagal ganti scene (%s)" % error_string(error))
	await get_tree().process_frame
	await _reveal(effect)
	transition_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	is_transitioning = false
	transition_finished.emit()


func _cover(effect: String) -> void:
	var viewport_width: float = get_viewport().get_visible_rect().size.x
	transition_rect.position.x = 0.0
	match effect:
		"instant":
			transition_rect.modulate.a = 1.0
			return
		"swipe_left":
			transition_rect.modulate.a = 1.0
			transition_rect.position.x = viewport_width
		"swipe_right":
			transition_rect.modulate.a = 1.0
			transition_rect.position.x = -viewport_width
	var tween: Tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	if effect == "fade":
		tween.tween_property(transition_rect, "modulate:a", 1.0, fade_duration)
	else:
		tween.tween_property(transition_rect, "position:x", 0.0, swipe_duration)
	await tween.finished


func _reveal(effect: String) -> void:
	var viewport_width: float = get_viewport().get_visible_rect().size.x
	if effect == "instant":
		transition_rect.modulate.a = 0.0
		return
	var tween: Tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	match effect:
		"swipe_left":
			tween.tween_property(transition_rect, "position:x", -viewport_width, swipe_duration)
		"swipe_right":
			tween.tween_property(transition_rect, "position:x", viewport_width, swipe_duration)
		_:
			tween.tween_property(transition_rect, "modulate:a", 0.0, fade_duration)
	await tween.finished
	transition_rect.modulate.a = 0.0
	transition_rect.position.x = 0.0
