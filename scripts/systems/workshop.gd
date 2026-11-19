extends Node2D
## SC-02 Workshop Interior: terima pesanan, zoom slot, drag & drop part, revisi dadakan, serah terima.

const ORDER_ROW_SCENE: PackedScene = preload("res://scenes/ui/components/order_row.tscn")
const TWIST_STATS_SCENE: PackedScene = preload("res://scenes/ui/components/twist_stats.tscn")
const Typewriter: GDScript = preload("res://scripts/utilities/typewriter.gd")

enum State { IDLE, ZOOMED, DRAGGING, TWIST, RESULT }

@export var zoom_level: float = 1.55
@export var zoom_duration: float = 0.35
@export var install_anim_duration: float = 0.8
@export var twist_delay: float = 0.9
@export var sticky_drag_threshold: float = 16.0
@export var order_panel_margin: float = 16.0

var state: State = State.IDLE
var order: ClientOrder
var selected_slot: int = -1
var dragging_card: PartCard
var _camera_tween: Tween
var _default_camera_position: Vector2
var _drag_start_position: Vector2
var _is_sticky_drag: bool = false
var _order_open: bool = true
var _order_tween: Tween
var _twist_stats: Dictionary = {} ## TwistChoice -> TwistStats

@onready var camera: Camera2D = $Camera2D
@onready var motor: MotorVisual = $Motor
@onready var client_sprite: Sprite2D = $Client
@onready var player_sprite: AnimatedSprite2D = $PlayerAvatar
@onready var piggy_bank: Area2D = $PiggyBank
@onready var clang: Sprite2D = $Fx/Clang
@onready var smoke: Node2D = $Fx/Smoke
@onready var smoke_cloud: Sprite2D = $Fx/Smoke/Cloud
@onready var sparks: CPUParticles2D = $Fx/Sparks
@onready var hud: GameHUD = $HUD

@onready var bubble: PanelContainer = %Bubble
@onready var bubble_label: Label = %BubbleLabel
@onready var order_panel: PanelContainer = %OrderPanel
@onready var client_name_label: Label = %ClientNameLabel
@onready var order_lines: VBoxContainer = %OrderLines
@onready var budget_label: Label = %BudgetLabel
@onready var estimate_label: Label = %EstimateLabel
@onready var progress_bar: ProgressBar = %ProgressBar
@onready var deliver_button: Button = %DeliverButton
@onready var close_order_button: Button = %CloseOrderButton
@onready var open_order_button: Button = %OpenOrderButton
@onready var tray: PanelContainer = %Tray
@onready var tray_popup: PopupAnimator = %Tray/PopupAnimator
@onready var tray_title: Label = %TrayTitle
@onready var tray_cards: Array[Node] = %TrayCards.get_children()
@onready var drag_ghost: TextureRect = %DragGhost
@onready var twist_overlay: Control = %TwistOverlay
@onready var twist_popup: PopupAnimator = %TwistPanel/PopupAnimator
@onready var twist_portrait: TextureRect = %TwistPortrait
@onready var twist_dialog: Label = %TwistDialog
@onready var result_overlay: Control = %ResultOverlay
@onready var result_popup: PopupAnimator = %ResultPanel/PopupAnimator


func _ready() -> void:
	if not GameState.is_session_active:
		GameState.new_game()
	get_viewport().physics_object_picking = true
	_default_camera_position = camera.position
	tray.visible = false
	drag_ghost.visible = false
	twist_overlay.visible = false
	result_overlay.visible = false
	clang.visible = false
	motor.slot_clicked.connect(_on_slot_clicked)
	piggy_bank.input_event.connect(_on_piggy_input)
	piggy_bank.mouse_entered.connect(_on_piggy_hover.bind(true))
	piggy_bank.mouse_exited.connect(_on_piggy_hover.bind(false))
	hud.exit_requested.connect(_exit_to_street)
	deliver_button.pressed.connect(_on_deliver_pressed)
	close_order_button.pressed.connect(_set_order_open.bind(false))
	open_order_button.pressed.connect(_set_order_open.bind(true))
	%TrayClose.pressed.connect(_close_zoom)
	%AcceptButton.pressed.connect(_on_twist_choice.bind(ClientOrder.TwistChoice.ACCEPT))
	%AbsorbButton.pressed.connect(_on_twist_choice.bind(ClientOrder.TwistChoice.ABSORB_LOSS))
	%RejectButton.pressed.connect(_on_twist_choice.bind(ClientOrder.TwistChoice.REJECT))
	%ContinueButton.pressed.connect(_on_result_continue)
	for card: Node in tray_cards:
		(card as PartCard).drag_requested.connect(_on_card_drag_requested)
	GameState.inventory_changed.connect(_refresh_tray)
	GameState.queue_changed.connect(_on_queue_changed)
	GameState.set_clock_running(true)
	AudioManager.play_music(&"workshop")
	_load_client()
	if GameState.tutorial_pending:
		hud.show_tutorial()


func _process(_delta: float) -> void:
	if state == State.DRAGGING:
		drag_ghost.position = get_viewport().get_mouse_position() - drag_ghost.size * 0.5


func _input(event: InputEvent) -> void:
	if state != State.DRAGGING:
		return
	var mouse_event: InputEventMouseButton = event as InputEventMouseButton
	if mouse_event == null or mouse_event.button_index != MOUSE_BUTTON_LEFT:
		return
	if not mouse_event.pressed:
		var moved: float = mouse_event.position.distance_to(_drag_start_position)
		if moved < sticky_drag_threshold and not _is_sticky_drag:
			_is_sticky_drag = true
			return
		get_viewport().set_input_as_handled()
		_finish_drag()
	elif _is_sticky_drag:
		get_viewport().set_input_as_handled()
		_finish_drag()


func _unhandled_input(event: InputEvent) -> void:
	var key_event: InputEventKey = event as InputEventKey
	if key_event and key_event.pressed and not key_event.echo and key_event.keycode == KEY_TAB:
		if order != null and not hud.is_modal_open():
			get_viewport().set_input_as_handled()
			_set_order_open(not _order_open)
		return
	if not event.is_action_pressed("cancel") or hud.is_modal_open():
		return
	get_viewport().set_input_as_handled()
	match state:
		State.DRAGGING:
			_cancel_drag()
		State.ZOOMED:
			_close_zoom()
		State.IDLE:
			_exit_to_street()


# ---------------------------------------------------------------- client flow

func _load_client() -> void:
	order = GameState.take_next_client()
	motor.show_order(order)
	($Shadows/ClientShadow as Sprite2D).visible = order != null
	if order == null:
		client_sprite.visible = false
		_show_order_panel(false)
		bubble.visible = false
		return
	client_sprite.visible = true
	client_sprite.texture = order.profile.texture_idle
	client_sprite.modulate.a = 0.0
	var base_x: float = client_sprite.position.x
	client_sprite.position.x = base_x
	var tween: Tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(client_sprite, "position:x", base_x, 0.45)
	tween.tween_property(client_sprite, "modulate:a", 1.0, 0.3)
	AudioManager.play_sfx(&"bell", 0.0)
	bubble.visible = true
	Typewriter.play(bubble_label, order.request_text)
	_show_order_panel(true)
	_refresh_order_panel()


func _on_queue_changed(_count: int) -> void:
	if order == null and state == State.IDLE and GameState.get_waiting_count() > 0:
		_load_client()


func _refresh_order_panel() -> void:
	if order == null:
		return
	client_name_label.text = order.profile.client_name
	for child: Node in order_lines.get_children():
		child.queue_free()
	for slot: int in order.target_tiers.keys():
		var row: OrderRow = ORDER_ROW_SCENE.instantiate() as OrderRow
		order_lines.add_child(row)
		row.setup(order, slot)
	budget_label.text = "Budget: %s" % Money.format(order.budget)
	estimate_label.text = "Estimasi bayar: %s  |  Modal part: %s" % [Money.format(order.get_payment()), Money.format(order.get_parts_cost())]
	progress_bar.value = order.get_progress() * 100.0
	deliver_button.disabled = order.twist_pending
	deliver_button.text = "SERAHKAN"


# ---------------------------------------------------------------- order panel slide

## Panel tampil/hilang total (ada/tidak ada klien). Klien baru selalu membuka panel.
func _show_order_panel(shown: bool) -> void:
	order_panel.visible = shown
	if shown:
		_set_order_open(true)
	else:
		open_order_button.visible = false


## Slide panel keluar layar ke kanan (tutup) atau masuk lagi (buka). Tab / tombol < > untuk toggle.
func _set_order_open(open: bool) -> void:
	_order_open = open
	if _order_tween and _order_tween.is_running():
		_order_tween.kill()
	open_order_button.visible = not open and order_panel.visible
	var width: float = maxf(order_panel.size.x, order_panel.get_combined_minimum_size().x)
	var target_right: float = -order_panel_margin if open else width + 20.0
	_order_tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_order_tween.tween_method(_place_order_panel, order_panel.offset_right, target_right, 0.3)
	AudioManager.play_sfx(&"click")


## Panel di-anchor ke kanan layar: geser offset kanan & kiri bersamaan supaya lebar tetap.
func _place_order_panel(offset_right_value: float) -> void:
	var width: float = maxf(order_panel.size.x, order_panel.get_combined_minimum_size().x)
	order_panel.offset_right = offset_right_value
	order_panel.offset_left = offset_right_value - width


# ---------------------------------------------------------------- zoom & tray

func _on_slot_clicked(slot: int) -> void:
	if order == null or not (state == State.IDLE or state == State.ZOOMED):
		return
	if not order.is_slot_ordered(slot):
		hud.show_toast("Klien nggak minta ganti %s. Fokus ke bagian bertanda *" % PartData.slot_to_name(slot), &"warning")
		AudioManager.play_sfx(&"install_fail")
		return
	if selected_slot >= 0:
		motor.highlight_slot(selected_slot, false)
	selected_slot = slot
	state = State.ZOOMED
	AudioManager.play_sfx(&"wrench")
	_move_camera(motor.get_slot_position(slot) + Vector2(0, -60), zoom_level)
	_refresh_tray()
	tray_popup.show_popup()
	motor.highlight_slot(slot, true)


func _close_zoom() -> void:
	if selected_slot >= 0:
		motor.highlight_slot(selected_slot, false)
	selected_slot = -1
	state = State.IDLE
	tray_popup.hide_popup()
	_move_camera(_default_camera_position, 1.0)


func _move_camera(target_position: Vector2, target_zoom: float) -> void:
	if _camera_tween and _camera_tween.is_running():
		_camera_tween.kill()
	_camera_tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_camera_tween.tween_property(camera, "position", target_position, zoom_duration)
	_camera_tween.tween_property(camera, "zoom", Vector2.ONE * target_zoom, zoom_duration)


func _refresh_tray() -> void:
	if selected_slot < 0 or order == null:
		return
	var parts: Array[PartData] = GameState.CATALOG.get_parts_for_slot(selected_slot)
	var target_tier: int = order.target_tiers.get(selected_slot, 0)
	tray_title.text = "TRAY PART: %s   |   Pesanan: Tier %d" % [PartData.slot_to_name(selected_slot).to_upper(), target_tier]
	for i: int in range(tray_cards.size()):
		var card: PartCard = tray_cards[i] as PartCard
		if i < parts.size():
			card.setup(parts[i], GameState.get_stock(parts[i].part_id))
			card.set_selected(parts[i].tier == target_tier)
		else:
			card.setup(null, 0)


# ---------------------------------------------------------------- drag & drop

func _on_card_drag_requested(card: PartCard) -> void:
	if state != State.ZOOMED:
		return
	if card.stock <= 0:
		AudioManager.play_sfx(&"install_fail")
		hud.show_toast("Stok %s habis! Beli dulu di Toko Sparepart Jaya." % card.part.part_id, &"error")
		return
	dragging_card = card
	drag_ghost.texture = card.part.get_icon()
	drag_ghost.visible = true
	drag_ghost.modulate = Color(1, 1, 1, 0.85)
	_drag_start_position = get_viewport().get_mouse_position()
	_is_sticky_drag = false
	drag_ghost.position = _drag_start_position - drag_ghost.size * 0.5
	state = State.DRAGGING
	AudioManager.play_sfx(&"click")


func _finish_drag() -> void:
	var part: PartData = dragging_card.part
	var world_point: Vector2 = get_global_mouse_position()
	if part.slot == selected_slot and motor.is_point_on_slot(selected_slot, world_point):
		drag_ghost.visible = false
		state = State.ZOOMED
		_install_part(part)
	else:
		_cancel_drag()


func _cancel_drag() -> void:
	state = State.ZOOMED
	AudioManager.play_sfx(&"install_fail")
	var target: Vector2 = dragging_card.global_position + dragging_card.size * 0.5 - drag_ghost.size * 0.5
	var tween: Tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(drag_ghost, "position", target, 0.25)
	tween.parallel().tween_property(drag_ghost, "modulate:a", 0.0, 0.25)
	tween.tween_callback(func() -> void: drag_ghost.visible = false)


func _install_part(part: PartData) -> void:
	if order.current_parts[part.slot] == part:
		hud.show_toast("Part itu sudah terpasang!", &"mini")
		AudioManager.play_sfx(&"install_fail")
		return
	if not GameState.remove_stock(part.part_id):
		return
	var returned: PartData = order.install_part(part)
	if returned != null:
		GameState.add_stock(returned.part_id)
	motor.set_part(part.slot, part)
	motor.bounce(part.slot)
	_play_install_fx(motor.get_slot_position(part.slot))
	_refresh_order_panel()
	_refresh_tray()
	if order.get_progress() >= 1.0 and not order.twist_checked:
		if order.roll_plot_twist(GameState.get_day_config().plot_twist_chance, GameState.rng):
			_refresh_order_panel()
			await get_tree().create_timer(twist_delay).timeout
			_show_twist()
		else:
			hud.show_toast("Pengerjaan 100%! Klik SERAHKAN MOTOR.", &"success")


func _play_install_fx(world_position: Vector2) -> void:
	AudioManager.play_sfx(&"wrench")
	AudioManager.play_sfx(&"install")
	sparks.global_position = world_position
	sparks.restart()
	_play_smoke(world_position)
	player_sprite.play(&"wrench")
	get_tree().create_timer(install_anim_duration).timeout.connect(func() -> void:
		if state != State.TWIST:
			player_sprite.play(&"idle"))


## Animasi asap + obeng berhamburan saat ganti sparepart (aset "Efek Asap Obeng").
func _play_smoke(world_position: Vector2) -> void:
	smoke.global_position = world_position
	smoke.visible = true
	smoke.modulate.a = 1.0
	var tween: Tween = create_tween().set_parallel(true)
	smoke_cloud.scale = Vector2.ONE * 0.2
	smoke_cloud.rotation = 0.0
	tween.tween_property(smoke_cloud, "scale", Vector2.ONE * 0.9, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(smoke_cloud, "rotation", deg_to_rad(8.0), 0.6)
	for child: Node in smoke.get_children():
		if child == smoke_cloud:
			continue
		var screwdriver: Sprite2D = child as Sprite2D
		screwdriver.position = Vector2.ZERO
		screwdriver.scale = Vector2.ONE * 0.3
		screwdriver.rotation = GameState.rng.randf_range(-0.6, 0.6)
		tween.tween_property(screwdriver, "scale", Vector2.ONE * 0.9, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween.tween_property(screwdriver, "rotation", screwdriver.rotation + GameState.rng.randf_range(-1.2, 1.2), 0.6).set_trans(Tween.TRANS_SINE)
		tween.tween_property(screwdriver, "position:y", -30.0, 0.6).set_trans(Tween.TRANS_SINE)
	tween.chain().tween_property(smoke, "modulate:a", 0.0, 0.3)
	tween.chain().tween_callback(func() -> void: smoke.visible = false)


# ---------------------------------------------------------------- plot twist

func _show_twist() -> void:
	if order == null or not order.twist_pending:
		return
	if state == State.ZOOMED or state == State.DRAGGING:
		drag_ghost.visible = false
		_close_zoom()
	state = State.TWIST
	AudioManager.play_sfx(&"plot_twist")
	client_sprite.texture = order.profile.texture_panic
	player_sprite.play(&"scratch")
	twist_portrait.texture = _make_bust(order.profile.texture_panic, 0.6)
	Typewriter.play(twist_dialog, order.twist_text)
	var slot_name: String = PartData.slot_to_name(order.twist_slot)
	var affordable: PartData = GameState.CATALOG.get_part_by_slot_tier(order.twist_slot, order.get_affordable_twist_tier())
	var current_cost: int = order.get_parts_cost()
	%AcceptDesc.text = "Ganti %s ke T%d %s. Untung, kepuasan turun." % [slot_name, affordable.tier, affordable.display_name]
	%AbsorbDesc.text = "Tetap pasang. Modal %s, kamu rugi. Kepuasan naik!" % Money.format(current_cost)
	%RejectDesc.text = "Gak bisa Bos! Klien bayar pas modal. Kepuasan anjlok."
	_show_twist_stats()
	twist_overlay.visible = true
	twist_popup.show_popup()
	_refresh_order_panel()


## Ringkasan dampak tiap pilihan (uang, kepuasan, risiko) menggantikan teks panjang.
func _show_twist_stats() -> void:
	var descs: Dictionary = {
		ClientOrder.TwistChoice.ACCEPT: %AcceptDesc,
		ClientOrder.TwistChoice.ABSORB_LOSS: %AbsorbDesc,
		ClientOrder.TwistChoice.REJECT: %RejectDesc,
	}
	for choice: int in descs.keys():
		var desc: Label = descs[choice]
		desc.visible = false
		if not _twist_stats.has(choice):
			var stats: TwistStats = TWIST_STATS_SCENE.instantiate() as TwistStats
			desc.get_parent().add_child(stats)
			_twist_stats[choice] = stats
		(_twist_stats[choice] as TwistStats).setup(order.preview_twist_choice(choice))


func _on_twist_choice(choice: ClientOrder.TwistChoice) -> void:
	if state != State.TWIST:
		return
	if not await hud.confirm("Yakin pilih opsi ini? Keputusan tidak bisa diubah.", "PILIH"):
		return
	if state != State.TWIST:
		return
	var slot: int = order.twist_slot
	var removed: PartData = order.apply_twist_choice(choice)
	if removed != null:
		GameState.add_stock(removed.part_id)
	motor.set_part(slot, order.current_parts[slot])
	motor.show_order(order)
	twist_popup.hide_popup()
	await twist_popup.hidden
	twist_overlay.visible = false
	state = State.IDLE
	client_sprite.texture = order.profile.texture_idle
	player_sprite.play(&"idle")
	match choice:
		ClientOrder.TwistChoice.ACCEPT:
			hud.show_toast("Pasang ulang %s Tier %d sesuai budget baru." % [PartData.slot_to_name(slot), order.target_tiers[slot]], &"info")
		ClientOrder.TwistChoice.ABSORB_LOSS:
			hud.show_toast("Demi reputasi! Serahkan motornya.", &"success")
		ClientOrder.TwistChoice.REJECT:
			hud.show_toast("Klien manyun... Serahkan motornya.", &"warning")
	_refresh_order_panel()


# ---------------------------------------------------------------- delivery

func _on_deliver_pressed() -> void:
	if order == null or order.twist_pending or not (state == State.IDLE or state == State.ZOOMED):
		return
	var unfinished: String = "" if order.get_progress() >= 1.0 else "\nPesanan BELUM beres, klien bisa kecewa!"
	if not await hud.confirm("Serahkan motor ke %s sekarang?%s" % [order.profile.client_name, unfinished], "SERAHKAN"):
		return
	if order == null or state == State.RESULT:
		return
	if state == State.ZOOMED:
		_close_zoom()
	state = State.RESULT
	var profile: ClientProfile = order.profile
	var result: Dictionary = GameState.complete_active_order()
	var satisfaction: float = result.satisfaction
	var line: String
	if satisfaction >= 75.0:
		client_sprite.texture = profile.texture_happy
		line = profile.pick_line(profile.happy_lines, GameState.rng)
		AudioManager.play_sfx(&"happy")
	elif satisfaction <= 45.0:
		client_sprite.texture = profile.texture_angry
		line = profile.pick_line(profile.angry_lines, GameState.rng)
		AudioManager.play_sfx(&"angry")
	else:
		client_sprite.texture = profile.texture_idle
		line = profile.pick_line(profile.neutral_lines, GameState.rng)
	AudioManager.play_sfx(&"motor_rev")
	AudioManager.play_sfx(&"coin")
	var piggy_sprite: Sprite2D = piggy_bank.get_node("Sprite") as Sprite2D
	if int(result.profit) < 0:
		Juice.shake(piggy_sprite)
		hud.shake_piggy()
	else:
		Juice.bounce(piggy_sprite)
	bubble_label.text = line
	%ResultTitle.text = "SERAH TERIMA!" if not result.caught else "KETAHUAN NIPU!"
	Typewriter.play(%ReactionLabel, line)
	%ResultPortrait.texture = _make_bust(client_sprite.texture)
	bubble.visible = false
	# Ringkas: cukup uang masuk + kepuasan, sisanya bikin bingung.
	%PaymentLabel.text = "+%s" % Money.format(result.payment)
	%SatisfactionLabel.text = "Kepuasan %d%%" % roundi(satisfaction)
	%ProfitLabel.visible = false
	%CaughtLabel.visible = false
	order = null
	_show_order_panel(false)
	result_overlay.visible = true
	result_popup.show_popup()


## Potret sampai dada saja: ambil bagian atas sprite karakter (kepala + dada).
func _make_bust(texture: Texture2D, ratio: float = 0.42) -> Texture2D:
	if texture == null:
		return null
	var bust: AtlasTexture = AtlasTexture.new()
	bust.atlas = texture
	bust.region = Rect2(0.0, 0.0, texture.get_width(), texture.get_height() * ratio)
	return bust


func _on_result_continue() -> void:
	result_popup.hide_popup()
	await result_popup.hidden
	result_overlay.visible = false
	state = State.IDLE
	if GameState.check_bankrupt():
		return
	var tween: Tween = create_tween()
	tween.tween_property(client_sprite, "modulate:a", 0.0, 0.3)
	await tween.finished
	_load_client()


# ---------------------------------------------------------------- misc

func _on_piggy_hover(hovered: bool) -> void:
	HoverOutline.set_hovered(piggy_bank.get_node("Sprite") as Sprite2D, hovered and state == State.IDLE)


func _on_piggy_input(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	var mouse_event: InputEventMouseButton = event as InputEventMouseButton
	if mouse_event and mouse_event.pressed and mouse_event.button_index == MOUSE_BUTTON_LEFT and state == State.IDLE:
		hud.open_ledger()


func _exit_to_street() -> void:
	if state == State.TWIST or state == State.RESULT or state == State.DRAGGING:
		return
	GameState.street_spawn_x = 1900.0
	AudioManager.play_sfx(&"door")
	SceneTransitionManager.change_scene(GameState.SCENE_STREET)
