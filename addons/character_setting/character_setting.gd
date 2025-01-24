@tool
extends EditorPlugin

var btn:Button
var event_editor_panel:EventEditor
var custom_inspector: EditorInspectorPlugin
@export var custom_resource_type := preload("../../event_editor/models/events_res.gd")


func _enter_tree() -> void:
	event_editor_panel = preload("res://event_editor/event_editor.tscn").instantiate()
	event_editor_panel.name = "事件编辑器"
	var original_load = ResourceLoader.load
	add_control_to_bottom_panel(event_editor_panel,"事件编辑器")
	add_custom_type("Events_Res","Resource",custom_resource_type,preload("res://icon.svg"))	

	custom_inspector = preload("res://event_editor/res_inspector.gd").new()
	add_inspector_plugin(custom_inspector)

func _edit(resource: Object) -> void:
	print("123",resource)
	event_editor_panel.current_resource = resource


func _exit_tree() -> void:
	remove_control_from_bottom_panel(event_editor_panel)
	remove_custom_type("Events_Res")
	event_editor_panel.queue_free()
	pass


func _handles(object: Object) -> bool:
	# 确认插件是否处理自定义资源
	return object is Events_Res

func _notification(what):
	if what == NOTIFICATION_READY:
		pass
