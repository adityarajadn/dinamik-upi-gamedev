extends Control
## SC-00 Main Menu.

@onready var play_button: Button = %PlayButton
@onready var logo: TextureRect = %Logo
@onready var info_panel: PanelContainer = %InfoPanel
@onready var info_popup: PopupAnimator = %InfoPopup
@onready var info_title: Label = %InfoTitle
@onready var info_body: Label = %InfoBody


func _ready() -> void:
	get_tree().paused = false
	_make_click_through(%Logo.get_parent().get_parent())
	OverlayUtil.pin_close_button(%InfoPanel, %InfoClose)
	OverlayUtil.add_backdrop(%InfoPanel)
	OverlayUtil.pin_close_button(%SettingsPanel, %SettingsClose)
	OverlayUtil.add_backdrop(%SettingsPanel)
	# Pengaturan cuma volume musik & SFX: buang kontrol lain kalau scene versi lama masih punya.
	var fullscreen: Node = find_child("FullscreenCheck", true, false)
	if fullscreen:
		fullscreen.queue_free()
	info_panel.visible = false
	play_button.pressed.connect(_on_play_pressed)
	%SettingsPanel.visible = false
	var settings_dim: CanvasItem = get_node_or_null("%SettingsDim")
	if settings_dim:
		settings_dim.visible = false
	%SettingsButton.pressed.connect(func() -> void:
		if settings_dim:
			settings_dim.visible = true
		%SettingsPanelPopupAnimator.show_popup())
	%SettingsPanelPopupAnimator.hidden.connect(func() -> void: if settings_dim: settings_dim.visible = false)
	%CreditsButton.pressed.connect(_show_info.bind("CREDITS", %CreditsText.text))
	%InfoClose.pressed.connect(info_popup.hide_popup)
	%SettingsClose.pressed.connect(%SettingsPanelPopupAnimator.hide_popup)
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
		%SettingsPanelPopupAnimator.hide_popup()
		get_viewport().set_input_as_handled()


func _on_play_pressed() -> void:
	GameState.new_game()
	AudioManager.play_sfx(&"motor_rev")
	SceneTransitionManager.change_scene(GameState.SCENE_INTRO, "fade")


func _show_info(title: String, body: String) -> void:
	info_title.text = title
	info_body.text = body
	# Credits: rata tengah; How to play tetap rata kiri.
	var centered: bool = title == "CREDITS"
	info_body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER if centered else HORIZONTAL_ALIGNMENT_LEFT
	info_body.vertical_alignment = VERTICAL_ALIGNMENT_CENTER if centered else VERTICAL_ALIGNMENT_TOP
	info_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var scroll: Control = info_body.get_parent() as Control
	info_body.custom_minimum_size.y = 0.0
	if centered:
		# Tunggu layout panel selesai, baru isi tinggi scroll supaya teks di tengah vertikal.
		(func() -> void: info_body.custom_minimum_size.y = scroll.size.y).call_deferred()
	info_popup.show_popup()


func _animate_logo() -> void:
	logo.pivot_offset = logo.size * 0.5
	var tween: Tween = create_tween().set_loops()
	tween.tween_property(logo, "rotation_degrees", 1.5, 1.4).set_trans(Tween.TRANS_SINE)
	tween.tween_property(logo, "rotation_degrees", -1.5, 1.4).set_trans(Tween.TRANS_SINE)


## Layout logo/tagline menutupi tombol: buat tembus klik (termasuk semua anaknya).
func _make_click_through(node: Node) -> void:
	if node is Control and not node is BaseButton:
		(node as Control).mouse_filter = Control.MOUSE_FILTER_IGNORE
	for child: Node in node.get_children():
		_make_click_through(child)
