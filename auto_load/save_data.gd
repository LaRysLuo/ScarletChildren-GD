extends Resource
class_name SaveData

## 当前场景
@export var current_map:String
@export var current_pos:Vector2i
@export var map_name:String

@export var game_time:int

@export var create_time:String

@export var slot_id:int


func _init(_current_map:String = "",_map_name:String = "",_current_pos:Vector2i = Vector2i.ZERO,_game_time:int = 0,_create_time:String = "",_slot_id:int = 0) -> void:
	self.current_map = _current_map
	self.map_name = _map_name
	self.current_pos = _current_pos
	self.game_time = _game_time
	self.create_time = _create_time
	self.slot_id = _slot_id



