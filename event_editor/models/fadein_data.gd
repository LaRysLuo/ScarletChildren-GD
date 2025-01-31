extends BaseEventNode
class_name FadeinData

func _execute(ent,agrs):
	print("淡入画面")
	await  GameManager.fadein()
