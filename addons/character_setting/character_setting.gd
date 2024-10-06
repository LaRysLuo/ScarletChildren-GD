@tool
extends EditorPlugin

var btn:Button


func _enter_tree() -> void:
	btn = Button.new()
	btn.name = "主要面板"
	add_control_to_dock(EditorPlugin.DOCK_SLOT_RIGHT_BL,btn)
	# Initialization of the plugin goes here.
	pass


func _exit_tree() -> void:
	remove_control_from_docks(btn)
	btn.queue_free()
	pass
