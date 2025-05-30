extends Object
class_name DialogueInfo

const Pressed = 0
const Auto = 1

var role:Role #人物名字
var role_expression_id:int # 角色表情id
var dialogue_text:String #对话文本
var wait_type:int # 等待类型
var wait_time:float # 等待时间

func _init(role:Role,role_expression_id:int,dialogue_text:String,wait_type:int = Pressed,wait_time:float = 0) -> void:
	self.role = role
	self.role_expression_id = role_expression_id
	self.dialogue_text = dialogue_text
	self.wait_type = wait_type
	self.wait_time = wait_time
