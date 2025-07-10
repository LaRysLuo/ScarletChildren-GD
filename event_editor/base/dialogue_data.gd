extends Resource
class_name DialogueData


@export var text_id:String ## 文本键
@export var expression_id:int = 0 ## 表情id



func _init(_text_id:String = "",_expression_id:int = 0) -> void:
    self.text_id = _text_id
    self.expression_id = _expression_id