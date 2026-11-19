extends Node
## State sesi permainan: uang, hari, jam, antrean, stok, toko, menang/kalah.

signal cash_changed(cash: int)
signal satisfaction_changed(average: float)
signal clock_changed(day: int, minutes: int)
signal restock_countdown_changed(seconds_left: float)
signal queue_changed(waiting_count: int)
signal inventory_changed
signal shop_restocked
signal toast_requested(text: String, kind: StringName)

const CONFIG: GameConfig = preload("res://resources/configurations/game_config.tres")
const CATALOG: PartCatalog = preload("res://resources/parts/part_catalog.tres")
const SCENE_STREET: String = "res://scenes/levels/street_hub.tscn"
const SCENE_DAY_SUMMARY: String = "res://scenes/main/day_summary.tscn"
const SCENE_GAME_OVER: String = "res://scenes/main/game_over.tscn"
const SCENE_MAIN_MENU: String = "res://scenes/main/main_menu.tscn"
const SCENE_INTRO: String = "res://scenes/main/intro_cutscene.tscn"
const SCENE_WORKSHOP: String = "res://scenes/levels/workshop.tscn"

var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var cash: int = 0
var day: int = 1
var day_time: float = 0.0
var is_clock_running: bool = false
var is_day_over: bool = false
var is_session_active: bool = false
var inventory: Dictionary = {} ## StringName part_id -> int
var queue: Array[ClientOrder] = []
var active_order: ClientOrder
var satisfaction_history: Array[float] = []
var clients_served_total: int = 0
var clients_served_today: int = 0
var clients_spawned_today: int = 0
var income_today: int = 0
var expense_today: int = 0
var deceptions_caught_total: int = 0
var shop_offers: Array[Dictionary] = [] ## {part: PartData, stock: int}
var street_spawn_x: float = 1900.0
var final_is_win: bool = false
var final_reason: String = ""
## Tutorial muncul tiap kali mulai main (game baru), bisa di-skip.
var tutorial_pending: bool = false

var _spawn_timer: float = 0.0
var _second_restock_done: bool = false
var _day_snapshots: Dictionary = {} ## day -> snapshot awal hari


func _process(delta: float) -> void:
	if not is_clock_running or is_day_over:
		return
	day_time += delta
	if not _second_restock_done and get_clock_minutes() >= CONFIG.second_restock_minutes:
		_second_restock_done = true
		restock_shop(true)
	_spawn_timer -= delta
	if _spawn_timer <= 0.0:
		_try_spawn_client()
		_reset_spawn_timer()
	clock_changed.emit(day, get_clock_minutes())
	restock_countdown_changed.emit(get_restock_seconds_left())
	if day_time >= CONFIG.day_length_sec:
		_end_day()


# ---------------------------------------------------------------- session

func new_game() -> void:
	rng.randomize()
	cash = CONFIG.start_cash
	day = 1
	inventory = CONFIG.starter_inventory.duplicate()
	satisfaction_history.clear()
	_day_snapshots.clear()
	clients_served_total = 0
	deceptions_caught_total = 0
	final_is_win = false
	final_reason = ""
	is_session_active = true
	tutorial_pending = true
	street_spawn_x = 1900.0
	_take_snapshot()
	start_day()


## Kalah: mundur CONFIG.rollback_days hari ke belakang (min. hari 1), state hari itu dipulihkan.
func restart_day() -> void:
	var target_day: int = maxi(1, day - CONFIG.rollback_days)
	if not _day_snapshots.has(target_day):
		new_game()
		return
	var snapshot: Dictionary = _day_snapshots[target_day]
	day = target_day
	cash = snapshot.cash
	inventory = (snapshot.inventory as Dictionary).duplicate()
	satisfaction_history = (snapshot.history as Array[float]).duplicate()
	clients_served_total = snapshot.served_total
	deceptions_caught_total = snapshot.caught_total
	for key: int in _day_snapshots.keys():
		if key > target_day:
			_day_snapshots.erase(key)
	is_session_active = true
	street_spawn_x = 1900.0
	start_day()


func start_day() -> void:
	day_time = 0.0
	is_day_over = false
	is_clock_running = false
	queue.clear()
	active_order = null
	clients_served_today = 0
	clients_spawned_today = 0
	income_today = 0
	expense_today = 0
	_second_restock_done = false
	restock_shop(false)
	for i: int in range(CONFIG.first_clients_count):
		_try_spawn_client()
	_reset_spawn_timer()
	_emit_all()


## Dipanggil Day Summary saat tombol lanjut ditekan.
func advance_after_summary() -> void:
	if check_bankrupt():
		return
	if clients_spawned_today == 0 and cash < CATALOG.get_cheapest_cost() * 3:
		trigger_game_over(false, "Kepuasan anjlok, tak ada lagi pelanggan yang datang. Bengkel sepi, celengan kosong.")
		return
	if day >= CONFIG.total_days:
		var average: float = get_average_satisfaction()
		if clients_served_total >= CONFIG.win_min_clients and average >= CONFIG.win_min_satisfaction:
			trigger_game_over(true, "Kamu bertahan 5 hari, melayani %d klien dengan kepuasan %d%%. Lisensi Distrik Modifikasi Balap terbuka!" % [clients_served_total, roundi(average)])
		else:
			trigger_game_over(false, "Target tidak tercapai: butuh min. %d klien & kepuasan %d%% (kamu: %d klien, %d%%)." % [CONFIG.win_min_clients, roundi(CONFIG.win_min_satisfaction), clients_served_total, roundi(average)])
		return
	day += 1
	_take_snapshot()
	start_day()
	street_spawn_x = 1900.0
	SceneTransitionManager.change_scene(SCENE_STREET)


func trigger_game_over(is_win: bool, reason: String) -> void:
	final_is_win = is_win
	final_reason = reason
	is_clock_running = false
	is_session_active = false
	SceneTransitionManager.change_scene(SCENE_GAME_OVER)


func set_clock_running(running: bool) -> void:
	is_clock_running = running and is_session_active and not is_day_over


# ---------------------------------------------------------------- clock

func get_clock_minutes() -> int:
	var span: float = float(CONFIG.day_end_minutes - CONFIG.day_start_minutes)
	return CONFIG.day_start_minutes + int(clampf(day_time / CONFIG.day_length_sec, 0.0, 1.0) * span)


func get_restock_seconds_left() -> float:
	var restock_time: float = _minutes_to_seconds(CONFIG.second_restock_minutes)
	if day_time < restock_time:
		return restock_time - day_time
	return maxf(CONFIG.day_length_sec - day_time, 0.0)


func format_clock(minutes: int) -> String:
	return "%02d:%02d" % [floori(minutes / 60.0), minutes % 60]


func _minutes_to_seconds(minutes: int) -> float:
	var span: float = float(CONFIG.day_end_minutes - CONFIG.day_start_minutes)
	return float(minutes - CONFIG.day_start_minutes) / span * CONFIG.day_length_sec


func _end_day() -> void:
	is_day_over = true
	is_clock_running = false
	queue.clear()
	active_order = null
	queue_changed.emit(0)
	AudioManager.play_sfx(&"restock")
	SceneTransitionManager.change_scene(SCENE_DAY_SUMMARY)


# ---------------------------------------------------------------- clients

func get_day_config() -> DayConfig:
	return CONFIG.get_day_config(day)


func get_waiting_count() -> int:
	return queue.size()


func take_next_client() -> ClientOrder:
	if active_order != null:
		return active_order
	if queue.is_empty():
		return null
	active_order = queue.pop_front()
	queue_changed.emit(queue.size())
	return active_order


func _try_spawn_client() -> void:
	var occupied: int = queue.size() + (1 if active_order != null else 0)
	if occupied >= CONFIG.queue_capacity:
		return
	if clients_spawned_today >= get_max_clients_today():
		return
	var profile: ClientProfile = _pick_profile()
	var order: ClientOrder = ClientOrder.create(profile, get_day_config(), CATALOG, rng)
	queue.append(order)
	clients_spawned_today += 1
	queue_changed.emit(queue.size())
	if is_clock_running:
		toast_requested.emit("%s datang dan ikut antre!" % profile.client_name, &"info")


## Kepuasan rendah = pelanggan makin sedikit (bisa nol), jadi pemasukan seret.
func get_max_clients_today() -> int:
	var ratio: float = clampf((get_average_satisfaction() - CONFIG.lose_satisfaction) / (100.0 - CONFIG.lose_satisfaction), 0.0, 1.0)
	return ceili(get_day_config().max_clients * ratio)


func _pick_profile() -> ClientProfile:
	var busy: Array[StringName] = []
	for order: ClientOrder in queue:
		busy.append(order.profile.client_id)
	if active_order != null:
		busy.append(active_order.profile.client_id)
	var free: Array[ClientProfile] = []
	for profile: ClientProfile in CONFIG.clients:
		if not busy.has(profile.client_id):
			free.append(profile)
	var pool: Array[ClientProfile] = free if not free.is_empty() else CONFIG.clients
	return pool[rng.randi_range(0, pool.size() - 1)]


func _reset_spawn_timer() -> void:
	_spawn_timer = rng.randf_range(CONFIG.spawn_interval_min, CONFIG.spawn_interval_max)


## Menyelesaikan pesanan aktif: bayar, catat kepuasan. Mengembalikan ringkasan hasil.
func complete_active_order() -> Dictionary:
	var order: ClientOrder = active_order
	if order == null:
		return {}
	var evaluation: Dictionary = order.evaluate(rng)
	var payment: int = order.get_payment()
	var satisfaction: float = evaluation.satisfaction
	cash += payment
	income_today += payment
	if payment > 0:
		toast_requested.emit("+%s diterima!" % Money.format(payment), &"money")
	satisfaction_history.append(satisfaction)
	clients_served_total += 1
	clients_served_today += 1
	if evaluation.caught:
		deceptions_caught_total += 1
	active_order = null
	cash_changed.emit(cash)
	satisfaction_changed.emit(get_average_satisfaction())
	queue_changed.emit(queue.size())
	return {
		"order": order,
		"payment": payment,
		"satisfaction": satisfaction,
		"caught": evaluation.caught,
		"profit": payment - order.get_parts_cost(),
	}


func get_average_satisfaction() -> float:
	if satisfaction_history.is_empty():
		return 100.0
	var total: float = 0.0
	for value: float in satisfaction_history:
		total += value
	return total / satisfaction_history.size()


func is_reputation_bankrupt() -> bool:
	return satisfaction_history.size() >= CONFIG.lose_check_min_clients and get_average_satisfaction() <= CONFIG.lose_satisfaction


## Kalah kalau uang habis. Mengembalikan true jika game over dipicu.
func check_bankrupt() -> bool:
	if not is_bankrupt():
		return false
	trigger_game_over(false, "BANGKRUT! Uang celengan habis dan tak ada stok part untuk dikerjakan.")
	return true


func is_bankrupt() -> bool:
	return cash < CATALOG.get_cheapest_cost() and get_total_stock() == 0


# ---------------------------------------------------------------- inventory & money

func get_stock(part_id: StringName) -> int:
	return int(inventory.get(part_id, 0))


func get_total_stock() -> int:
	var total: int = 0
	for value: int in inventory.values():
		total += value
	return total


func add_stock(part_id: StringName, amount: int = 1) -> void:
	inventory[part_id] = get_stock(part_id) + amount
	inventory_changed.emit()


func remove_stock(part_id: StringName, amount: int = 1) -> bool:
	if get_stock(part_id) < amount:
		return false
	inventory[part_id] = get_stock(part_id) - amount
	inventory_changed.emit()
	return true


## items: Array of {offer_index: int, quantity: int}. Mengembalikan true jika berhasil.
func purchase(items: Array[Dictionary]) -> bool:
	var total: int = 0
	for item: Dictionary in items:
		var offer: Dictionary = shop_offers[item.offer_index]
		if int(offer.stock) < int(item.quantity):
			toast_requested.emit("Stok toko tidak cukup!", &"error")
			return false
		total += (offer.part as PartData).cost_price * int(item.quantity)
	if total <= 0:
		return false
	if total > cash:
		toast_requested.emit("Duit celengan kurang! Butuh %s" % Money.format(total), &"error")
		return false
	cash -= total
	expense_today += total
	for item: Dictionary in items:
		var offer: Dictionary = shop_offers[item.offer_index]
		offer.stock = int(offer.stock) - int(item.quantity)
		add_stock((offer.part as PartData).part_id, int(item.quantity))
	cash_changed.emit(cash)
	return true


# ---------------------------------------------------------------- shop

func restock_shop(announce: bool) -> void:
	shop_offers.clear()
	var config: DayConfig = get_day_config()
	var slots: Array = PartData.SLOT_NAMES.keys()
	for i: int in range(CONFIG.shop_offer_count):
		var slot: int = slots[i] if i < slots.size() else slots[rng.randi_range(0, slots.size() - 1)]
		var part: PartData = CATALOG.get_part_by_slot_tier(slot, config.pick_tier(rng, 1))
		var merged: bool = false
		for offer: Dictionary in shop_offers:
			if offer.part == part:
				offer.stock = int(offer.stock) + 1
				merged = true
				break
		if not merged:
			shop_offers.append({"part": part, "stock": rng.randi_range(1, 3)})
	shop_offers.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		var pa: PartData = a.part
		var pb: PartData = b.part
		return pa.slot < pb.slot or (pa.slot == pb.slot and pa.tier < pb.tier))
	shop_restocked.emit()
	if announce:
		AudioManager.play_sfx(&"restock")
		toast_requested.emit("Ding-dong! Toko Sparepart Jaya restock barang baru!", &"success")


# ---------------------------------------------------------------- helpers

func format_money(amount: int) -> String:
	return Money.format(amount)


func _take_snapshot() -> void:
	_day_snapshots[day] = {
		"cash": cash,
		"inventory": inventory.duplicate(),
		"history": satisfaction_history.duplicate(),
		"served_total": clients_served_total,
		"caught_total": deceptions_caught_total,
	}


func _emit_all() -> void:
	cash_changed.emit(cash)
	satisfaction_changed.emit(get_average_satisfaction())
	clock_changed.emit(day, get_clock_minutes())
	restock_countdown_changed.emit(get_restock_seconds_left())
	queue_changed.emit(queue.size())
	inventory_changed.emit()
