## 管理所有的游戏事件
extends  Node2D
class_name GameEvent



## 属性
var is_buszing = false

## 信号
signal  on_event_trigger_start # 当有事件开始了
signal  on_event_trigger_end # 当事件触发结束了
signal  on_event_play_se(se_name:String) # 当事件想要播放音乐


## 回调函数，当场景初始化时，寻找本地图上所有的事件，并连接函数
func init_all_event():
	print("来到新场景，正在初始所有事件")
	var events = get_tree().get_nodes_in_group("events")
	print("事件数量为：",events.size())
	for event:Event in events:
		if !event.on_play_se.is_connected(_play_se):
			event.on_play_se.connect(_play_se)
			event.on_triggered.connect(_event_triggered)
 
## 回调更新，当game_state变化时，此处也随即更新
func update_game_state(_state:int, _is_buszing:bool):
	self.is_buszing = is_buszing

func _play_se(_se_name:String):
	on_event_play_se.emit(_se_name)
	pass

## 当有事件触发了
func _event_triggered(event_res:EventsRes,event:Event):
	if self.is_buszing: 
		push_error("游戏正在忙碌中")
		return
	print("场景中有事件触发了")
	on_event_trigger_start.emit()
	# 设置事件的一次性操作
	if !event_res: return
	await event.set_event_one_shot()
	print("开始执行事件")
	await trigger_event_res(event_res,event)
	event.event_finish.emit()
	on_event_trigger_end.emit()


## 触发事件的封装
func trigger_event_res(event_res:EventsRes,trigger_self:Event = null,args= {}):
	var event:BaseEventNode = event_res.tree
	## WARNING 事件处理主逻辑
	## 如果需要添加新的节点逻辑，请去对应继承BaseEventNode的子类去重写_execute
	## 新建一个自定义的事件线程（不是真的线程，可以叫协程或者序列）来处理所有事件，并等待处理完成
	var et = EventThread.new()
	await et.trigger_event(event,trigger_self,args).on_complete
