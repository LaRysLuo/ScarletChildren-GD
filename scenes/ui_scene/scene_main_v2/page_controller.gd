extends Control
class_name PageController

"""
页面控制器，显示多个页面的内容
"""

const PAGES = {
	"phone_picture":preload("res://scenes/ui_scene/scene_main_v2/pages/page_picture/page_picture.tscn"),
	"phone_memo":preload("res://scenes/ui_scene/scene_main_v2/pages/page_memo/page_memo.tscn"),
}


const FADE_OFFSET = 283
const FADE_TIME =  0.1

signal all_finished

func _ready() -> void:
	hide()

## 压入页面
func push_page(page_name:String):
	if PAGES.has(page_name):
		var page = PAGES.get(page_name)
		var ent = page.instantiate()
		if ent.has_signal("finished"):
			ent.finished.connect(_pop_page)
		add_child(ent)
		show()
		_fade_in(ent)
	else: push_error("错误的手机页面名称：%s" % page_name)

func _fade_in(ent):
	ent.position.x = FADE_OFFSET
	var tween = create_tween()
	tween.tween_property(ent,"modulate:a",1,FADE_TIME)
	tween.tween_property(ent,"position:x",0,FADE_TIME)
	await tween.finished

func _fade_out(ent):
	var tween = create_tween()
	tween.tween_property(ent,"position:x",FADE_OFFSET,FADE_TIME)
	tween.tween_property(ent,"modulate:a",0,FADE_TIME)
	await tween.finished


func _pop_page():
	var node = get_children().back()
	await _fade_out(node)
	remove_child(node)
	node.queue_free()
	if get_children().is_empty():
		all_finished.emit()
	
