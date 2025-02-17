extends Event
class_name SavePoint

## 存档点的封装

## 存档点的事件资源
@export var event_res:Events_Res

## 组件引用
var anim:AnimatedSprite2D:
	get(): return get_node("./AnimatedSprite2D2")

func _ready() -> void:
	#GameManager.player.on_interact_changed.connect(change_person_shadow)
	pass

## 重写交互逻辑
func interact():
	if !event_res:
		event_finish.emit()
		return
	_parse_event_config(event_res)

func interactable() -> bool:
	return true
	
func touchable() -> bool:
	return true

func change_person_shadow(event:Event,state:int):
	if event == self: anim.frame = state
	else: anim.frame = 0
