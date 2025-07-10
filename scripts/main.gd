extends Node2D

#@onready var main_menu = $CanvasLayer/SceneMain
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("cancel"):
		SceneManager.navigate_to("main_menu")
		print("123")
		#main_menu.show_window()
		#get_window().set_input_as_handled()
		
