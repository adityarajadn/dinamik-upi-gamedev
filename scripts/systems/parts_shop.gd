extends Node2D
## SC-03 Toko Sparepart Jaya: katalog 3x3, keranjang, checkout, restock 5 menit.

const Typewriter: GDScript = preload("res://scripts/utilities/typewriter.gd")

const KOH_IDLE: Texture2D = preload("res://assets/baked_processed/char_kohjaya_idle.png")
const KOH_SMILE: Texture2D = preload("res://assets/baked_processed/char_kohjaya_smile.png")
const CART_ROW_SCENE: PackedScene = preload("res://scenes/ui/components/cart_row.tscn")

@export var smile_duration: float = 1.6

var cart: Dictionary = {} ## offer_index -> quantity

@onready var hud: GameHUD = %HUD
@onready var koh_jaya: Sprite2D = %KohJaya
@onready var grid_cards: Array[Node] = %ShopGrid.get_children()
@onready var cart_items: VBoxContainer = %CartItems
@onready var cart_empty: Label = %CartEmpty
@onready var cart_total: Label = %CartTotal
@onready var checkout_button: Button = %CheckoutButton
@onready var countdown_label: Label = %CountdownLabel
@onready var koh_bubble: Label = %KohBubbleLabel


func _ready() -> void:
	if not GameState.is_session_active:
		GameState.new_game()
	for card: Node in grid_cards:
		(card as PartCard).card_pressed.connect(_on_card_pressed)
	checkout_button.pressed.connect(_on_checkout_pressed)
	%LeaveButton.pressed.connect(_exit_to_street)
	hud.exit_requested.connect(_exit_to_street)
	GameState.shop_restocked.connect(_on_restocked)
	GameState.restock_countdown_changed.connect(_on_countdown_changed)
	GameState.cash_changed.connect(func(_cash: int) -> void: _refresh_cart())
	GameState.set_clock_running(true)
	AudioManager.play_music(&"shop")
	_refresh_grid()
	_refresh_cart()
	_on_countdown_changed(GameState.get_restock_seconds_left())
	_bob_koh_jaya()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("cancel") and not hud.is_modal_open():
		get_viewport().set_input_as_handled()
		_exit_to_street()


func _refresh_grid() -> void:
	for i: int in range(grid_cards.size()):
		var card: PartCard = grid_cards[i] as PartCard
		if i < GameState.shop_offers.size():
			var offer: Dictionary = GameState.shop_offers[i]
			var remaining: int = int(offer.stock) - int(cart.get(i, 0))
			card.setup(offer.part, remaining, i)
			card.set_selected(cart.has(i))
		else:
			card.setup(null, 0)


func _refresh_cart() -> void:
	for child: Node in cart_items.get_children():
		if child != cart_empty:
			child.queue_free()
	var total: int = 0
	var indices: Array = cart.keys()
	indices.sort()
	for index: int in indices:
		var offer: Dictionary = GameState.shop_offers[index]
		var part: PartData = offer.part
		var quantity: int = cart[index]
		total += part.cost_price * quantity
		var row: CartRow = CART_ROW_SCENE.instantiate() as CartRow
		cart_items.add_child(row)
		row.setup(index, part, quantity, quantity < int(offer.stock))
		row.quantity_change_requested.connect(_on_quantity_change_requested)
		row.remove_requested.connect(_on_remove_requested)
	cart_empty.visible = cart.is_empty()
	cart_total.text = "TOTAL: %s" % Money.format(total)
	cart_total.add_theme_color_override("font_color", Color(1, 0.3, 0.3) if total > GameState.cash else Color(1, 0.902, 0))
	checkout_button.disabled = cart.is_empty() or total > GameState.cash


func _get_cart_total() -> int:
	var total: int = 0
	for index: int in cart.keys():
		total += (GameState.shop_offers[index].part as PartData).cost_price * int(cart[index])
	return total


func _on_quantity_change_requested(offer_index: int, delta: int) -> void:
	var stock: int = int(GameState.shop_offers[offer_index].stock)
	var quantity: int = clampi(int(cart.get(offer_index, 0)) + delta, 0, stock)
	if quantity <= 0:
		cart.erase(offer_index)
	else:
		cart[offer_index] = quantity
	AudioManager.play_sfx(&"click")
	_refresh_grid()
	_refresh_cart()


func _on_remove_requested(offer_index: int) -> void:
	cart.erase(offer_index)
	AudioManager.play_sfx(&"click")
	_refresh_grid()
	_refresh_cart()


func _on_card_pressed(card: PartCard) -> void:
	if card.stock <= 0:
		AudioManager.play_sfx(&"install_fail")
		_koh_say("Oops, that one's sold out, kid.")
		return
	cart[card.offer_index] = int(cart.get(card.offer_index, 0)) + 1
	AudioManager.play_sfx(&"click")
	_refresh_grid()
	_refresh_cart()


func _on_checkout_pressed() -> void:
	if cart.is_empty():
		return
	if not await hud.confirm("Buy everything in the cart for %s?" % Money.format(_get_cart_total()), "BUY"):
		return
	var items: Array[Dictionary] = []
	for index: int in cart.keys():
		items.append({"offer_index": index, "quantity": cart[index]})
	if GameState.purchase(items):
		AudioManager.play_sfx(&"coin")
		cart.clear()
		_refresh_grid()
		_refresh_cart()
		_koh_say("Thanks! Your parts are going straight to your workshop!")
		koh_jaya.texture = KOH_SMILE
		get_tree().create_timer(smile_duration).timeout.connect(func() -> void: koh_jaya.texture = KOH_IDLE)
	else:
		AudioManager.play_sfx(&"install_fail")
		_koh_say("Hmm, not enough money, kid. Take some items out first.")


func _on_restocked() -> void:
	cart.clear()
	_refresh_grid()
	_refresh_cart()
	_koh_say("Ding-dong! New stock just arrived, take your pick!")


func _on_countdown_changed(seconds_left: float) -> void:
	var total: int = int(ceil(seconds_left))
	countdown_label.text = "%02d:%02d Until New Stock!" % [floori(total / 60.0), total % 60]


func _koh_say(text: String) -> void:
	Typewriter.play(koh_bubble, text)


func _bob_koh_jaya() -> void:
	var base_y: float = koh_jaya.position.y
	var tween: Tween = create_tween().set_loops()
	tween.tween_property(koh_jaya, "position:y", base_y - 5.0, 0.8).set_trans(Tween.TRANS_SINE)
	tween.tween_property(koh_jaya, "position:y", base_y, 0.8).set_trans(Tween.TRANS_SINE)


func _exit_to_street() -> void:
	GameState.street_spawn_x = 2810.0
	AudioManager.play_sfx(&"door")
	SceneTransitionManager.change_scene(GameState.SCENE_STREET)
