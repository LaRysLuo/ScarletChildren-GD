extends CanvasLayer
class_name SceneJigsaw

## 信号
signal on_finish # 场景结束了，取消或者完成拼图都会触发 
signal on_succuss  # 只有成功会触发

## 引用组件
var grid:GridContainer:
	get():return get_node("HBoxContainer/GridContainer")

var move_count_label:Label:
	get():return get_node("MarginContainer/Label")

var key_tips:KeyTipsBottom:
	get():return get_node("MarginContainer/HBoxContainer/KeyTipsBottom")


## 属性
var puzzle_units:Array[PuzzleUnit]

var puzzle_texs = [
	preload("res://scenes/ui_scene/scene_jigsaw/assets/star_fish/1.png"),
	preload("res://scenes/ui_scene/scene_jigsaw/assets/star_fish/2.png"),
	preload("res://scenes/ui_scene/scene_jigsaw/assets/star_fish/3.png"),
	preload("res://scenes/ui_scene/scene_jigsaw/assets/star_fish/4.png"),
	preload("res://scenes/ui_scene/scene_jigsaw/assets/star_fish/5.png"),
	preload("res://scenes/ui_scene/scene_jigsaw/assets/star_fish/6.png"),
	preload("res://scenes/ui_scene/scene_jigsaw/assets/star_fish/7.png"),
	preload("res://scenes/ui_scene/scene_jigsaw/assets/star_fish/8.png")
]

var dirs = [
	Vector2i.DOWN,
	Vector2i.LEFT,
	Vector2i.RIGHT,
	Vector2i.UP
]

#var random_index_gp = ["0", "2", "1", "6", "4", "5", "3", "7", "-1"]
var random_index_gp = ["0","1","2","3","4","5","6","-1","7"]
var finish_index_gp = ["0","1","2","3","4","5","6","7","-1"]


var is_complete:bool = false

var last_index:int = -1
var select_index:int = 0:
	set(val):
		last_index = select_index
		select_index = val
		focus(select_index)

var is_buszing:bool = false

var move_count:int = 0:
	set(val):
		move_count = val
		_refresh_move_count()


func _ready() -> void:
	call_deferred("_init_all")

## 初始化图案
func _init_all():
	_refresh_children()
		
	var index = 0
	for unit:PuzzleUnit in puzzle_units:
		if index < puzzle_texs.size():	
			var tex = puzzle_texs[index]
			if !tex: return
			unit.name = str(index)
			unit.set_info(tex)
			index += 1
		else: 
			unit.name = "-1"
			break
	if !is_complete: 
		_random_piece()
	else:
		key_tips.disable_key(KeyTipsBottom.keyType.key_a)
	# 聚焦第一个元素
	focus(0)

## 刷新拼图块
func _refresh_children():
	puzzle_units.clear()
	# 获取所有的Unit
	for child in grid.get_children():
		puzzle_units.append(child)

## 刷新移动步数
func _refresh_move_count():
	move_count_label.text = "移动步数：%s" % move_count
	
## 【对外调用】 设置谜题为已完成
func set_complete():
	self.is_complete = true
	
## 打乱碎片
func _random_piece():
	var index = 0
	for child_name in random_index_gp:
		var unit = _find_piece_by_name(child_name)
		if !unit:
			print("出错了！！！！！",child_name)
			return
		grid.move_child(unit,index)
		index += 1
	_refresh_children()
	
func _find_piece_by_name(name:StringName) -> PuzzleUnit:
	for unit in puzzle_units:
		if unit.name == name: 
			return unit
	return null
	
## 聚焦
func focus(index:int):
	AudioManager.play_cursor_move()
	if last_index >=0: puzzle_units[last_index].unfocus()
	puzzle_units[index].focus()
	pass

func _input(event: InputEvent) -> void:
	if is_buszing: return
	if event.is_action_pressed("down") && _cursor_down_enable() : _cursor_down()
	if event.is_action_pressed("left") && _cursor_left_enable() : _cursor_left()
	if event.is_action_pressed("right")  && _cursor_right_enable() : _cursor_right()
	if event.is_action_pressed("up") && _cursor_up_enable() : _cursor_up()
	if event.is_action_pressed("submit"):_move()
	if event.is_action_pressed("cancel"):_back()
	
## 判断是否可移动的
func movable(index:int) -> bool:
	var unit = puzzle_units[index]
	if unit: return unit.movable
	return false
	
func _cursor_down_enable() -> bool:
	return (select_index + grid.columns) < puzzle_units.size()
	
func _cursor_left_enable() -> bool:
	return select_index % grid.columns >= 1
	
func _cursor_right_enable() -> bool:
	return select_index % grid.columns < grid.columns -1

func _cursor_up_enable() -> bool:
	return (select_index - grid.columns) >= 0
	
## 光标下移
func _cursor_down():
	if movable(select_index  + grid.columns):
		select_index += grid.columns

## 光标左移
func _cursor_left():
	if movable(select_index  - 1):
		select_index -= 1
	
## 光标右移
func _cursor_right():
	if movable(select_index  + 1):
		select_index += 1

## 光标上移
func _cursor_up():
	if movable(select_index  - grid.columns):
		select_index  -= grid.columns

## 移动拼图
func _move():
	if is_complete: return
	var block = _find_empty()
	# 没有找到空位，不能移动
	if !block:
		AudioManager.play_buzzle()
		return
	var piece:PuzzleUnit = _find_piece()
	var piece_index = piece.get_index()
	var block_index = block.get_index()
	#var tar_pos = piece.position
	self.is_buszing = true
	piece.move(block)
	await  piece.move_finished
	
	grid.move_child(piece,block_index)
	grid.move_child(block,piece_index)
	_refresh_children()
	self.select_index = block_index
	self.move_count +=1
	await  get_tree().create_timer(0.3).timeout
	# 检查是否结束
	if _check_finish():
		AudioManager.play_puzzle_complete()
		on_succuss.emit()
		await  get_tree().create_timer(0.5).timeout
		_back()
		#on_finish.emit()
		return
	self.is_buszing = false
	
## 返回上一层
func _back():
	SceneManager.backall()
	on_finish.emit()

## 找到拼图碎片
func _find_piece() -> PuzzleUnit:
	var unit:PuzzleUnit = puzzle_units[select_index]
	return unit
	
## 从四个方向寻找空位置
func _find_empty() -> PuzzleUnit:
	var dir_index_list = [] 
	if _cursor_down_enable():
		dir_index_list.append(select_index  + grid.columns)
	if _cursor_left_enable():
		dir_index_list.append(select_index - 1)
	if _cursor_right_enable():
		dir_index_list.append(select_index + 1)
	if _cursor_up_enable():
		dir_index_list.append(select_index  - grid.columns)
	for dir_index in dir_index_list:
		if dir_index >= puzzle_units.size(): continue
		var unit:PuzzleUnit = puzzle_units[dir_index]
		if !unit.movable:
			return unit
	return null

## 检查拼图是否完成
func _check_finish() -> bool:
	var index:int = 0
	for child:String in finish_index_gp:
		var unit = puzzle_units[index]
		if !unit: 
			return false
		if unit.name != child:
			return false
		index+=1
	print("拼图已完成")
	return true
