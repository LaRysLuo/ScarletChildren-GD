extends "res://scripts/game_object.gd"
class_name Event

# 触发方式
enum TriggerType {
	None无,
	Interact交互,
	Touch触碰
}

var condition = "" #触发条件
@export var event_name = "" #事件名
@export var is_collsion:bool = false # 是否为障碍物,表示该事件是否可穿透
@export var trigger_type:TriggerType = TriggerType.None无 # 触发方式
@export var event_code_group:EventCodeGroup #事件语句集

signal  event_finish # 事件交互结束

#var code_list:Array[EventCode] = [
	#EventCode.new(EventCode.CodeName.MESSAGE,"你好呀"),
	#EventCode.new(EventCode.CodeName.MESSAGE,"你是什么人")
#]

# 不可穿透 并且Touch就会触发的类型 -> 各种无图像的门，用于场景传送
# 不可穿透 并且只有交互后才会触发的类型 -> 各种NPC人物，可进行对话

# 交互
func interact():
	print_rich("[color=red]事件触发了，将要执行的语句有%s个[/color]" % event_code_group.list.size() )
	for code in event_code_group.list:
		print_rich("[color=red]开始执行名为%s的event语句[/color]" % code.code_name)
		match code.code_name:
			EventCode.CodeName.MESSAGE:	 await show_message(code.args)
			EventCode.CodeName.TELEPORT: await teleport(code.args)
			EventCode.CodeName.MOVEDOWN: await character_move(code.args,Vector2i.DOWN)
			EventCode.CodeName.MOVELEFT: await character_move(code.args,Vector2i.LEFT)
			EventCode.CodeName.MOVERIGHT: await character_move(code.args,Vector2i.RIGHT)
			EventCode.CodeName.MOVEUP: await character_move(code.args,Vector2i.UP)
			EventCode.CodeName.MOVEFORWARD: await character_move(code.args,0)
			EventCode.CodeName.FACEDOWN: await face_dir(code.args,Vector2i.DOWN)
			EventCode.CodeName.FACELEFT: await face_dir(code.args,Vector2i.LEFT)
			EventCode.CodeName.FACERIGHT: await face_dir(code.args,Vector2i.RIGHT)
			EventCode.CodeName.FACEUP: await face_dir(code.args,Vector2i.UP)
			EventCode.CodeName.FADEOUT:await fadeout()
			EventCode.CodeName.FADEIN:await fadein()
			EventCode.CodeName.WAIT: await wait(code.args)
		print_rich("[color=red]%s语句执行完毕[/color]" % str(code.code_name))
	print_rich("[color=red]event事件全部执行完毕[/color]")
	#清除该节点
	if !self.map: queue_free()
	else: self.map.add_child(self) # TODO 这里可能会有问题
	event_finish.emit()

# 显示信息框
func show_message(args:String):
	var arglist =  args.split(',') # 使用逗号分隔数组
	if arglist.is_empty(): 
		print_debug("参数为空，MESSAGE语句必须要传入一个参数")
		return
	var message_text = arglist[0]
	if !(message_text is String):
		print_debug("参数错误，MESSAGE语句必须是String")
		return	 
	DialogueManager.show_message(message_text)
	await  DialogueManager.dialogue_finish 
	print("信息显示完成")



func _get_event_by_name(name:String) -> CharacterBase:
	if name == "this": return self # 如果输入的是this的话，则返回本身
	if name == "player": return GameManager.player as CharacterBase
	var events = get_tree().get_nodes_in_group("events")
	var result = events.filter(func(event:Event):return event.event_name == name)
	return result

# 场景传送： 要传送的场景以及他的场景编号
# 参数1 目标场景的名称
# 参数2 目标事件
# 参数3（可选） 是否要显示淡出淡入
func teleport(args:String):
	var arglist =  args.split(',') # 使用逗号分隔数组
	if arglist.is_empty(): 
		print_debug("参数为空，MESSAGE语句必须要传入一个参数")
		return
	if arglist.size() < 2:
		print_debug("参数错误，场景移动方法必须是两个参数")
		return

	# 场景移动前要把该事件保护起来
	self.get_parent().remove_child(self)
	GameManager.add_child(self)

	var scene_name = arglist[0] #目标场景名称
	var target_event_id = int(arglist[1]) #目标事件名称
	var with_fade:bool = true
	if arglist.size() == 3: with_fade = string_to_bool(arglist[2])
	
	
	SceneManager.move(scene_name,target_event_id,with_fade) #传送到目标场合
	
	await SceneManager.move_finished #等待移动结束

func string_to_bool(str:String):
	if str == "true": return true
	elif str == "false": return false
	print_debug("输入的参数{%s}无法转换" %str)

# 画面淡出
func fadeout():
	print("淡出画面")
	await SceneManager.fadeout()

# 画面淡入
func fadein():
	print("淡入画面")
	await  SceneManager.fadein()

# 等待n秒，参数为等待时间
func wait(args:String):
	var arglist =  args.split(',') # 使用逗号分隔数组
	if arglist.is_empty(): 
		print_debug("参数为空，MESSAGE语句必须要传入一个参数")
		return
	var time_value = int(arglist[0])	
	var timer = get_tree().create_timer(time_value)
	await timer.timeout

# 角色前进一步,共2个参数，
# 参数1是控制的角色，
# 参数2是前进的步数
# 参数3（可选）是否要等待移动完成
func character_move(args:String,type):
	var arglist =  args.split(',') # 使用逗号分隔数组
	if arglist.size() < 2: 
		print_debug("参数为空，MESSAGE语句必须要传至少2个参数")
		return
	# 从当前场景中找到对应角色名的事件	
	var event_name = arglist[0]
	var event = _get_event_by_name(event_name)
	if !event:
		print_debug("输入了不存在的事件名称")
		return
	var count:int = int(arglist[1]) # 将字符串转为整型
	var last_route =  event.find_last_route()
	
	var target =  event.cell_pos #获得当前位置
	if last_route: target = last_route.target
	var move_dir:Vector2i #移动方向
	if type is Vector2i:
		move_dir = type
		print("现在是按方向行走 %s - %d",[type,Vector2i.LEFT])
	elif type == 0: 
		move_dir = event.dir
	elif  type == 1: #前后退
		move_dir = event.dir
	else: 
		print_debug("输入的type参数错误")
		return
	print("当前的面朝方向 %s - %d",[type,Vector2i.LEFT])
	var wait_finish = true
	if arglist.size() ==3 : wait_finish = string_to_bool(arglist[2]) 
	for n in count:
		target = move_dir + target
		event.move_to_by_route(MoveRoute.new(move_dir,target))
	if wait_finish: await event.pos_changed # 等待全部移动完成

# 面朝方向
# 参数1 目标事件
func face_dir(args:String,dir:Vector2i):
	var arglist =  args.split(',') # 使用逗号分隔数组
	if arglist.size() < 1: 
		print_debug("参数错误，MESSAGE语句必须要传至少1个参数")
		return
	# 从当前场景中找到对应角色名的事件	
	var event_name = arglist[0]
	var event = _get_event_by_name(event_name)
	if !event:
		print_debug("输入了不存在的事件名称")
		return
	event.face_to(dir)

func _args_validate(args:String):
	pass
