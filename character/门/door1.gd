extends Event
class_name Door1


## 事件资源
#var event_res:Events_Res

@export var event_res:Events_Res


## 组件引用
var anim:AnimatedSprite2D:
	get(): return get_node("./AnimatedSprite2D2")

## 重写Event._load_event_config载入事件配置，该配置会在Event._ready里被调用
func _load_event_config():
	## 1. ExPage生效的情况下：
	if !page : return
	## 2. EventPage生效的情况下：处理碰撞，以及刷新精灵图和可见度
	if page.content: self.ingore_collsion = !page.content.is_collsion
	# 刷新精灵图
	_refresh_sprite_frame(page.frame_index,page)
	# 刷新可视化
	_init_event_visible(page)

## 重写获取动画名称的参数
func get_dir_animation_name(_dir:int) :
	match _dir:
		0: return "default"
		1: return "close"
		2:return "open"
		3: return "opened"
	return null

func _refresh_event_state(_item_name:StringName = "",_state:int = 0):
	await  super._refresh_event_state()
	# event_config = get_event_config()
	# if self.ori_cell_pos == Vector2i(8,9):
	# 	print("事件(%s,%s)重新刷新后的page为%s" % [ori_cell_pos.x,ori_cell_pos.y,page])
	if !page: _refresh_sprite_frame(0) # 将精灵图变回默认
		

## 从配置文件载入event资源
# 1 优先获取event_config
# 2 如果没有event_config就获取ex_config
func _load_eventres_from_config():
	if page: return
	var ex = handler.try_get_ex_page(ori_cell_pos)
	if !ex: return 
	var eec = ex.content
	print("eec",eec)
	if !eec: return null
	if eec is DoorEx:
		var _event_res =  eec._make_event_res()
		#print("生成的event_res:",event_res)
		return _event_res
	else: return null
	

## 寻找EventExConfig 弃用中
# func _get_eventex_config(coord:Vector2i) -> EventEx:
# 	var map_config:MapConfig = get_parent().get_parent()
# 	var filters = map_config.event_ex.filter(func(item:EventExConfig):return item.coord == coord)
# 	if filters.is_empty():
# 		return null
# 	return filters[0].event_ex

## 重写交互逻辑
func interact():
	if page:
		print("开始执行普通事件")
		super.interact()
	else:
		print("开始执行门事件")
		event_res = _load_eventres_from_config()
		#push_warning("生成的event_res:",event_res.tree)
		if !event_res:
			event_finish.emit()
			return
		await  _parse_event_config(event_res)
		print("门事件完成")

func interactable() -> bool:
	if page:
		return super.interactable()
	else:
		var config = _load_eventres_from_config()
		if !config:return false
		return true
	
func touchable() -> bool:
	if page:
		return super.touchable()
	else:
		if _find_around_enemy(cell_pos):
			return false
		var config = _load_eventres_from_config()
		if !config:return false
		return true

## 打开门
func open_door():
	await  play_anim("open")
	await play_anim("opened")

func close_door():
	await play_anim("close")
	await  play_anim("default")

## 可重写虚方法
func _play_open_se():
	AudioManager.play_door_open()
	pass
	
## 可重写虚方法
func _play_close_se():
	AudioManager.play_door_close()
	pass

## 播放事件动画
func play_anim(anim_name:String,custom_spd:float = 1):
	if anim_name == "default" || anim_name == "close":
		self.ingore_collsion = false
	if anim_name == "opened" || anim_name == "open":
		self.ingore_collsion = true

	if !anim:return
	## 播放开关门声音
	if anim_name == "open":
		_play_open_se()
	if anim_name == "close":
		_play_close_se()
	var frames = anim.sprite_frames
	if !frames:return
	## 判断是否存在该动画名称的动画
	if frames.has_animation(anim_name):
		anim.play(anim_name,custom_spd)
		await anim.animation_finished
