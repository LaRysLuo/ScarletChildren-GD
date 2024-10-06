extends Node



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var boolean = "res://addons/dialogue_manager/example_balloon/example_balloon.tscn"
	var resource := load("res://story/dialogue_text.dialogue")
	DialogueManager.show_dialogue_balloon_scene(boolean,resource, "开始标题1")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
