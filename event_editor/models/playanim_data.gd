extends BaseEventNode
class_name PlayAnimData

## 此事件 self
## 玩家 player
## 其他事件 other
@export var event_type:String

@export var event_coord:Variant = null

@export var anim_name:String

@export var wait_time:float


func _init(cmd:int = BaseEventNode.Scripts,pos:Vector2 = Vector2.ZERO,anim_name:String = "",event_type:String = "self",event_coord:Variant = null,wait_time:float = 0.3) -> void:
	self.node_type = cmd
	self.pos = pos
	self.anim_name = anim_name
	self.event_type = event_type
	self.event_coord = event_coord
	self.wait_time = wait_time

func _execute(event,args):
	var target_event
	match event_type:
		"self":target_event = event
		"player": GameManager.player
		"other": target_event =_get_event_by_coord()
	#print("event_type=%s,coord=%s,target_event=%s" % [event_type,event_coord,target_event])
	if target_event is Door1:
		await target_event.play_anim(anim_name,1)
		#await GameManager.wait(wait_time)

## 从坐标中获得event
func _get_event_by_coord() -> Event:
	if !event_coord:
		return null
	if !event_coord is Vector2i:
		printerr("event_coord的传参类型错误")
		return null
	## 找到当前地图某一个坐标上的事件
	var events =  GameManager.get_tree().get_nodes_in_group("events")
	print("filters=",events)
	var filters = events.filter(func(item:Event):return item.cell_pos == event_coord)
	print("filters=",filters)
	if filters.is_empty(): return null
	return filters[0]
	return null
