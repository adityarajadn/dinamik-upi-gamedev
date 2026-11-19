extends Control
## Tutorial singkat tiap kali mulai main. LANJUT untuk halaman berikut, LEWATI untuk skip.

signal finished

const STEPS: Array[Dictionary] = [
	{"title": "SELAMAT DATANG, MONTIR!", "body": "Bengkelmu baru buka. Layani pelanggan, pasang part sesuai pesanan, dan jaga celengan tetap terisi."},
	{"title": "PESANAN KLIEN", "body": "Baca panel pesanan di kanan: bagian motor yang diminta, tier, dan budget. Tab untuk buka/tutup panel."},
	{"title": "PASANG PART", "body": "Klik bagian motor bertanda *, lalu seret kartu part dari tray ke motor yang berpendar."},
	{"title": "SERAHKAN MOTOR", "body": "Kalau semua beres, klik SERAHKAN MOTOR. Hati-hati, klien bisa minta revisi dadakan!"},
	{"title": "BELANJA & UANG", "body": "Stok habis? Keluar (ESC) ke jalan, belanja di Toko Sparepart Jaya. Klik celengan untuk lihat buku kas."},
	{"title": "JANGAN BANGKRUT", "body": "Kepuasan rendah = pelanggan makin sepi. Kalau uang habis, kamu kalah dan mundur beberapa hari ke belakang."},
]

var _step: int = 0

@onready var title_label: Label = %TutorialTitle
@onready var body_label: Label = %TutorialBody
@onready var page_label: Label = %TutorialPage
@onready var next_button: Button = %TutorialNext
@onready var popup: PopupAnimator = %TutorialPanel/PopupAnimator


func _ready() -> void:
	visible = false
	next_button.pressed.connect(_next)
	%TutorialSkip.pressed.connect(_close)


func start() -> void:
	_step = 0
	visible = true
	popup.show_popup()
	_show_step()


func _next() -> void:
	AudioManager.play_sfx(&"page_flip")
	if _step >= STEPS.size() - 1:
		_close()
		return
	_step += 1
	_show_step()
	Juice.bounce(%TutorialPanel)


func _show_step() -> void:
	var step: Dictionary = STEPS[_step]
	title_label.text = step.title
	body_label.text = step.body
	page_label.text = "%d / %d" % [_step + 1, STEPS.size()]
	next_button.text = "MULAI!" if _step == STEPS.size() - 1 else "LANJUT"
	next_button.grab_focus()


func _close() -> void:
	if not visible:
		return
	popup.hide_popup()
	visible = false
	finished.emit()
