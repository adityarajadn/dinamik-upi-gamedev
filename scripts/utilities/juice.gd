class_name Juice
extends RefCounted
## Animasi feedback kecil yang dipakai ulang: bounce (uang masuk) dan shake (rugi).

const META_TWEEN: StringName = &"_juice_tween"
const META_BASE_SCALE: StringName = &"_juice_base_scale"
const META_BASE_ROTATION: StringName = &"_juice_base_rotation"


static func bounce(target: CanvasItem, strength: float = 0.25) -> void:
	var base_scale: Vector2 = _prepare(target)
	var tween: Tween = target.create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	target.set_meta(META_TWEEN, tween)
	tween.tween_property(target, "scale", base_scale * Vector2(1.0 - strength * 0.4, 1.0 + strength), 0.08)
	tween.tween_property(target, "scale", base_scale * Vector2(1.0 + strength * 0.3, 1.0 - strength * 0.3), 0.1)
	tween.tween_property(target, "scale", base_scale, 0.3)


static func shake(target: CanvasItem, angle_degrees: float = 12.0, times: int = 4) -> void:
	_prepare(target)
	var base_rotation: float = target.get_meta(META_BASE_ROTATION)
	var tween: Tween = target.create_tween().set_trans(Tween.TRANS_SINE)
	target.set_meta(META_TWEEN, tween)
	for i: int in range(times):
		var falloff: float = 1.0 - float(i) / float(times)
		tween.tween_property(target, "rotation", base_rotation + deg_to_rad(angle_degrees * falloff), 0.05)
		tween.tween_property(target, "rotation", base_rotation - deg_to_rad(angle_degrees * falloff), 0.05)
	tween.tween_property(target, "rotation", base_rotation, 0.05)


static func _prepare(target: CanvasItem) -> Vector2:
	if target.has_meta(META_TWEEN):
		var previous: Tween = target.get_meta(META_TWEEN) as Tween
		if previous and previous.is_valid():
			previous.kill()
	if not target.has_meta(META_BASE_SCALE):
		target.set_meta(META_BASE_SCALE, target.get("scale"))
		target.set_meta(META_BASE_ROTATION, target.get("rotation"))
	var control: Control = target as Control
	if control:
		control.pivot_offset = control.size * 0.5
	target.set("scale", target.get_meta(META_BASE_SCALE))
	target.set("rotation", target.get_meta(META_BASE_ROTATION))
	return target.get_meta(META_BASE_SCALE)
