class_name MotorPreview
extends Node2D
## Motor paper-doll tanpa interaksi. Dipakai di antrean jalan supaya motor yang dibawa NPC
## sama persis dengan motor yang nanti dikerjakan di bengkel (ClientOrder.current_parts).

@onready var slot_sprites: Dictionary = {
	PartData.Slot.BODY: [%Body],
	PartData.Slot.EXHAUST: [%Exhaust],
	PartData.Slot.ENGINE: [%Engine],
	PartData.Slot.WHEELS: [%RearWheel, %FrontWheel],
	PartData.Slot.LIGHT: [%Headlight],
}


func show_order(order: ClientOrder) -> void:
	visible = order != null
	if order == null:
		return
	for slot: int in slot_sprites.keys():
		var part: PartData = order.current_parts.get(slot)
		if part == null:
			continue
		for sprite: Sprite2D in slot_sprites[slot]:
			sprite.texture = part.texture
			MotorVisual.apply_facing(sprite)
		if slot == PartData.Slot.BODY:
			MotorVisual.apply_body_layout(%Frame, %Engine, %Headlight, part)
