extends Node2D
class_name CinemaScene

## 剧场组件

## 演出内容
@export var story_res:EventsRes

## 演出结束
signal  on_complete

func _ready() -> void:
	var children = get_children()
	if children.is_empty():
		printerr("出错了，组件下没有任何子元素")
		return
	_start_event_res()

## 开始演出
func _start_event_res():
	var _on_complete = on_complete
	if story_res: await GameManager.trigger_event_res(story_res)
	await SceneManager.backto(on_complete)
	#_on_complete.emit()
