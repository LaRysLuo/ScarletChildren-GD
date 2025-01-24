extends BaseEventNode
class_name FadeinData

func _execute(ent):
	print("淡入画面")
	await  GameManager.fadein()
