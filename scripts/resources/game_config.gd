class_name GameConfig
extends Resource
## Parameter global ekonomi, waktu, dan kondisi menang/kalah.

@export var start_cash: int = 400000
## 1 hari in-game = 300 detik nyata (GDD 6.2).
@export var day_length_sec: float = 120.0
@export var day_start_minutes: int = 480 ## 08:00
@export var day_end_minutes: int = 1200 ## 20:00
@export var second_restock_minutes: int = 1020 ## 17:00
@export var queue_capacity: int = 5
@export var first_clients_count: int = 2
@export var spawn_interval_min: float = 30.0
@export var spawn_interval_max: float = 60.0
@export var total_days: int = 5
@export var shop_offer_count: int = 9
@export var win_min_clients: int = 15
@export_range(0.0, 100.0) var win_min_satisfaction: float = 75.0
@export_range(0.0, 100.0) var lose_satisfaction: float = 10.0
## Kalah reputasi baru dicek setelah sejumlah klien dilayani.
@export var lose_check_min_clients: int = 3
## Saat kalah, mundur sekian hari ke belakang.
@export var rollback_days: int = 10
@export var starter_inventory: Dictionary = {}
@export var days: Array[DayConfig] = []
@export var clients: Array[ClientProfile] = []


func get_day_config(day: int) -> DayConfig:
	for config: DayConfig in days:
		if config.day == day:
			return config
	return days.back() if not days.is_empty() else DayConfig.new()
