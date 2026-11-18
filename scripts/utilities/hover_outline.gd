class_name HoverOutline
extends RefCounted
## Outline putih untuk objek yang bisa diklik/di-interaksi. Pakai: HoverOutline.set_hovered(item, true).
## Material dibuat sekali per item (uniform terpisah).

const SHADER: Shader = preload("res://shaders/hover_outline.gdshader")


static func set_hovered(item: CanvasItem, hovered: bool, width: float = 6.0) -> void:
	if item == null:
		return
	var material: ShaderMaterial = item.material as ShaderMaterial
	if material == null or material.shader != SHADER:
		if not hovered:
			return
		material = ShaderMaterial.new()
		material.shader = SHADER
		item.material = material
	material.set_shader_parameter("outline_width", width)
	material.set_shader_parameter("outline_enabled", 1.0 if hovered else 0.0)
