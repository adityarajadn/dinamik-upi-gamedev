class_name OrderRow
extends PanelContainer
## Satu baris pesanan ringkas: ikon part target, slot + tier, status centang.

const COLOR_PENDING: Color = Color(0.3, 0.3, 0.36, 1)
const COLOR_DONE: Color = Color(0.3, 0.85, 0.45, 1)
const COLOR_WARNING: Color = Color(1, 0.4, 0, 1)

@onready var icon: TextureRect = %Icon
@onready var slot_label: Label = %SlotLabel
@onready var note_label: Label = %NoteLabel
@onready var status_box: Panel = %StatusBox
@onready var status_label: Label = %StatusLabel


func setup(order: ClientOrder, slot: int) -> void:
	var target: PartData = order.get_target_part(slot)
	var done: bool = order.installed_by_player[slot]
	icon.texture = target.get_icon()
	slot_label.text = "%s  T%d" % [PartData.slot_to_name(slot), target.tier]
	var note: String = ""
	if done and (order.current_parts[slot] as PartData).tier != target.tier:
		note = "Installed T%d" % (order.current_parts[slot] as PartData).tier
	note_label.text = note
	note_label.visible = not note.is_empty()
	var box: StyleBoxFlat = (status_box.get_theme_stylebox("panel") as StyleBoxFlat).duplicate() as StyleBoxFlat
	box.bg_color = COLOR_DONE if done else COLOR_PENDING
	status_box.add_theme_stylebox_override("panel", box)
	status_label.text = "✔" if done else ""
