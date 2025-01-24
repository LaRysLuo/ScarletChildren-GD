extends Node2D

# 初始化玩家位置
func _ready() -> void:
	var node = find_player_start_pos()
	if node && !GameManager.player:
		GameManager.instance_player(node.get_parent(),node.global_position)
	# 清除当前的玩家初始化标识
	queue_free()
	
# 判断是否存在玩家初始标记
func find_player_start_pos() -> Node2D:
	var playersign = get_tree().get_nodes_in_group("player_sign")
	if !playersign: return null # 没找到玩家初始化标识返回
	if playersign.size() > 1: print_debug("错误的开始点数量，开始点不能超过1个")
	return playersign[0] as Node2D
