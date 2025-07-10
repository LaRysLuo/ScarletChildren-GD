extends BaseEventNode
class_name SubThreadData


func  _init(_cmd:int = BaseEventNode.SubThread,_pos:Vector2 = Vector2.ZERO) -> void:
	self.node_type = _cmd
	self.pos = _pos

## 获得子节点，索引1
func next_sub() -> BaseEventNode:
	return super.next(1)
	
## 重写父类虚方法
func _execute(_ent:Event,_args):
	print_rich("[color=#B94D61]- 正在执行《分支线程》[/color]")
	# 运行子线程
	var sub_event:BaseEventNode = next_sub()
	var sub_start = StartData.new()
	sub_start.children.append(ChildrenNodeConfig.new(0,0,sub_event))

	var et = EventThread.new()
	et.trigger_event(sub_start,_ent,{})
	et.on_complete.connect(_sub_event_execute_complete.bind(et))
	return 

## 当子线程结束时
func _sub_event_execute_complete(_et:EventThread):
	print("子线程处理完毕")
	pass
