@tool
extends EditorPlugin

var btn:Button
var event_editor_panel:EventEditor
var custom_inspector: EditorInspectorPlugin
@export var custom_resource_type := preload("../../event_editor/models/events_res.gd")



func _enter_tree() -> void:
	_loaded_editor_translation()
	event_editor_panel = preload("res://event_editor/event_editor.tscn").instantiate()
	event_editor_panel.name = "事件编辑器"
	var original_load = ResourceLoader.load
	add_control_to_bottom_panel(event_editor_panel,"事件编辑器")
	add_custom_type("Events_Res","Resource",custom_resource_type,preload("res://icon.svg"))	

	add_custom_type("ExPage","Node2D",preload("res://event_sys/TilemapEventComponent/EventPage/event_page.gd"),preload("res://assets/icon/stair.png"))

	custom_inspector = preload("res://event_editor/res_inspector.gd").new()
	add_inspector_plugin(custom_inspector)

func _edit(resource: Object) -> void:
	print("123",resource)
	event_editor_panel.current_resource = resource

func _loaded_editor_translation():
	print("初始化语言配置")
	#var file = FileAccess.open("res://localization/local utf-8.zh.translation", FileAccess.READ)
	var e1 = ResourceLoader.load("res://localization/local utf-8.zh_CN.translation") as Translation
	var e2 = ResourceLoader.load("res://localization/e01_03.zh_CN.translation") as Translation
	# print("合并语言文件:t1的大小%s,t2的 大小:%s" % [e1.get_message_count(),e2.get_message("dialogue_06_resu")])
	var merged = merge_translations(e1,e2)
	TranslationServer.clear()
	if merged: TranslationServer.add_translation(merged)
	# print("测试翻译:%s 当前信息数量%s", [merged.get_message("dialogue_06_resu"),merged.get_message_count()])


func merge_translations(t1: Translation, t2: Translation) -> Translation:
	# print("合并语言文件:t1的大小%s,t2的 大小:%s" % [t1.get_message_list().size(),t2.get_message_count()])
	if not t1 or not t2:
		print("加载翻译失败")
		return null
	
	var merged = Translation.new()
	merged.set_locale("zh_CN") 
	# merged.
	
	# 复制 t1 的所有 key-value
	for key in t1.get_message_list():
		merged.add_message(key, t1.get_message(key))
	
	# 复制 t2，但避免 key 冲突（t2 优先）
	for key in t2.get_message_list():
		print(key)
		print(t2.get_message(key))
		merged.add_message(key, t2.get_message(key))  # 会覆盖 t1 的内容
	# merged.set_message_translation()
	return merged

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
