extends Event
class_name Door1

## MAIN LOGIC
#1 门打开
#2 玩家前进步
#3 画面淡出
#4 场景转移
#5 等到
#6 画面淡入
#7 玩家前进1步

## 事件资源
#var event_res:Events_Res

@export var event_res:Events_Res


## 组件引用
var anim:AnimatedSprite2D:
	get(): return get_node("./AnimatedSprite2D2")

func _ready() -> void:
	#GameManager.player.on_interact_changed.connect(change_person_shadow)
	#self.event_res = _load_eventres_from_config()
	pass

## 从配置文件载入event资源
func _load_eventres_from_config():
	var eec = _get_eventex_config(cell_pos)
	if !eec: return null
	if eec is DoorEx:
		var event_res =  eec._make_event_res()
		#print("生成的event_res:",event_res)
		return event_res
	else: return null
	

## 寻找EventExConfig
func _get_eventex_config(coord:Vector2i) -> EventEx:
	var map_config:MapConfig = get_parent().get_parent() as MapConfig
	var filters = map_config.event_ex.filter(func(item:EventExConfig):return item.coord == coord)
	if filters.is_empty():
		return null
	return filters[0].event_ex

## 重写交互逻辑
func interact():
	event_res = _load_eventres_from_config()
	#push_warning("生成的event_res:",event_res.tree)
	if !event_res:
		event_finish.emit()
		return
	await  _parse_event_config(event_res)
	print("X事件交互完成")

func interactable() -> bool:
	var config = _load_eventres_from_config()
	if !config:return false
	return true
	
func touchable() -> bool:
	var config = _load_eventres_from_config()
	if !config:return false
	return true

## 播放事件动画
func play_anim(anim_name:String):
	if anim_name == "default":
		self.ingore_collsion = false
	if anim_name == "opened":
		self.ingore_collsion = true
	if !anim:return
	var frames = anim.sprite_frames
	if !frames:return
	## 判断是否存在该动画名称的动画
	if frames.has_animation(anim_name):
		anim.play(anim_name)
		await anim.animation_finished
