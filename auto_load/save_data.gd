extends Resource
class_name SaveData

## 当前场景
@export var current_map:String 

## 当前位置
@export var current_pos:Vector2i

@export var game_time:int

@export var items:Array[Item]

func save_player(current_map:String,current_pos:Vector2i,game_time:int,items:Array[Item]):
	self.current_map = current_map
	self.current_pos = current_pos
	self.game_time = game_time
	self.items = items
	return self
