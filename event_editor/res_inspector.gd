@tool
extends EditorInspectorPlugin

func _can_handle(object: Object) -> bool:
	return object is EventCodeGroup
	
func _parse_property(object: Object, type: Variant.Type, name: String, hint_type: PropertyHint, hint_string: String, usage_flags: int, wide: bool) -> bool:
	return true

func _parse_category(object: Object, category: String) -> void:
	pass

func _parse_group(object: Object, group: String) -> void:
	pass

func _parse_end(object: Object) -> void:
	pass
