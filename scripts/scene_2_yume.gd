extends Control


func _ready() -> void:
	DialogueManager.show_message("礼诗…")
	DialogueManager.show_message("唔...")
	DialogueManager.show_message("礼诗。")
	DialogueManager.show_message("唔...")
	DialogueManager.show_message("礼诗!")
	DialogueManager.show_message("谁在叫我，让我再睡一会。")
	DialogueManager.show_message("礼诗，快醒醒，来我这里。")
	await DialogueManager.dialogue_finish
	
	# 载入到1号房间
	SceneManager.goto("maps/1号房间")
	
	
