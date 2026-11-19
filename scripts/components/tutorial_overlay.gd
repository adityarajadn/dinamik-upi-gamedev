extends Control
## Tutorial spotlight: layar digelapkan, bagian UI yang dibahas "dilubangi" dan diberi bingkai berdenyut,
## lalu panel penjelasan diletakkan di samping bagian itu. CONTINUE untuk lanjut, SKIP untuk lewati.
##
## Setiap langkah: {"title": String, "body": String, "target": Callable (opsional, -> Rect2 layar)}.
## Target dievaluasi saat langkah tampil, jadi aman untuk node yang bergerak / berubah ukuran.

signal finished

## Dipakai kalau pemanggil tidak memberi langkah sendiri.
const DEFAULT_STEPS: Array[Dictionary] = [
	{"title": "WELCOME, MECHANIC!", "body": "Your workshop just opened. Serve customers, install parts as ordered, and keep the piggy bank full."},
	{"title": "DON'T GO BROKE", "body": "Low satisfaction = fewer customers. Run out of money and you lose, going back a few days."},
]
const HOLE_PADDING: float = 14.0
const PANEL_GAP: float = 28.0
const SCREEN_MARGIN: float = 24.0
const DIM_ALPHA: float = 0.72

const SPOTLIGHT_SHADER: String = """
shader_type canvas_item;
uniform vec4 hole = vec4(0.0);      // x, y, w, h dalam pixel lokal ColorRect
uniform float radius = 18.0;
uniform float alpha = 0.72;
uniform vec2 rect_size = vec2(1920.0, 1080.0);

float rounded_box(vec2 p, vec2 half_size, float r) {
	vec2 q = abs(p) - half_size + vec2(r);
	return length(max(q, 0.0)) + min(max(q.x, q.y), 0.0) - r;
}

void fragment() {
	vec2 p = UV * rect_size;
	float a = alpha;
	if (hole.z > 0.0 && hole.w > 0.0) {
		vec2 c = hole.xy + hole.zw * 0.5;
		float d = rounded_box(p - c, hole.zw * 0.5, min(radius, min(hole.z, hole.w) * 0.5));
		a *= smoothstep(0.0, 6.0, d);
	}
	COLOR = vec4(0.0, 0.0, 0.0, a);
}
"""

var _steps: Array = []
var _step: int = 0
var _hole: Rect2 = Rect2()
var _hole_tween: Tween
var _ring_time: float = 0.0
var _ring: Control

@onready var dim: ColorRect = $Dim
@onready var panel: PanelContainer = %TutorialPanel
@onready var title_label: Label = %TutorialTitle
@onready var body_label: Label = %TutorialBody
@onready var page_label: Label = %TutorialPage
@onready var next_button: Button = %TutorialNext
@onready var popup: PopupAnimator = %TutorialPanelPopupAnimator


func _ready() -> void:
	visible = false
	next_button.pressed.connect(_next)
	%TutorialSkip.pressed.connect(_close)
	# Overlay dibangun dari kode supaya tidak bergantung pada pengaturan di scene.
	var material := ShaderMaterial.new()
	var shader := Shader.new()
	shader.code = SPOTLIGHT_SHADER
	material.shader = shader
	dim.material = material
	dim.color = Color.WHITE
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	panel.set_anchors_preset(Control.PRESET_TOP_LEFT)
	_ring = Control.new()
	_ring.name = "SpotlightRing"
	_ring.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ring.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_ring.draw.connect(_draw_ring)
	add_child(_ring)
	move_child(_ring, dim.get_index() + 1)
	resized.connect(func() -> void: if visible: _show_step(false))


func start(steps: Array = []) -> void:
	_steps = steps if not steps.is_empty() else DEFAULT_STEPS
	_step = 0
	_hole = Rect2()
	visible = true
	popup.show_popup()
	_show_step(false)


func _process(delta: float) -> void:
	if not visible:
		return
	_ring_time += delta
	_ring.queue_redraw()


func _next() -> void:
	AudioManager.play_sfx(&"page_flip")
	if _step >= _steps.size() - 1:
		_close()
		return
	_step += 1
	_show_step(true)
	Juice.bounce(panel)


func _show_step(animate: bool) -> void:
	var step: Dictionary = _steps[_step]
	title_label.text = step.get("title", "")
	body_label.text = step.get("body", "")
	page_label.text = "%d / %d" % [_step + 1, _steps.size()]
	next_button.text = "START!" if _step == _steps.size() - 1 else "CONTINUE"
	next_button.grab_focus()
	var target: Rect2 = _resolve_target(step)
	_move_hole(target, animate)
	_place_panel.call_deferred(target)


func _resolve_target(step: Dictionary) -> Rect2:
	var getter: Variant = step.get("target")
	if getter is Callable and (getter as Callable).is_valid():
		var r: Variant = (getter as Callable).call()
		if r is Rect2 and (r as Rect2).has_area():
			var local: Rect2 = r as Rect2
			local.position -= global_position
			return local.grow(HOLE_PADDING)
	return Rect2()


func _move_hole(target: Rect2, animate: bool) -> void:
	if _hole_tween and _hole_tween.is_running():
		_hole_tween.kill()
	# Tanpa target: lubang menyusut ke tengah layar (layar gelap penuh).
	var to: Rect2 = target if target.has_area() else Rect2(size * 0.5, Vector2.ZERO)
	if not animate or not _hole.has_area() and not target.has_area():
		_set_hole(to)
		return
	var from: Rect2 = _hole if _hole.has_area() else Rect2(to.get_center(), Vector2.ZERO)
	_hole_tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_hole_tween.tween_method(func(t: float) -> void:
		_set_hole(Rect2(from.position.lerp(to.position, t), from.size.lerp(to.size, t))), 0.0, 1.0, 0.35)


func _set_hole(r: Rect2) -> void:
	_hole = r
	var mat: ShaderMaterial = dim.material as ShaderMaterial
	mat.set_shader_parameter("hole", Vector4(r.position.x, r.position.y, r.size.x, r.size.y))
	mat.set_shader_parameter("rect_size", dim.size)
	mat.set_shader_parameter("alpha", DIM_ALPHA)


## Panel di bawah / atas / kanan / kiri lubang, pilih sisi yang muat; tanpa target: tengah layar.
func _place_panel(target: Rect2) -> void:
	panel.reset_size()
	var ps: Vector2 = panel.get_combined_minimum_size()
	panel.size = ps
	var area: Vector2 = size
	var pos: Vector2
	if not target.has_area():
		pos = (area - ps) * 0.5
	else:
		var c: Vector2 = target.get_center()
		var options: Array[Vector2] = [
			Vector2(c.x - ps.x * 0.5, target.end.y + PANEL_GAP),
			Vector2(c.x - ps.x * 0.5, target.position.y - PANEL_GAP - ps.y),
			Vector2(target.end.x + PANEL_GAP, c.y - ps.y * 0.5),
			Vector2(target.position.x - PANEL_GAP - ps.x, c.y - ps.y * 0.5),
		]
		# Fallback (target besar): taruh di sisi atas/bawah layar yang paling jauh dari target.
		pos = Vector2(c.x - ps.x * 0.5, SCREEN_MARGIN if c.y > area.y * 0.5 else area.y - ps.y - SCREEN_MARGIN)
		for o: Vector2 in options:
			var r := Rect2(o, ps)
			var fits: bool = r.position.x >= SCREEN_MARGIN and r.position.y >= SCREEN_MARGIN \
				and r.end.x <= area.x - SCREEN_MARGIN and r.end.y <= area.y - SCREEN_MARGIN
			if fits and not r.intersects(target):
				pos = o
				break
	pos.x = clampf(pos.x, SCREEN_MARGIN, maxf(SCREEN_MARGIN, area.x - ps.x - SCREEN_MARGIN))
	pos.y = clampf(pos.y, SCREEN_MARGIN, maxf(SCREEN_MARGIN, area.y - ps.y - SCREEN_MARGIN))
	panel.position = pos


func _draw_ring() -> void:
	if not _hole.has_area():
		return
	var pulse: float = 0.5 + 0.5 * sin(_ring_time * 5.0)
	var r: Rect2 = _hole.grow(2.0 + pulse * 4.0)
	var col := Color(1, 0.83, 0.1, 0.65 + pulse * 0.35)
	_ring.draw_rect(r, col, false, 5.0)
	_ring.draw_rect(r.grow(5.0), Color(1, 0.12, 0.56, 0.35 * (1.0 - pulse)), false, 3.0)


func _close() -> void:
	if not visible:
		return
	popup.hide_popup()
	visible = false
	finished.emit()
