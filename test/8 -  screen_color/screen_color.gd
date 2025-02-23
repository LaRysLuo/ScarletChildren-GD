## 特效管理器

extends CanvasLayer
class_name ScreenColor


## 特效资源的引用
var color_screen:PackedScene = preload("res://component/color_rect/color_rect_full.tscn")


var color_screen_instance:ColorScreen

## 设置屏幕颜色
## ColorScreen.Black
# set_screen_color(ColorScreen.Black)
func set_screen_color(color:Color):
	if color_screen_instance: clear_screen()
	color_screen_instance = color_screen.instantiate()
	if color_screen_instance is ColorScreen:
		color_screen.set_color(color)
	add_child(color_screen_instance)

## 清除屏幕
func clear_screen():
	color_screen_instance.clear()
	color_screen_instance = null

## 淡出黑色
func fadeout_black(time:float = 1):
	if color_screen_instance: clear_screen()
	color_screen_instance = color_screen.instantiate()
	add_child(color_screen_instance)
	if color_screen_instance is ColorScreen:
		color_screen_instance.set_color(ColorScreen.BLACK,true,time)
	await color_screen_instance.fade_finished

## 淡入画面
func fadein(time:float = 1):
	if color_screen_instance:
		await color_screen_instance.fadein(time)
		color_screen_instance = null