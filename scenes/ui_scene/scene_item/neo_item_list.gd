extends CanvasLayer
class_name NeoItemList


## 引用
@onready var catagory_bar:CatagoryTabBar = $PanelContainer/MarginContainer/VBoxContainer/CatagoryBar/VBoxContainer/CatagoryTabBar
@onready var item_list:ItemListEx = $PanelContainer/MarginContainer/VBoxContainer/ItemList
@onready var item_help_label:ItemHelpLabel = $PanelContainer/MarginContainer/VBoxContainer/ItemList/VBoxContainer/ItemHelpLabel
@onready var key_tips:KeyTipsBottom = $PanelContainer/MarginContainer/VBoxContainer/KeyTipsBottom

## 属性
# 包裹物品种类
var catagory_group = [
	{
		"type_name":"道具",
		"key":1
	},
	{
		"type_name":"线索",
		"key":2
	},
	{
		"type_name":"资料",
		"key":3
	}
]

## 当前选中的物品分类
var catagory_index:int

## 选择器模式
var picker_mode:bool = false

## 选择器模式 - 选择完成时
var picker_complete:Callable
var picker_cancel:Callable

## data_player
var data_player:DataPlayer:
	get(): return GameManager.data_player

## 获得道具列表
func get_items(index:int) -> Array[Item]:
	var key = catagory_group[index].key
	if !key: return []
	return data_player.get_shown_items.filter(func(item:Item):return item.item_catagory == key)


func _ready() -> void:
	catagory_bar.set_info(catagory_group)
	catagory_bar.on_cancel.connect(_scene_close)
	catagory_bar.on_changed.connect(_on_catagory_changed)
	catagory_bar.on_submit.connect(_on_catagory_confirm)
	catagory_bar.on_active.connect(func():
			key_tips.set_btns_info({
				"a_btn": KeyTipsConfig.new("确认"),
				"b_btn": KeyTipsConfig.new("返回"),
				"x_btn": KeyTipsConfig.new("",false),
				"y_btn": KeyTipsConfig.new("",false),
			})
	)
	
	item_list.on_changed.connect(_on_item_changed)	
	item_list.on_cancel.connect(_on_item_list_cancel)
	item_list.on_submit.connect(_use_item)


	catagory_bar.active()

## 开始选择器模式
func start_picker_mode(on_complate:Callable,on_cancal:Callable):
	self.picker_complete = on_complate
	self.picker_cancel = on_cancal
	self.picker_mode = true
	

## 关闭当前场景
func _scene_close():
	SceneManager.backto()
	if picker_mode: picker_cancel.call()
	pass

func _use_item(item:Item):
	## 选择器模式
	if picker_mode: 
		await  SceneManager.backall()
		picker_complete.call(item)
	## 正常模式
	else: 
		if !item_list.usable(item):
			AudioManager.play_se("blip03")
			return
		var event_res = data_player.get_use_callback(item)
		## 1.关掉道具窗口
		await  SceneManager.backall()
		## 2.触发物品效果
		print("触发物品效果")
		await  GameManager.trigger_event_res(event_res)

## INFO 信号函数 当标签页变化时，刷新itemList
func _on_catagory_changed(index:int):
	var list:Array[Item] = get_items(index)
	item_list.set_info(list,data_player)

## INFO 信号函数
func _on_catagory_confirm(index:int):
	if get_items(index).is_empty():
		AudioManager.play_buzzle()
		return
	self.catagory_index = index
	catagory_bar.deactive()
	item_list.active()
	key_tips.set_btns_info({
		"a_btn": KeyTipsConfig.new("使用"),
		"b_btn": KeyTipsConfig.new("返回"),
		"x_btn": KeyTipsConfig.new("组合"),
		"y_btn": KeyTipsConfig.new("",false),
	})

## INFO 信号函数 当道具有变化时，更新help_bar
func _on_item_changed(index:int):
	if index == -1:
		print("选择取消了")
		item_help_label.set_info("")
		return
	var items = get_items(catagory_index)
	var item = items[index]
	print("选择有变化",item.item_name)
	if item && item is Item:
		item_help_label.set_info(item.item_desc)
		
## INFO 信号函数
func _on_item_list_cancel():
	item_list.deactive()
	catagory_bar.active()
