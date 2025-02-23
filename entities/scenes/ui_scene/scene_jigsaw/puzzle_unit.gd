extends Control
class_name PuzzleUnit

## 解谜单元

# 引用组件
var texture_rect:TextureRect:
	get():return get_node("TextureRect2")
	
var color_rect:ColorRect:
	get():return get_node("ColorRect")

# 是否可移动的
var movable:bool:
	get():return texture_rect.texture != null

var tween:Tween


## 设置信息
func set_info(tex:Texture2D):
	texture_rect.texture = tex
	unfocus()

signal move_finished

## 移动碎片
func move(target:PuzzleUnit):
	tween = get_tree().create_tween()
	# 设置 Tween 动画
	tween.tween_property(self, "position", target.position, 0.3)  # 0.5 秒内移动到目标位置
	
	# 可选：设置动画的缓动效果
	tween.set_ease(Tween.EASE_IN_OUT)  # 缓入缓出效果
	tween.set_trans(Tween.TRANS_QUAD)  # 使用二次方过渡
	# 可选：在动画完成后执行某些操作
	tween.tween_callback(func(): 
		move_finished.emit()
		print("移动完成！")
	)
	return self


## 聚焦
func focus():
	color_rect.show()
	
## 失焦
func unfocus():
	color_rect.hide()
