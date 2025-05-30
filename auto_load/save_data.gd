extends Resource
class_name SaveData

## 当前场景
@export var current_map:String 

## 当前位置
@export var current_pos:Vector2i

@export var game_time:int

@export var items:Array[Item]

func save_player(_current_map:String,_current_pos:Vector2i,_game_time:int,_items:Array[Item]):
	self.current_map = _current_map
	self.current_pos = _current_pos
	self.game_time = _game_time
	self.items = _items
	return self
