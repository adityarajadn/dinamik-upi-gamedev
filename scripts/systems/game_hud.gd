class_name GameHUD
extends CanvasLayer
## HUD bersama (GDD 5.2): saldo, kepuasan, jam & restock, antrean, ledger, pause.

signal exit_requested

@export var show_exit_button: bool = false
@export var esc_pauses: bool = true
@export var exit_text: String = "EXIT - ESC"
@export var toast_duration: float = 2.4

const STOCK_CELL_SCENE: PackedScene = preload("res://scenes/ui/components/stock_cell.tscn")
const COLOR_GOOD: Color = Color(0.15, 0.55, 0.25, 1)
const COLOR_MID: Color = Color(0.85, 0.55, 0, 1)
const COLOR_BAD: Color = Color(0.8, 0.15, 0.2, 1)
## Jenis toast -> theme type variation (lihat game_theme.tres).
const TOAST_X: float = 20.0
const TOAST_STYLES: Dictionary = {
	&"info": &"ToastPanel",
	&"success": &"ToastSuccess",
	&"warning": &"ToastWarning",
	&"error": &"ToastError",
	&"money": &"ToastMoney",
	&"mini": &"ToastMini",
}

var _toast_tween: Tween
var _ledger_page: int = 0
var _stock_cells: Dictionary = {} ## part_id -> StockCell
var _last_cash: int = -1

@onready var cash_label: Label = %CashLabel
@onready var piggy_icon: TextureRect = %PiggyIcon
@onready var satisfaction_label: Label = %SatLabel
@onready var satisfaction_bar: ProgressBar = %SatBar
@onready var day_label: Label = %DayLabel
@onready var restock_label: Label = %RestockLabel
@onready var queue_title: Label = %QueueTitle
@onready var helmets: Array[Node] = %Helmets.get_children()
@onready var exit_button: Button = %ExitButton
@onready var pause_button: Button = %PauseButton
@onready var toast_panel: PanelContainer = %Toast
@onready var toast_label: Label = %ToastLabel
@onready var ledger_panel: PanelContainer = %LedgerPanel
@onready var ledger_dim: ColorRect = %LedgerDim
@onready var ledger_spreads: Array[Node] = %Spreads.get_children()
@onready var prev_page_button: Button = %PrevPage
@onready var next_page_button: Button = %NextPage
@onready var page_label: Label = %PageLabel
@onready var ledger_popup: PopupAnimator = %LedgerPopup
@onready var pause_overlay: Control = %PauseOverlay
@onready var confirm_dialog: ConfirmDialog = %ConfirmDialog
@onready var tutorial: Control = %TutorialOverlay


func _ready() -> void:
	exit_button.visible = show_exit_button
	exit_button.text = exit_text
	exit_button.pressed.connect(func() -> void: exit_requested.emit())
	pause_button.pressed.connect(toggle_pause)
	%ResumeButton.pressed.connect(toggle_pause)
	%MenuButton.pressed.connect(_on_menu_pressed)
	%PauseSettingsButton.pressed.connect(_set_pause_settings.bind(true))
	%PauseSettingsClose.pressed.connect(_set_pause_settings.bind(false))
	%PauseMusicSlider.value = AudioManager.music_volume
	%PauseSfxSlider.value = AudioManager.sfx_volume
	%PauseMusicSlider.value_changed.connect(AudioManager.set_music_volume)
	%PauseSfxSlider.value_changed.connect(func(value: float) -> void:
		AudioManager.set_sfx_volume(value)
		AudioManager.play_sfx(&"click"))
	%LedgerClose.pressed.connect(close_ledger)
	OverlayUtil.pin_close_button(ledger_panel, %LedgerClose)
	OverlayUtil.pin_close_button(%PauseSettingsPanel, %PauseSettingsClose)
	ledger_dim.color = OverlayUtil.DIM_COLOR
	#%LedgerButton.pressed.connect(func() -> void: close_ledger() if ledger_panel.visible else open_ledger())
	prev_page_button.pressed.connect(_turn_ledger_page.bind(-1))
	next_page_button.pressed.connect(_turn_ledger_page.bind(1))
	_build_stock_cells()
	ledger_panel.visible = false
	prev_page_button.visible = false
	next_page_button.visible = false
	page_label.visible = false
	pause_overlay.visible = false
	toast_panel.visible = false
	GameState.cash_changed.connect(_on_cash_changed)
	GameState.satisfaction_changed.connect(_on_satisfaction_changed)
	GameState.clock_changed.connect(_on_clock_changed)
	GameState.restock_countdown_changed.connect(_on_restock_changed)
	GameState.queue_changed.connect(_on_queue_changed)
	GameState.toast_requested.connect(show_toast)
	_on_cash_changed(GameState.cash)
	_on_satisfaction_changed(GameState.get_average_satisfaction())
	_on_clock_changed(GameState.day, GameState.get_clock_minutes())
	_on_restock_changed(GameState.get_restock_seconds_left())
	_on_queue_changed(GameState.get_waiting_count())


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("open_ledger"):
		if ledger_panel.visible:
			close_ledger()
		else:
			open_ledger()
		get_viewport().set_input_as_handled()
	elif confirm_dialog.visible:
		return
	elif event.is_action_pressed("pause") and (esc_pauses or get_tree().paused):
		if ledger_panel.visible and not get_tree().paused:
			close_ledger()
		else:
			toggle_pause()
		get_viewport().set_input_as_handled()


func is_modal_open() -> bool:
	return ledger_panel.visible or pause_overlay.visible or confirm_dialog.visible or tutorial.visible


## Tutorial tiap kali mulai main. Jam berhenti selama tutorial terbuka.
func show_tutorial(steps: Array = []) -> void:
	GameState.tutorial_pending = false
	GameState.set_clock_running(false)
	tutorial.start(steps)
	await tutorial.finished
	GameState.set_clock_running(true)


## Modal "Yakin?" untuk semua aksi penting supaya tidak salah pencet.
## Tetap bekerja walau HUD disembunyikan di scene (mis. Toko): elemen HUD lain disembunyikan sementara.
func confirm(message: String, confirm_text: String = "CONFIRM") -> bool:
	var hidden_nodes: Array[CanvasItem] = []
	var was_visible: bool = visible
	if not was_visible:
		for child: Node in confirm_dialog.get_parent().get_children():
			var item: CanvasItem = child as CanvasItem
			if item and item != confirm_dialog and item.visible:
				item.visible = false
				hidden_nodes.append(item)
		visible = true
	var confirmed: bool = await confirm_dialog.ask(message, confirm_text)
	if not was_visible:
		visible = false
		for item: CanvasItem in hidden_nodes:
			item.visible = true
	return confirmed


## Panel pengaturan di dalam pause: gantikan panel pause selama terbuka.
func _set_pause_settings(open: bool) -> void:
	%PauseSettingsPanel.visible = open
	%PausePanel.visible = not open
	if not open:
		%PauseSettingsButton.grab_focus()


func toggle_pause() -> void:
	if %PauseSettingsPanel.visible:
		_set_pause_settings(false)
		return
	var paused: bool = not get_tree().paused
	get_tree().paused = paused
	pause_overlay.visible = paused
	if paused:
		%ResumeButton.grab_focus()


func open_ledger() -> void:
	_refresh_ledger()
	# Buku kas hanya untuk lihat stok: langsung ke spread stok, tanpa navigasi halaman.
	_show_ledger_page(ledger_spreads.size() - 1, false)
	ledger_dim.visible = true
	ledger_popup.show_popup()
	AudioManager.play_sfx(&"coin")


func close_ledger() -> void:
	ledger_dim.visible = false
	ledger_popup.hide_popup()


func show_toast(text: String, kind: StringName = &"info") -> void:
	toast_label.text = text
	toast_panel.theme_type_variation = TOAST_STYLES.get(kind, &"ToastPanel")
	var is_mini: bool = kind == &"mini"
	var width: float = 400.0 if is_mini else 560.0
	# Hitung tinggi teks manual: Label autowrap belum punya lebar saat frame pertama.
	var text_width: float = width - 177.0 ## content margin kiri 125 + kanan 52
	var font: Font = toast_label.get_theme_font("font")
	var font_size: int = toast_label.get_theme_font_size("font_size")
	var text_height: float = font.get_multiline_string_size(text, HORIZONTAL_ALIGNMENT_CENTER, text_width, font_size).y
	var height: float = maxf(70.0 if is_mini else 112.0, text_height + 92.0)
	toast_label.custom_minimum_size = Vector2(text_width, 0.0)
	toast_label.size = Vector2(text_width, text_height)
	toast_panel.custom_minimum_size = Vector2(width, height)
	toast_panel.size = Vector2(width, height)
	# Ulangi setelah layout frame berikutnya (show_toast bisa dipanggil saat scene baru _ready).
	(func() -> void: toast_panel.size = Vector2(width, height)).call_deferred()
	if _toast_tween and _toast_tween.is_running():
		_toast_tween.kill()
	toast_panel.visible = true
	toast_panel.modulate.a = 1.0
	# Taruh toast tepat di bawah jam supaya tidak menutupi info HUD.
	var clock: Control = find_child("ClockBox", true, false) as Control
	if clock:
		toast_panel.global_position.y = clock.get_global_rect().end.y + 16.0
	var hidden_x: float = -toast_panel.size.x - 40.0
	toast_panel.position.x = hidden_x
	# Slide in dari kiri, tahan, lalu slide out lagi ke kiri.
	_toast_tween = create_tween()
	_toast_tween.tween_property(toast_panel, "position:x", TOAST_X, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_toast_tween.tween_interval(toast_duration)
	_toast_tween.tween_property(toast_panel, "position:x", hidden_x, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	_toast_tween.tween_callback(func() -> void: toast_panel.visible = false)


func _refresh_ledger() -> void:
	var net: int = GameState.income_today - GameState.expense_today
	%DayLine.text = "Day %d  -  %s" % [GameState.day, GameState.format_clock(GameState.get_clock_minutes())]
	%IncomeValue.text = Money.format(GameState.income_today)
	%ExpenseValue.text = "-" + Money.format(GameState.expense_today)
	%NetValue.text = ("" if net >= 0 else "-") + Money.format(absi(net))
	%NetValue.add_theme_color_override("font_color", COLOR_GOOD if net >= 0 else COLOR_BAD)
	%CashValue.text = Money.format(GameState.cash)
	var satisfaction: float = GameState.get_average_satisfaction()
	var sat_color: Color = COLOR_GOOD if satisfaction >= 75.0 else (COLOR_MID if satisfaction > 45.0 else COLOR_BAD)
	%SatValue.text = "%d%%" % roundi(satisfaction)
	%SatValue.add_theme_color_override("font_color", sat_color)
	%SatLedgerBar.value = satisfaction
	var fill: StyleBoxFlat = %SatLedgerBar.get_theme_stylebox("fill").duplicate() as StyleBoxFlat
	if fill:
		fill.bg_color = sat_color
		%SatLedgerBar.add_theme_stylebox_override("fill", fill)
	%ServedTodayValue.text = str(GameState.clients_served_today)
	%ServedTotalValue.text = str(GameState.clients_served_total)
	%QueueValue.text = "%d / %d" % [GameState.get_waiting_count(), GameState.CONFIG.queue_capacity]
	%CaughtValue.text = "%dx" % GameState.deceptions_caught_total
	for part: PartData in GameState.CATALOG.parts:
		if _stock_cells.has(part.part_id):
			(_stock_cells[part.part_id] as StockCell).setup(part, GameState.get_stock(part.part_id))
	%StockTotal.text = "Total stock: %d parts" % GameState.get_total_stock()


## Sel stok disusun per slot (baris) x tier (kolom): 3 slot di halaman kiri, sisanya di kanan.
func _build_stock_cells() -> void:
	var slots: Array = [PartData.Slot.BODY, PartData.Slot.ENGINE, PartData.Slot.EXHAUST, PartData.Slot.LIGHT, PartData.Slot.WHEELS]
	for i: int in range(slots.size()):
		var page: VBoxContainer = %StockLeft if i < 3 else %StockRight
		var slot_label: Label = Label.new()
		slot_label.theme_type_variation = &"DarkLabel"
		slot_label.add_theme_font_size_override("font_size", 20)
		slot_label.text = PartData.slot_to_name(slots[i]).to_upper()
		page.add_child(slot_label)
		var cells_row: HBoxContainer = HBoxContainer.new()
		cells_row.add_theme_constant_override("separation", 4)
		page.add_child(cells_row)
		for part: PartData in GameState.CATALOG.get_parts_for_slot(slots[i]):
			var cell: StockCell = STOCK_CELL_SCENE.instantiate() as StockCell
			cells_row.add_child(cell)
			_stock_cells[part.part_id] = cell
	%StockRight.move_child(%StockTotal, %StockRight.get_child_count() - 1)


func _turn_ledger_page(direction: int) -> void:
	var target: int = clampi(_ledger_page + direction, 0, ledger_spreads.size() - 1)
	if target == _ledger_page:
		return
	_show_ledger_page(target, true)


func _show_ledger_page(page: int, animate: bool) -> void:
	_ledger_page = page
	for i: int in range(ledger_spreads.size()):
		(ledger_spreads[i] as CanvasItem).visible = i == page
	page_label.text = "%d / %d" % [page + 1, ledger_spreads.size()]
	prev_page_button.disabled = page <= 0
	next_page_button.disabled = page >= ledger_spreads.size() - 1
	if animate:
		AudioManager.play_sfx(&"page_flip")
		Juice.bounce(ledger_spreads[page] as CanvasItem, 0.12)

func _on_quit_pressed() -> void:
	if await confirm("Quit the game? Today's progress won't be saved.", "KELUAR"):
		get_tree().quit()


func _on_menu_pressed() -> void:
	if not await confirm("Back to the main menu? Today's progress won't be saved.", "TO MENU"):
		return
	get_tree().paused = false
	pause_overlay.visible = false
	GameState.set_clock_running(false)
	GameState.is_session_active = false
	SceneTransitionManager.change_scene(GameState.SCENE_MAIN_MENU)


func _on_cash_changed(cash: int) -> void:
	cash_label.text = Money.format(cash)
	if _last_cash >= 0 and cash > _last_cash:
		Juice.bounce(piggy_icon)
	_last_cash = cash


## Dipanggil saat transaksi berujung rugi.
func shake_piggy() -> void:
	Juice.shake(piggy_icon)


func _on_satisfaction_changed(average: float) -> void:
	satisfaction_label.text = "%d%%" % roundi(average)
	satisfaction_bar.value = average
	var color: Color = Color(1, 0.08, 0.58).lerp(Color(0.35, 1, 0.45), clampf(average / 100.0, 0.0, 1.0))
	satisfaction_label.add_theme_color_override("font_color", color)


func _on_clock_changed(day: int, minutes: int) -> void:
	day_label.text = "DAY %d - %s" % [day, GameState.format_clock(minutes)]


func _on_restock_changed(seconds_left: float) -> void:
	var total: int = int(ceil(seconds_left))
	restock_label.text = "Shop restock: %02d:%02d" % [floori(total / 60.0), total % 60]


func _on_queue_changed(waiting_count: int) -> void:
	queue_title.text = "Queue: %d/%d" % [waiting_count, GameState.CONFIG.queue_capacity]
	for i: int in range(helmets.size()):
		var helmet: TextureRect = helmets[i] as TextureRect
		helmet.modulate = Color(1, 1, 1, 1) if i < waiting_count else Color(0.25, 0.25, 0.3, 0.6)


## Rect layar elemen HUD untuk spotlight tutorial.
func get_tutorial_rect(element: StringName) -> Rect2:
	# Cari berdasarkan nama (bukan path) supaya tetap ketemu walau node dipindah.
	var node: Control = find_child(String(element), true, false) as Control
	return node.get_global_rect() if node and node.is_visible_in_tree() else Rect2()
