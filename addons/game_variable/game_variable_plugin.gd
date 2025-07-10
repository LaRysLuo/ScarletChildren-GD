@tool
extends EditorPlugin

var variable_eidtor

func _enter_tree() -> void:
	var ui_scene = preload("./ui/game_variable_ui.tscn")
	variable_eidtor = ui_scene.instantiate()
	EditorInterface.get_editor_main_screen().add_child(variable_eidtor)
	# add_control_to_bottom_panel(variable_eidtor,"变量编辑器")
	#add_control_to_container(CONTAINER_CANVAS_EDITOR_BOTTOM, variable_eidtor)  # 添加到右上角停靠面板



func _exit_tree() -> void:
	if variable_eidtor:
		variable_eidtor.queue_free()
	# remove_control_from_bottom_panel(variable_eidtor)
	#remove_control_from_container(CONTAINER_CANVAS_EDITOR_BOTTOM,variable_eidtor)


func _has_main_screen():
	return true

func _make_visible(visible):
	if variable_eidtor:
		variable_eidtor.visible = visible

func _get_plugin_name():
	return "变量管理器"