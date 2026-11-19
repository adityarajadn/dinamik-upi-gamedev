extends Control
## SC-05 Game Over / Menang: statistik + Restart Day / New Game / Menu.

const BG_LOSE: Texture2D = preload("res://assets/generated/bg_game_over.png")
const BG_WIN: Texture2D = preload("res://assets/generated/bg_win.png")


func _ready() -> void:
	var is_win: bool = GameState.final_is_win
	%Background.texture = BG_WIN if is_win else BG_LOSE
	%TitleLabel.text = "MOD MAESTRO!" if is_win else "WORKSHOP SHUT DOWN!"
	%TitleLabel.add_theme_color_override("font_color", Color(1, 0.902, 0) if is_win else Color(1, 0.0784, 0.5765))
	%ReasonLabel.text = GameState.final_reason
	%StatsLabel.text = "Days reached: %d / %d\nTotal clients served: %d\nAverage satisfaction: %d%%\nFinal balance: %s\nScams caught: %d times" % [
		GameState.day, GameState.CONFIG.total_days, GameState.clients_served_total,
		roundi(GameState.get_average_satisfaction()), Money.format(GameState.cash), GameState.deceptions_caught_total]
	# Kalah: cuma MAIN LAGI (mundur %d hari) atau MENU. Menang: GAME BARU atau MENU.
	%RestartDayButton.visible = not is_win
	%RestartDayButton.text = "PLAY AGAIN"
	%NewGameButton.visible = is_win
	%RestartDayButton.pressed.connect(_on_restart_day)
	%NewGameButton.pressed.connect(_on_new_game)
	%MenuButton.pressed.connect(func() -> void: SceneTransitionManager.change_scene(GameState.SCENE_MAIN_MENU))
	AudioManager.play_music(&"menu")
	AudioManager.play_sfx(&"happy" if is_win else &"plot_twist")
	%PanelPopup.show_popup()
	(%NewGameButton if is_win else %RestartDayButton).grab_focus()


func _on_restart_day() -> void:
	GameState.restart_day()
	SceneTransitionManager.change_scene(GameState.SCENE_STREET)


func _on_new_game() -> void:
	GameState.new_game()
	SceneTransitionManager.change_scene(GameState.SCENE_STREET)
