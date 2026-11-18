class_name ClientProfile
extends Resource
## Persona klien: nama, sprite ekspresi, dan template dialog (GDD 3.5).

@export var client_id: StringName = &"doni"
@export var client_name: String = "Klien"
@export var persona: String = ""
@export var texture_idle: Texture2D
@export var texture_happy: Texture2D
@export var texture_angry: Texture2D
@export var texture_panic: Texture2D
@export var scooter_tint: Color = Color.WHITE
## Toleransi budget di atas harga jual standar (GDD: 0% - 20%).
@export_range(0.0, 0.5) var budget_tolerance_max: float = 0.2
## Placeholder: {parts}, {budget}
@export_multiline var request_lines: PackedStringArray = PackedStringArray()
## Placeholder: {slot}, {budget}
@export_multiline var twist_lines: PackedStringArray = PackedStringArray()
@export_multiline var happy_lines: PackedStringArray = PackedStringArray()
@export_multiline var neutral_lines: PackedStringArray = PackedStringArray()
@export_multiline var angry_lines: PackedStringArray = PackedStringArray()


func pick_line(lines: PackedStringArray, rng: RandomNumberGenerator) -> String:
	if lines.is_empty():
		return "..."
	return lines[rng.randi_range(0, lines.size() - 1)]
