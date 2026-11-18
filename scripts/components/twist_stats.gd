class_name TwistStats
extends VBoxContainer
## Ringkasan dampak satu pilihan Revisi Dadakan: uang, kepuasan (bar), risiko ketahuan (bar).

const COLOR_GOOD: Color = Color(0.2, 0.75, 0.35, 1)
const COLOR_MID: Color = Color(1, 0.75, 0.1, 1)
const COLOR_BAD: Color = Color(0.9, 0.2, 0.25, 1)

@onready var money_value: Label = $Money/Value
@onready var satisfaction_bar: ProgressBar = $Satisfaction/Bar
@onready var satisfaction_value: Label = $Satisfaction/Value
@onready var risk_row: HBoxContainer = $Risk
@onready var risk_bar: ProgressBar = $Risk/Bar
@onready var risk_value: Label = $Risk/Value


func setup(preview: Dictionary) -> void:
	var profit: int = preview.profit
	money_value.text = ("+" if profit >= 0 else "-") + Money.format(absi(profit))
	money_value.add_theme_color_override("font_color", COLOR_GOOD if profit > 0 else (COLOR_MID if profit == 0 else COLOR_BAD))
	var satisfaction: float = preview.satisfaction
	satisfaction_bar.value = satisfaction
	satisfaction_value.text = "%d%%" % roundi(satisfaction)
	_tint_bar(satisfaction_bar, COLOR_GOOD if satisfaction >= 75.0 else (COLOR_MID if satisfaction > 45.0 else COLOR_BAD))
	var risk: float = preview.risk
	risk_row.visible = risk > 0.0
	risk_bar.value = risk * 100.0
	risk_value.text = "%d%%" % roundi(risk * 100.0)
	_tint_bar(risk_bar, COLOR_BAD)


func _tint_bar(bar: ProgressBar, color: Color) -> void:
	var fill: StyleBoxFlat = bar.get_theme_stylebox("fill").duplicate() as StyleBoxFlat
	if fill == null:
		return
	fill.bg_color = color
	bar.add_theme_stylebox_override("fill", fill)
