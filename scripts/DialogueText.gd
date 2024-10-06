extends Object
class_name DialogueInfo

var character_name:String #人物名字
var dialogue_text:String #对话文本

func _init(char_name:String,dialogue_text:String) -> void:
	self.character_name = char_name
	self.dialogue_text = dialogue_text
