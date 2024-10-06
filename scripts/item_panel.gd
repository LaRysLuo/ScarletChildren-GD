extends Control

@onready var itemList = [
	{
		"itemName":"道具A",
		"desc":"你好呀，这是道具A"
	},
	{
		"itemName":"道具B",
		"desc":"你好呀，这是道具B"
	},
	{
		"itemName":"道具C",
		"desc":"你不好吗？这是道具C"
	},
	{
		"itemName":"道具D",
		"desc":"你不好吗？这是道具D"
	}
]

@onready var helpBox = $Panel/Label2
@onready var grid:GridContainer = $Panel/GridContainer
@onready var prefab:PackedScene = ResourceLoader.load("res://scenes/button.tscn")


var index:int = 0 :
	set(new):
		last = index
		index = new
		print("当前的index是",index)
var last:int = -1
var btnlist = [] #按钮列表

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("item_panel运行了")
	refresh()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func refresh():
	for item in itemList:
		var btn = prefab.instantiate()
		grid.add_child(btn)
		btn.name = item.itemName
		btn.text = item.itemName
		btn.connect("lb_focus_entered",func():
			helpBox.text = item.desc
		)
		btn.connect("lb_select_changed",on_select)
	var item:LButton = grid.get_child(0)
	item.focus()
	print("item:",item)

# 玩家按下选择后
func on_select(event:int):
	var list :Array[Node] = grid.get_children()
	print("list的数量：",list.size())
	var num:int = grid.columns
	match  event:
		0: 
			#向下移动光标
			if num > 0 && index + num < list.size() -1: index += num
		1:
			# 向左移动
			if index > 0: index-=1
		2:
			#往右向横行移动 0%2  < 2
			if index < list.size() -1: index+=1
		3:
			#向上移动	光标
			if num > 0 && index - num >= 0: index -=num		
	update_btn()

func update_btn():
	var list :Array[Node] = grid.get_children()
	if last > -1 : 
		var last_btn = list[last] as LButton
		last_btn.unfocus()
	var btn = list[index] as LButton
	btn.focus()
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("cancel"): 
		get_window().set_input_as_handled()
		SceneManager.backto()
		
		
