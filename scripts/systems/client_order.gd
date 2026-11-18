class_name ClientOrder
extends RefCounted
## State runtime satu pesanan klien. Bukan Resource bersama, aman dimodifikasi.

enum TwistChoice { NONE, ACCEPT, ABSORB_LOSS, REJECT }

const BASE_SATISFACTION: float = 70.0
const SCORE_EXACT: float = 25.0
const SCORE_HIGHER: float = 30.0
const SCORE_LOWBALL_DETECTED: float = -35.0
const SCORE_NOT_DONE: float = -30.0
## Tetap pasang & rugi: klien cuma bayar sebagian modal part.
const ABSORB_PAY_RATIO: float = 0.8
const TWIST_MOD: Dictionary = {
	TwistChoice.NONE: 0.0,
	TwistChoice.ACCEPT: -10.0,
	TwistChoice.ABSORB_LOSS: 10.0,
	TwistChoice.REJECT: -45.0,
}

var profile: ClientProfile
var original_parts: Dictionary = {} ## slot -> PartData (kondisi awal motor)
var current_parts: Dictionary = {} ## slot -> PartData (terpasang sekarang)
var installed_by_player: Dictionary = {} ## slot -> bool
var target_tiers: Dictionary = {} ## slot -> int (hanya slot yang dipesan)
var budget: int = 0
var original_budget: int = 0
var request_text: String = ""

var twist_checked: bool = false
var twist_pending: bool = false
var twist_slot: int = -1
var twist_new_budget: int = 0
var twist_text: String = ""
var twist_choice: TwistChoice = TwistChoice.NONE

var _catalog: PartCatalog


static func create(client: ClientProfile, day_config: DayConfig, catalog: PartCatalog, rng: RandomNumberGenerator) -> ClientOrder:
	var order := ClientOrder.new()
	order.profile = client
	order._catalog = catalog
	var max_current_tier: int = 2 if day_config.day < 3 else 3
	for slot: int in PartData.SLOT_NAMES.keys():
		var tier: int = rng.randi_range(1, max_current_tier)
		var part: PartData = catalog.get_part_by_slot_tier(slot, tier)
		order.original_parts[slot] = part
		order.current_parts[slot] = part
		order.installed_by_player[slot] = false

	var slots: Array = PartData.SLOT_NAMES.keys()
	slots.shuffle()
	var slot_count: int = rng.randi_range(1, maxi(day_config.max_order_slots, 1))
	var total_sell: int = 0
	for slot: int in slots:
		if order.target_tiers.size() >= slot_count:
			break
		var current_tier: int = (order.original_parts[slot] as PartData).tier
		if current_tier >= 5:
			continue
		var target: int = day_config.pick_tier(rng, current_tier + 1)
		target = clampi(maxi(target, current_tier + 1), 1, 5)
		order.target_tiers[slot] = target
		total_sell += catalog.get_part_by_slot_tier(slot, target).selling_price

	var tolerance: float = rng.randf_range(0.0, client.budget_tolerance_max)
	order.budget = _round_money(int(total_sell * (1.0 + tolerance)))
	order.original_budget = order.budget
	order.request_text = client.pick_line(client.request_lines, rng).format({
		"parts": order.describe_targets(),
		"budget": Money.format(order.budget),
	})
	return order


static func _round_money(amount: int) -> int:
	return int(round(amount / 5000.0)) * 5000


func describe_targets() -> String:
	var pieces: PackedStringArray = PackedStringArray()
	for slot: int in target_tiers.keys():
		var part: PartData = get_target_part(slot)
		pieces.append(part.display_name)
	return ", ".join(pieces)


func get_target_part(slot: int) -> PartData:
	return _catalog.get_part_by_slot_tier(slot, target_tiers[slot])


func is_slot_ordered(slot: int) -> bool:
	return target_tiers.has(slot)


func get_progress() -> float:
	if target_tiers.is_empty():
		return 1.0
	var done: int = 0
	for slot: int in target_tiers.keys():
		if installed_by_player[slot]:
			done += 1
	return float(done) / float(target_tiers.size())


## Pasang part ke slot. Mengembalikan part yang dilepas jika itu part
## pemasangan pemain (dikembalikan ke stok), atau null bila part asli dibuang.
func install_part(part: PartData) -> PartData:
	var returned: PartData = null
	if installed_by_player[part.slot]:
		returned = current_parts[part.slot]
	current_parts[part.slot] = part
	installed_by_player[part.slot] = true
	return returned


## Lepas part pemain dan kembalikan motor ke part asli (dipakai saat revisi).
func revert_slot(slot: int) -> PartData:
	if not installed_by_player[slot]:
		return null
	var removed: PartData = current_parts[slot]
	current_parts[slot] = original_parts[slot]
	installed_by_player[slot] = false
	return removed


func get_bill() -> int:
	var bill: int = 0
	for slot: int in target_tiers.keys():
		if not installed_by_player[slot]:
			continue
		var installed: PartData = current_parts[slot]
		var target: PartData = get_target_part(slot)
		if installed.tier == 1 and target.tier > 1:
			bill += installed.selling_price
		else:
			bill += target.selling_price
	return bill


func get_payment() -> int:
	return mini(get_bill(), budget)


## Biaya modal part yang dipasang pemain untuk pesanan ini.
func get_parts_cost() -> int:
	var cost: int = 0
	for slot: int in target_tiers.keys():
		if installed_by_player[slot]:
			cost += (current_parts[slot] as PartData).cost_price
	return cost


## Menghitung kepuasan akhir. Mengembalikan {satisfaction, caught}.
func evaluate(rng: RandomNumberGenerator) -> Dictionary:
	var total: float = 0.0
	var caught: bool = false
	for slot: int in target_tiers.keys():
		var score: float = 0.0
		if not installed_by_player[slot]:
			score = SCORE_NOT_DONE
		else:
			var installed: PartData = current_parts[slot]
			var target_tier: int = target_tiers[slot]
			if installed.tier == target_tier:
				score = SCORE_EXACT
			elif installed.tier > target_tier:
				score = SCORE_HIGHER
			elif installed.tier == 1:
				score = SCORE_LOWBALL_DETECTED
				caught = true
			else:
				score = rng.randf_range(5.0, 10.0)
		total += score
	var average: float = total / maxf(float(target_tiers.size()), 1.0)
	var satisfaction: float = BASE_SATISFACTION + average + float(TWIST_MOD[twist_choice])
	return {"satisfaction": clampf(satisfaction, 0.0, 100.0), "caught": caught}


## Dipanggil saat progres 100% pertama kali. Mengembalikan true bila twist muncul.
func roll_plot_twist(chance: float, rng: RandomNumberGenerator) -> bool:
	if twist_checked:
		return false
	twist_checked = true
	if rng.randf() >= chance:
		return false
	var best_slot: int = -1
	var best_price: int = -1
	for slot: int in target_tiers.keys():
		var price: int = get_target_part(slot).selling_price
		if price > best_price:
			best_price = price
			best_slot = slot
	if best_slot < 0 or target_tiers[best_slot] <= 1:
		return false
	twist_slot = best_slot
	twist_new_budget = maxi(_round_money(int(original_budget * rng.randf_range(0.4, 0.6))), 5000)
	twist_text = profile.pick_line(profile.twist_lines, rng).format({
		"budget": Money.format(twist_new_budget),
		"slot": PartData.slot_to_name(twist_slot),
	})
	twist_pending = true
	return true


## Tier tertinggi yang muat di budget baru untuk slot twist.
func get_affordable_twist_tier() -> int:
	var other_cost: int = 0
	for slot: int in target_tiers.keys():
		if slot != twist_slot:
			other_cost += get_target_part(slot).selling_price
	var remaining: int = twist_new_budget - other_cost
	var min_tier: int = mini((original_parts[twist_slot] as PartData).tier + 1, target_tiers[twist_slot])
	var best: int = min_tier
	for tier: int in range(min_tier, target_tiers[twist_slot] + 1):
		if _catalog.get_part_by_slot_tier(twist_slot, tier).selling_price <= remaining:
			best = tier
	return best


## Perkiraan dampak tiap pilihan Revisi Dadakan untuk ditampilkan ke pemain
## (tanpa mengubah state). Mengembalikan {profit, satisfaction, risk}.
## - ACCEPT (Turunkan): part diturunkan ke tier yang muat budget -> untung, kepuasan turun.
## - ABSORB_LOSS (Pasang): part tetap, klien bayar di bawah modal -> rugi, kepuasan naik.
## - REJECT (Tolak): klien bayar pas modal -> impas, kepuasan anjlok.
func preview_twist_choice(choice: TwistChoice) -> Dictionary:
	var other_cost: int = 0
	var other_bill: int = 0
	for slot: int in target_tiers.keys():
		if slot == twist_slot:
			continue
		other_cost += get_target_part(slot).cost_price
		other_bill += get_target_part(slot).selling_price
	var current: PartData = get_target_part(twist_slot)
	var cost: int = other_cost + current.cost_price
	var payment: int = 0
	match choice:
		TwistChoice.ACCEPT:
			var affordable: PartData = _catalog.get_part_by_slot_tier(twist_slot, get_affordable_twist_tier())
			cost = other_cost + affordable.cost_price
			payment = other_bill + affordable.selling_price
		TwistChoice.ABSORB_LOSS:
			payment = _absorb_payment(cost)
		TwistChoice.REJECT:
			payment = cost
	var satisfaction: float = BASE_SATISFACTION + SCORE_EXACT + float(TWIST_MOD[choice])
	return {
		"profit": payment - cost,
		"satisfaction": clampf(satisfaction, 0.0, 100.0),
		"risk": 0.0,
	}


## Terapkan keputusan pemain. Mengembalikan part yang dilepas (untuk dikembalikan ke stok) atau null.
## Budget di-set ulang supaya get_payment() menghasilkan untung/rugi/impas sesuai pilihan.
func apply_twist_choice(choice: TwistChoice) -> PartData:
	twist_pending = false
	twist_choice = choice
	var removed: PartData = null
	match choice:
		TwistChoice.ACCEPT:
			target_tiers[twist_slot] = get_affordable_twist_tier()
			removed = revert_slot(twist_slot)
			budget = _target_bill()
		TwistChoice.ABSORB_LOSS:
			budget = _absorb_payment(_target_cost())
		TwistChoice.REJECT:
			budget = _target_cost()
	return removed


func _absorb_payment(cost: int) -> int:
	return mini(twist_new_budget, _round_money(int(cost * ABSORB_PAY_RATIO)))


func _target_cost() -> int:
	var cost: int = 0
	for slot: int in target_tiers.keys():
		cost += get_target_part(slot).cost_price
	return cost


func _target_bill() -> int:
	var bill: int = 0
	for slot: int in target_tiers.keys():
		bill += get_target_part(slot).selling_price
	return bill
