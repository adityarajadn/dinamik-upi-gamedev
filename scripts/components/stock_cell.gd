class_name StockCell
extends VBoxContainer
## Sel stok di buku kas: ikon part + jumlah. Pudar bila stok habis.

@onready var icon: TextureRect = %Icon
@onready var tier_label: Label = %TierLabel
@onready var count_label: Label = %CountLabel


func setup(part: PartData, count: int) -> void:
	icon.texture = part.get_icon()
	tier_label.text = "T%d" % part.tier
	count_label.text = "x%d" % count
	modulate = Color.WHITE if count > 0 else Color(1, 1, 1, 0.3)
	tooltip_text = "%s (%s)" % [part.display_name, part.part_id]
