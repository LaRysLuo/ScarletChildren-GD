extends Node2D



func _ready() -> void:
	call_deferred("refresh_character")

func refresh_character():
	var chars = get_tree().get_nodes_in_group("characters")
	for char in chars:
		if char is CharacterBase:
			print("char_name",char.name)
			match char.name:
				"CharacterResu":
					char.face_to(Vector2i.RIGHT)
				"CharacterHasin": 
					char.face_to(Vector2i.RIGHT)
				"CharacterAi":
					char.face_to(Vector2i.LEFT)
				"CharacterYui":
					char.face_to(Vector2i.LEFT)
