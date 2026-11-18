class_name PlayerInteraction
extends Node
## Deteksi pintu terdekat lewat Area2D dan memicu interaksi (tombol E/W/Space).

signal interact_requested(door: Door)

@export var area_path: NodePath

var can_interact: bool = true
var _nearby: Array[Door] = []

@onready var area: Area2D = get_node(area_path) as Area2D


func _ready() -> void:
	area.area_entered.connect(_on_area_entered)
	area.area_exited.connect(_on_area_exited)


func _unhandled_input(event: InputEvent) -> void:
	if not can_interact or _nearby.is_empty():
		return
	if event.is_action_pressed("interact"):
		get_viewport().set_input_as_handled()
		interact_requested.emit(_nearby.back())


func _on_area_entered(other: Area2D) -> void:
	var door: Door = other as Door
	if door and not _nearby.has(door):
		_nearby.append(door)
		door.set_highlighted(true)


func _on_area_exited(other: Area2D) -> void:
	var door: Door = other as Door
	if door:
		_nearby.erase(door)
		door.set_highlighted(false)
