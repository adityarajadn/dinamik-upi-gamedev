class_name PartCatalog
extends Resource
## Katalog seluruh varian komponen (25 entri).

@export var parts: Array[PartData] = []


func get_part(part_id: StringName) -> PartData:
	for part: PartData in parts:
		if part.part_id == part_id:
			return part
	push_error("PartCatalog: part '%s' not found" % part_id)
	return null


func get_part_by_slot_tier(slot: int, tier: int) -> PartData:
	for part: PartData in parts:
		if part.slot == slot and part.tier == tier:
			return part
	return null


func get_parts_for_slot(slot: int) -> Array[PartData]:
	var result: Array[PartData] = []
	for part: PartData in parts:
		if part.slot == slot:
			result.append(part)
	result.sort_custom(func(a: PartData, b: PartData) -> bool: return a.tier < b.tier)
	return result


func get_cheapest_cost() -> int:
	var cheapest: int = 0
	for part: PartData in parts:
		if cheapest == 0 or part.cost_price < cheapest:
			cheapest = part.cost_price
	return cheapest
