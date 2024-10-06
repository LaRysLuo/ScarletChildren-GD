extends Area2D
class_name Interactable

signal on_interact # 订阅触发的事件

func _init()->void:
	collision_layer =0
	collision_mask = 0
	set_collision_mask_value(2,true)
	
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	

func interact() -> void:
	print("触发了哦")
	DialogueManager.show_message("大门紧闭，出不去了")
	on_interact.emit()
	pass
	
	
func _on_body_entered(player:Player) -> void:
	player.interactableNode = self
	pass
	
func _on_body_exited(player:Player) -> void:
	player.interactableNode = null
	pass	
