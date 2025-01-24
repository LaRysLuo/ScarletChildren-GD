## 可选择的菜单
@tool
extends Control
class_name OptionMenu

@export var selected:int = -1



@export var option_list:Array[Dictionary]

@onready var parent:Control = $VBoxContainer

var children:Array[Node]:
	get(): return parent.get_children().filter(func(item):return item is LButton)


## 选项预制体
const OPTION_ITEM_PRE = preload("res://scenes/l_button.tscn")

signal on_select_changed(index:int)

#func _ready() -> void:
	#self.visibility_changed.connect(_on_disabled)
	#pass

func enable():
	if !option_list:
		print_debug("option_list为空，无法渲染")
		return
	for item in option_list:
		var option_item = OPTION_ITEM_PRE.instantiate() as LButton
		option_item.text = tr(item["display_name"]) 
		option_item.lb_select_changed.connect(on_select)
		option_item.lb_submit.connect(on_submit)
		parent.add_child(option_item)
	select(0)

func disable():
	for p:LButton in children:
		p.lb_select_changed.disconnect(on_select)
		p.lb_submit.disconnect(on_submit)
		parent.remove_child(p)
		p.queue_free()
	option_list.clear()
	selected = -1

## 选择结果
func select(index:int):
	print("children:",children.size())
	var btn = children[index] as LButton if index >= 0 and index < children.size() else null  # children[index] as LButton
	var last = children[selected] as LButton if selected >= 0 and selected < children.size() else null
	if btn: btn.focus()
	if last:last.unfocus()
	on_select_changed.emit(index)
	selected = index

## 【C】当选择变化时
func on_select(event:int):
	if !visible: return ## 隐藏时返回
	match  event:
		3: if selected > 0: select(selected - 1)  # 向下移动
		0: if selected < children.size() -1: select(selected + 1) # 向上移动

## 输入确定
func on_submit():
	if !visible: return ## 隐藏时返回
	var opt:Dictionary = option_list[selected]
	var callback:Callable = opt["callback"]
	if callback: callback.call()

## 在option_list添加元素
func add_option(display_name:String,callback:Callable ):
	option_list.append(
		{
			"display_name":display_name,
			"callback":callback
		}
	)
	return self
