class_name PartCard
extends PanelContainer
## Kartu komponen. Mode TRAY: tekan & tahan untuk drag. Mode SHOP: klik menambah ke keranjang.

signal drag_requested(card: PartCard)
signal card_pressed(card: PartCard)

enum Mode { TRAY, SHOP }

@export var mode: Mode = Mode.TRAY

var part: PartData
var stock: int = 0
var offer_index: int = -1
var _hover_tween: Tween

@onready var id_label: Label = %IdLabel
@onready var icon_rect: TextureRect = %Icon
@onready var name_label: Label = %NameLabel
@onready var price_label: Label = %PriceLabel
@onready var stock_label: Label = %StockLabel


func _ready() -> void:
	gui_input.connect(_on_gui_input)
	mouse_entered.connect(_on_hover.bind(true))
	mouse_exited.connect(_on_hover.bind(false))
	resized.connect(func() -> void: pivot_offset = size * 0.5)


func setup(new_part: PartData, new_stock: int, new_offer_index: int = -1) -> void:
	part = new_part
	stock = new_stock
	offer_index = new_offer_index
	if part == null:
		visible = false
		return
	visible = true
	id_label.text = "%s  T%d" % [part.part_id, part.tier]
	icon_rect.texture = part.get_icon()
	name_label.text = part.display_name
	if mode == Mode.SHOP:
		price_label.text = Money.format(part.cost_price)
		stock_label.text = "Sisa: %d" % stock
	else:
		price_label.text = "Jual %s" % Money.short(part.selling_price)
		stock_label.text = "[Stok: %d]" % stock
	modulate = Color(1, 1, 1, 1) if stock > 0 else Color(0.55, 0.55, 0.6, 0.85)


func set_selected(is_selected: bool) -> void:
	theme_type_variation = &"CardSelected" if is_selected else &"CardPanel"


func _on_gui_input(event: InputEvent) -> void:
	if part == null:
		return
	var mouse_event: InputEventMouseButton = event as InputEventMouseButton
	if mouse_event == null or mouse_event.button_index != MOUSE_BUTTON_LEFT or not mouse_event.pressed:
		return
	accept_event()
	if mode == Mode.TRAY:
		drag_requested.emit(self)
	else:
		card_pressed.emit(self)


func _on_hover(is_hovered: bool) -> void:
	if part != null:
		HoverOutline.set_hovered(icon_rect, is_hovered, 8.0)
	if _hover_tween and _hover_tween.is_running():
		_hover_tween.kill()
	_hover_tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_hover_tween.tween_property(self, "scale", Vector2.ONE * (1.05 if is_hovered else 1.0), 0.12)
