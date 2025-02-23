extends Node
class_name GameScreen

@onready var effect:ScreenEffect = $ScreenEffect


## 画面淡入
func fadein(time:float = 0.35):
	effect.fadein(time)
	await effect.fade_finished


## 画面淡出
func fadeout(time:float,color:Color = effect.BLACK):
	effect.set_color(color,true,time)
	await effect.fade_finished
