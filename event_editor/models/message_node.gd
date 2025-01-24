extends BaseEventNode 
class_name MessageNode

@export var text:String ## 信息文本
@export var role:Role ## 角色数据
@export var type:int ## 对话类型
@export var wait_time:int ## 等待时间（毫秒），只有当type为1才有效。

var result = -1 ## 分支节点

func  _init(cmd:int = 0,pos:Vector2 = Vector2.ZERO,text:String ="",role:Role = null,type:int = 0,wait_time:int = 0) -> void:
	self.node_type = cmd
	self.pos = pos
	self.text = text
	self.role = role
	self.type = type
	self.wait_time = wait_time

## 重写下一步:当result有参数时，返回思考回调
func next(index:int = 0) -> BaseEventNode:
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
			print("rrrr=",r)
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
func _execute(event):
	#print("开始显示信息，新逻辑执行成功，完美！")
	result = -1
	var keywords = _get_keyword()
	DialogueManager.show_message(text,type,wait_time,role)
	DialogueManager.set_keyword(keywords)
	print("result11=",result)
	result = await  DialogueManager.dialogue_finish
	print("result22=",result)
	print("信息显示完成")
