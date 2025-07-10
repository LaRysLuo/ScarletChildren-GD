extends Node2D

func _ready() -> void:
	call_deferred("refresh_character")

func refresh_character():
	var chars = get_tree().get_nodes_in_group("characters")
	for char in chars:
		if char is CharacterBase:
			print("char_name",char.name)
			char.face_to(Vector2i.UP)
