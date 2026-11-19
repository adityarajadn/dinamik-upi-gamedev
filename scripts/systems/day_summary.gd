extends Control
## SC-04 Rekap harian: laba/rugi, lanjut hari berikutnya.

@onready var panel_popup: PopupAnimator = %Panel/PopupAnimator


func _ready() -> void:
	AudioManager.play_music(&"menu")
	var net: int = GameState.income_today - GameState.expense_today
	var average: float = GameState.get_average_satisfaction()
	%TitleLabel.text = "TUTUP BENGKEL - HARI %d" % GameState.day
	%IncomeLabel.text = "Pendapatan Kotor: %s" % Money.format(GameState.income_today)
	%ExpenseLabel.text = "Modal Suku Cadang: %s" % Money.format(GameState.expense_today)
	%NetLabel.text = "Laba Bersih: %s" % Money.format(net)
	%NetLabel.add_theme_color_override("font_color", Color(0.08, 0.91, 0.76) if net >= 0 else Color(1, 0.44, 0.6))
	%CashLabel.text = "Saldo Celengan: %s" % Money.format(GameState.cash)
	%ServedLabel.text = "Klien dilayani hari ini: %d" % GameState.clients_served_today
	%SatLabel.text = "Kepuasan rata-rata: %d%%" % roundi(average)
	var is_last_day: bool = GameState.day >= GameState.CONFIG.total_days
	%NextButton.text = "LIHAT HASIL AKHIR" if is_last_day else "MULAI HARI BARU"
	%NextButton.pressed.connect(_on_next_pressed)
	%NextButton.grab_focus()
	panel_popup.show_popup()
	AudioManager.play_sfx(&"coin")


func _on_next_pressed() -> void:
	%NextButton.disabled = true
	GameState.advance_after_summary()
