extends Node
## Audio lintas scene. Semua AudioStreamPlayer sudah ada di scene autoload (tanpa node runtime).

const MUSIC: Dictionary = {
	&"menu": preload("res://assets/generated/audio/bgm_menu.mp3"),
	&"street": preload("res://assets/generated/audio/bgm_street.mp3"),
	&"workshop": preload("res://assets/generated/audio/bgm_workshop.mp3"),
	&"shop": preload("res://assets/generated/audio/bgm_shop.mp3"),
}

const SFX: Dictionary = {
	&"wrench": preload("res://assets/generated/audio/sfx_tool_wrench.mp3"),
	&"install": preload("res://assets/generated/audio/sfx_install_pop.mp3"),
	&"install_fail": preload("res://assets/generated/audio/sfx_install_fail.mp3"),
	&"coin": preload("res://assets/generated/audio/sfx_coin_drop.mp3"),
	&"plot_twist": preload("res://assets/generated/audio/sfx_revision_twist.mp3"),
	&"motor_rev": preload("res://assets/generated/audio/sfx_motor_rev.mp3"),
	&"door": preload("res://assets/generated/audio/sfx_door_bell.mp3"),
	&"click": preload("res://assets/generated/audio/sfx_ui_click.mp3"),
	&"happy": preload("res://assets/generated/audio/sfx_client_happy.mp3"),
	&"angry": preload("res://assets/generated/audio/sfx_client_angry.mp3"),
	&"restock": preload("res://assets/generated/audio/sfx_restock_ding.mp3"),
	&"page_flip": preload("res://assets/generated/audio/sfx_page_flip.mp3"),
}

@export var music_fade_duration: float = 0.6
@export var music_volume_db: float = 0.0

var current_music: StringName = &""
var _music_tween: Tween
var _next_sfx_index: int = 0

@onready var music_player: AudioStreamPlayer = $MusicPlayer
@onready var sfx_players: Array[Node] = $SfxPlayers.get_children()


func play_music(music_id: StringName) -> void:
	if music_id == current_music and music_player.playing:
		return
	if not MUSIC.has(music_id):
		push_warning("AudioManager: musik '%s' tidak terdaftar" % music_id)
		return
	current_music = music_id
	if _music_tween and _music_tween.is_running():
		_music_tween.kill()
	_music_tween = create_tween()
	if music_player.playing:
		_music_tween.tween_property(music_player, "volume_db", -40.0, music_fade_duration * 0.5)
	_music_tween.tween_callback(func() -> void:
		music_player.stream = MUSIC[music_id]
		music_player.volume_db = -40.0
		music_player.play())
	_music_tween.tween_property(music_player, "volume_db", music_volume_db, music_fade_duration)


func stop_music() -> void:
	current_music = &""
	music_player.stop()


func play_sfx(sfx_id: StringName, pitch_variance: float = 0.06) -> void:
	if not SFX.has(sfx_id):
		push_warning("AudioManager: SFX '%s' tidak terdaftar" % sfx_id)
		return
	var player: AudioStreamPlayer = sfx_players[_next_sfx_index] as AudioStreamPlayer
	_next_sfx_index = (_next_sfx_index + 1) % sfx_players.size()
	player.stream = SFX[sfx_id]
	player.pitch_scale = 1.0 + randf_range(-pitch_variance, pitch_variance)
	player.play()
