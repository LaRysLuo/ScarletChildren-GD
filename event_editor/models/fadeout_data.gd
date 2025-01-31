extends BaseEventNode
class_name FadeoutData

func _execute(ent,args):
	print("淡出画面")
	#GameManager.set_screen_color(ColorScreen.BLACK)
	await  GameManager.fadeout_black()
	#await SceneManager.fadeout()
