extends RefCounted
## Efek mengetik untuk dialog NPC + SFX "ngomong" tiap beberapa huruf.

const CHARS_PER_SEC: float = 45.0
const BLIP_EVERY: int = 3


static func play(label: Label, text: String, chars_per_sec: float = CHARS_PER_SEC) -> Tween:
	label.text = text
	label.visible_characters = 0
	var total: int = text.length()
	var state: Dictionary = {"last": 0}
	var tween: Tween = label.create_tween()
	tween.tween_method(func(value: float) -> void:
		var count: int = int(value)
		if count == int(state.last):
			return
		state.last = count
		label.visible_characters = count
		if count % BLIP_EVERY == 0 and count < total and text[count - 1] != " ":
			AudioManager.play_sfx(&"talk", 0.15)
		, 0.0, float(total), total / chars_per_sec)
	tween.tween_callback(func() -> void: label.visible_characters = -1)
	return tween
