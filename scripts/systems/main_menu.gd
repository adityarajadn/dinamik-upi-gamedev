extends Control
## SC-00 Main Menu.

@onready var play_button: Button = %PlayButton
@onready var logo: TextureRect = %Logo
@onready var info_panel: PanelContainer = %InfoPanel
@onready var info_popup: PopupAnimator = %InfoPanel/PopupAnimator
@onready var info_title: Label = %InfoTitle
@onready var info_body: Label = %InfoBody


func _ready() -> void:
	get_tree().paused = false
	info_panel.visible = false
	play_button.pressed.connect(_on_play_pressed)
	%SettingsPanel.visible = false
	%SettingsButton.pressed.connect(%SettingsPanel/PopupAnimator.show_popup)
	%CreditsButton.pressed.connect(_show_info.bind("KREDIT", %CreditsText.text))
	%InfoClose.pressed.connect(info_popup.hide_popup)
	%SettingsClose.pressed.connect(%SettingsPanel/PopupAnimator.hide_popup)
	%MusicSlider.value = AudioManager.music_volume
	%SfxSlider.value = AudioManager.sfx_volume
	%MusicSlider.value_changed.connect(AudioManager.set_music_volume)
	%SfxSlider.value_changed.connect(func(value: float) -> void:
		AudioManager.set_sfx_volume(value)
		AudioManager.play_sfx(&"click"))
	AudioManager.play_music(&"menu")
	play_button.grab_focus()
	_animate_logo()


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("cancel"):
		return
	if info_panel.visible:
		info_popup.hide_popup()
		get_viewport().set_input_as_handled()
	elif %SettingsPanel.visible:
		%SettingsPanel/PopupAnimator.hide_popup()
		get_viewport().set_input_as_handled()


func _on_play_pressed() -> void:
	GameState.new_game()
	AudioManager.play_sfx(&"motor_rev")
	SceneTransitionManager.change_scene(GameState.SCENE_INTRO, "fade")


func _show_info(title: String, body: String) -> void:
	info_title.text = title
	info_body.text = body
	info_popup.show_popup()


func _animate_logo() -> void:
	logo.pivot_offset = logo.size * 0.5
	var tween: Tween = create_tween().set_loops()
	tween.tween_property(logo, "rotation_degrees", 1.5, 1.4).set_trans(Tween.TRANS_SINE)
	tween.tween_property(logo, "rotation_degrees", -1.5, 1.4).set_trans(Tween.TRANS_SINE)
