extends CanvasLayer

#引用
@export var stamina_bar:StaminaBar:
	get(): return get_node("ComponetStaminaBar")

func _ready() -> void:
	# 等待玩家角色实例载入
	if !GameManager.player:
		await GameManager.on_player_loaded
	if !GameManager.is_normal_state:
		await GameManager.on_event_trigger_end
	_init_stamina_bar()
	
func _exit_tree() -> void:
	GameManager.player.on_stamina_changed.disconnect(stamina_bar.refresh)
	
func _init_stamina_bar():
	# 连接信号
	print("初始化UI")
	GameManager.player.on_stamina_changed.connect(stamina_bar.refresh)
	#stamina_bar.hide()
