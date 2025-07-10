extends BaseEventNode 
class_name MessageNode

@export var text:String ## 信息文本
@export var role:Role ## 角色数据
@export var type:int ## 等待类型
@export var wait_time:int ## 等待时间（毫秒），只有当type为1才有效。
@export var expression_id:int = 0 ## 表情id
@export var position_type:int = 2 ## 位置类型

@export var dialogue_list:Array[DialogueData] ## 对话数据列表

var result = -1 ## 分支节点

func  _init(_cmd:int = 0,_pos:Vector2 = Vector2.ZERO,_text:String ="",_role:Role = null,_type:int = 0,_wait_time:int = 0,_expression_id:int = 0,_position_type:int = 2,_dialogue_list:Array[DialogueData] = []) -> void:
	self.node_type = _cmd
	self.pos = _pos
	self.text = _text
	self.role = _role
	self.type = _type
	self.wait_time = _wait_time
	self.expression_id = _expression_id
	self.position_type = _position_type
	self.dialogue_list = _dialogue_list

## 重写下一步:当result有参数时，返回思考回调
func next(_index:int = 0) -> BaseEventNode:
	if typeof(result) == TYPE_INT && result == -1:
		return super.next()
	if typeof(result) == TYPE_DICTIONARY && result.type == 1:
		print("call=",_get_keyword().size())
		return _get_keyword()[result.key_index].get_call()
	if typeof(result) == TYPE_DICTIONARY && result.type == 2:
		var matched = result.matched
		print("匹配结果：",matched)
		## 如果匹配到的话
		if matched: 
			print("匹配到了哟")
			return _get_keyword()[result.key_index].get_item_link().get_call()
		else:	
			print("没有匹配到了哟")
			var r = _get_keyword()[result.key_index].get_none_matched()
			return r
	return super.next()

## 获得关键词
func _get_keyword() -> Array[KeywordData]:
	const from_port_index = 1
	var filters = children.filter(func(item:ChildrenNodeConfig):return item.from_port_index == 1)
	if filters.is_empty():return []
	var keywords:Array[KeywordData]
	for config:ChildrenNodeConfig in filters:
		if config.child is KeywordData:
			keywords.append(config.child)
	#var keywords = filters.map(func(item:ChildrenNodeConfig): return item.child)
	return keywords

## 重写父类虚方法
func _execute(_event,_args):
	#print("开始显示信息，新逻辑执行成功，完美！")
	result = -1
	## 新逻辑：目前还没兼容思考节点相关内容
	if !dialogue_list.is_empty():
		print("dialogue_list的尺寸:",dialogue_list.size())
		DialogueManager.show_message_array(dialogue_list,type,wait_time,role,position_type)
	else:
		var keywords = _get_keyword()
		DialogueManager.show_message(text,type,wait_time,role,expression_id,position_type)
		DialogueManager.set_keyword(keywords)
	## 如果后续节点是optionNode,则直接不等待完成，直接显示下一个节点
	if _get_next_option():
		await DialogueManager.dialogue_typing_finish
		return 
	result = await  DialogueManager.dialogue_finish
	print("[MessageData]信息显示完成")

## 判断下一个节点是否是选项节点
func _get_next_option() -> bool:
	if next(0) is OptionData:
		print("[MessageData]下一个节点是选项节点")
		return true
	return false
