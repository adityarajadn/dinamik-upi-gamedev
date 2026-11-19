class_name ConfirmDialog
extends Control
## Modal konfirmasi "Yakin?" untuk aksi penting (beli, serahkan, keluar). Pakai: `if await dialog.ask(...)`.

signal answered(confirmed: bool)

@onready var message_label: Label = %ConfirmMessage
@onready var confirm_button: Button = %ConfirmYes
@onready var cancel_button: Button = %ConfirmNo
@onready var popup: PopupAnimator = %ConfirmPanelPopupAnimator


func _ready() -> void:
	visible = false
	confirm_button.pressed.connect(_answer.bind(true))
	cancel_button.pressed.connect(_answer.bind(false))


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("cancel") or event.is_action_pressed("pause"):
		get_viewport().set_input_as_handled()
		_answer(false)


func ask(message: String, confirm_text: String = "CONFIRM", cancel_text: String = "CANCEL") -> bool:
	message_label.text = message
	confirm_button.text = confirm_text
	cancel_button.text = cancel_text
	visible = true
	popup.show_popup()
	cancel_button.grab_focus()
	var confirmed: bool = await answered
	return confirmed


func _answer(confirmed: bool) -> void:
	if not visible:
		return
	popup.hide_popup()
	visible = false
	answered.emit(confirmed)
