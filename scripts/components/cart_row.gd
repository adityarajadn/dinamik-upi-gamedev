class_name CartRow
extends PanelContainer
## Satu baris keranjang ala marketplace: ikon, nama, harga, tombol - jumlah +, hapus.

signal quantity_change_requested(offer_index: int, delta: int)
signal remove_requested(offer_index: int)

var offer_index: int = -1

@onready var icon: TextureRect = %Icon
@onready var name_label: Label = %NameLabel
@onready var price_label: Label = %PriceLabel
@onready var quantity_label: Label = %QuantityLabel
@onready var minus_button: Button = %MinusButton
@onready var plus_button: Button = %PlusButton
@onready var remove_button: Button = %RemoveButton


func _ready() -> void:
	minus_button.pressed.connect(func() -> void: quantity_change_requested.emit(offer_index, -1))
	plus_button.pressed.connect(func() -> void: quantity_change_requested.emit(offer_index, 1))
	remove_button.pressed.connect(func() -> void: remove_requested.emit(offer_index))


func setup(index: int, part: PartData, quantity: int, can_add_more: bool) -> void:
	offer_index = index
	icon.texture = part.get_icon()
	icon.flip_h = false
	name_label.text = part.display_name
	price_label.text = "%s  x%d = %s" % [Money.format(part.cost_price), quantity, Money.format(part.cost_price * quantity)]
	quantity_label.text = str(quantity)
	plus_button.disabled = not can_add_more
