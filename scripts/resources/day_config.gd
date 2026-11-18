class_name DayConfig
extends Resource
## Parameter progresi satu hari (GDD 6.2 Tabel Progresi Hari).

@export var day: int = 1
@export var max_clients: int = 4
## Bobot kemunculan Tier 1..5 di toko dan pesanan klien (0.0 - 1.0).
@export var tier_weights: PackedFloat32Array = PackedFloat32Array([1.0, 0.8, 0.2, 0.0, 0.0])
@export var max_order_slots: int = 1
## Batas atas total harga jual pesanan klien (GDD 6.2 Ekspektasi Budget).
@export var max_order_value: int = 250000
@export_range(0.0, 1.0) var plot_twist_chance: float = 0.2


func pick_tier(rng: RandomNumberGenerator, min_tier: int = 1) -> int:
	var total: float = 0.0
	for i: int in range(tier_weights.size()):
		if i + 1 >= min_tier:
			total += tier_weights[i]
	if total <= 0.0:
		return clampi(min_tier, 1, 5)
	var roll: float = rng.randf() * total
	for i: int in range(tier_weights.size()):
		if i + 1 < min_tier:
			continue
		roll -= tier_weights[i]
		if roll <= 0.0:
			return i + 1
	return clampi(min_tier, 1, 5)
