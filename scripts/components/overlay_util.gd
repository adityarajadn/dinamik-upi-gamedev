class_name OverlayUtil
## Helper overlay: tombol close di pojok kanan atas panel + backdrop hitam 25% di belakang panel.
## Dipasang dari kode supaya tetap benar walau scene diubah/ditimpa di editor.

const DIM_COLOR: Color = Color(0, 0, 0, 0.25)
const CLOSE_SIZE: float = 84.0


## Pindahkan tombol close ke pojok kanan atas panel (setengah keluar dari bingkai).
static func pin_close_button(panel: Control, button: Control) -> void:
	if panel == null or button == null:
		return
	var corner: Control = panel.get_node_or_null("CloseCorner") as Control
	if corner == null:
		corner = Control.new()
		corner.name = "CloseCorner"
		corner.mouse_filter = Control.MOUSE_FILTER_IGNORE
		panel.add_child(corner)
	if button.get_parent() != corner:
		button.reparent(corner, false)
	if button is Button:
		(button as Button).text = ""
		(button as Button).theme_type_variation = &"CloseButtonBig"
		if (button as Button).tooltip_text.is_empty():
			(button as Button).tooltip_text = "Close"
	button.custom_minimum_size = Vector2(CLOSE_SIZE, CLOSE_SIZE)
	button.size_flags_horizontal = Control.SIZE_SHRINK_END
	button.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	button.offset_left = -CLOSE_SIZE * 0.5
	button.offset_right = CLOSE_SIZE * 0.5
	button.offset_top = -CLOSE_SIZE * 0.8
	button.offset_bottom = CLOSE_SIZE * 0.2


## Backdrop full-screen di belakang panel, tampil/hilang mengikuti panel.
static func add_backdrop(panel: Control) -> ColorRect:
	if panel == null:
		return null
	var parent: Node = panel.get_parent()
	var dim: ColorRect = parent.get_node_or_null(String(panel.name) + "Dim") as ColorRect
	if dim == null:
		dim = ColorRect.new()
		dim.name = String(panel.name) + "Dim"
		dim.color = DIM_COLOR
		dim.mouse_filter = Control.MOUSE_FILTER_STOP
		parent.add_child(dim)
		parent.move_child(dim, panel.get_index())
		dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		panel.visibility_changed.connect(func() -> void: dim.visible = panel.visible)
	dim.visible = panel.visible
	return dim
