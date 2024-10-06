extends Node2D
class_name GamePlay

enum GameState {
	Normal, #正在运行
	Buszing, #忙碌的
}

var game_state = GameState.Normal 
var player_pre:Resource
var player:Player_v1

var is_normal_state:
	get(): return game_state == GameState.Normal

func set_game_state_buszing():
	game_state = GameState.Buszing

func set_game_state_normal():
	game_state = GameState.Normal

# 记录游戏的状态
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player_pre = preload("res://character/player.tscn")
	#SceneManager.need_instance_player.connect(_instance_player)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# 创建玩家
func instance_player(map,vec:Vector2):
	if player: print_debug("初始化玩家错误，当前已生成玩家，请确认整个游戏玩家标识是否只有1个")
	if !player_pre: print_debug("初始化玩家失败，未设置玩家场景的路径")
	player = player_pre.instantiate() 
	player.position = vec
	map.add_child(player)
