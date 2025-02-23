@tool ## 必须要加上这个才能在编辑器模式使用
extends Control
class_name EventEditor

## 调试信息显示时长
const MESSAGE_SHOW_TIME = 2.0
var tween:Tween


## 各种组件
@export var save_btn:Button
@export var clear_btn:Button
@export var node_parent:GraphEdit
@export var popup_menu:PopupMenu
@export var popup_menu2:Control
@export var res_name_label:Label
@export var tip_label:Label
@export var add_menu:Control

## 各种资源的预制体
#const START_NODE_RES = preload("res://event_editor/nodes/start/start_node.tscn")
const START_NODE_RES = preload("./nodes/start/start_node.tscn")
const MESSAGE_NODE_RES = preload("res://event_editor/nodes/message_node/message_node.tscn")
const OPTION_NODE_RES = preload("res://event_editor/nodes/option/option_node.tscn")
const CHAR_MOVE_RES = preload("./nodes/character_move/character_move.tscn")
const FADEOUT_RES = preload("./nodes/fadeout/fadeout_node.tscn")
const FADEIN_RES = preload("./nodes/fadein/fadein_node.tscn")
const WAIT_RES = preload("./nodes/wait/wait.tscn")
const TRANSPORT = preload("./nodes/transport/transport_node.tscn")
const SCRIPT_RES = preload("./nodes/script_node/script_node.tscn")
const SUBTHREAD_RES = preload("./nodes/sub_thread/sub_thread_gn.tscn")
const PLAYANIM_RES = preload("./nodes/playanim_node/playanim_node.tscn")
const KEYWORD_RES = preload("res://event_editor/nodes/keyword_node/keyword_node.tscn")
const ITEMLINK_RES = preload("res://event_editor/nodes/itemlink_node/itemlink_node.tscn")
const READING_RES = preload("res://event_editor/nodes/read_ready_node/read_ready.tscn")
const READING_PAGE_RES = preload("res://event_editor/nodes/reading_page_node/reading_page_node.tscn")
const CINEMA_RES = preload("res://event_editor/nodes/cinema_node/cinema_mode.tscn")
const CONDITION_RES = preload("res://event_editor/nodes/condition_node/condition_node.tscn")
#const NODE_RES = preload("res://event_editor/nodes/charactermove_node.tscn")


## INFO 请在这里配置新的菜单按钮，键是菜单的显示名字，值是按钮按下的回调
var MENU_SETTING = [
	{
		## 开始节点
		"id"= BaseEventNode.Start,
		"name" = "开始",
		"callback"= _add_start_node
	},
	{
		## 消息节点
		"id"= BaseEventNode.Message,
		"name" = "显示消息",
		"callback"= _add_message_node
	},
	{
		## 分支节点
		"id"= BaseEventNode.Option,
		"name" = "分支选项",
		"callback"= _add_option_node
	},
	{
		## 移动节点
		"id" = BaseEventNode.CharacterMove,
		"name" = "角色移动",
		"callback" = func(from = null): return _create_node(CHAR_MOVE_RES,from).from_data(from)
	},
	{
		## 画面淡出
		"id" = 	BaseEventNode.Fadeout,
		"name" = "淡出画面",
		"callback" = func(from = null): return _create_node(FADEOUT_RES,from).from_data(from)
	},
	{
		## 画面淡入
		"id" = 	BaseEventNode.Fadein,
		"name" = "淡入画面",
		"callback" = func(from = null): return _create_node(FADEIN_RES,from).from_data(from)
	},
	{
		## 等待
		"id" = 	BaseEventNode.Wait,
		"name" = "等待",
		"callback" = func(from = null): return _create_node(WAIT_RES,from).from_data(from)
	},
	{
		## 场景移动
		"id" = BaseEventNode.Transport,
		"name" = "场景移动",
		"callback" = func(from = null): return _create_node(TRANSPORT,from).from_data(from)
	},
	{
		## 分支线程
		"id" = BaseEventNode.SubThread,
		"name" = "并行分支",
		"callback" = func(from = null): return _create_node(SUBTHREAD_RES,from).from_data(from)
		
	},
	{
		## 运行脚本
		"id" = BaseEventNode.Scripts,
		"name" = "运行脚本",
		"callback" = func(from = null): return _create_node(SCRIPT_RES,from).from_data(from)
	},{
		## 播放事件动画
		"id" = BaseEventNode.PlayEventAnim,
		"name" = "播放事件动画",
		"callback" = func(from = null): return _create_node(PLAYANIM_RES,from).from_data(from)
	},{
		"id" = BaseEventNode.Keyword,
		"name" = "思考关键词",
		"callback" = func(from = null): return _create_node(KEYWORD_RES,from).from_data(from)
	},{
		"id" = BaseEventNode.Itemlink,
		"name" = "物品联想",
		"callback" = func(from = null): return _create_node(ITEMLINK_RES,from).from_data(from)
	},{
		"id" = BaseEventNode.Reading,
		"name" = "启动阅读模式",
		"callback" = func(from = null): return _create_node(READING_RES,from).from_data(from)
	},{
		"id" = BaseEventNode.ReadingPage,
		"name" = "阅读Ex-页面",
		"callback" =  func(from = null): return _create_node(READING_PAGE_RES,from).from_data(from)
	},{
		"id" = BaseEventNode.CinemaMode,
		"name" = "启动剧场模式",
		"callback" = func(from = null): return _create_node(CINEMA_RES,from).from_data(from)
	},{
		"id" = BaseEventNode.ConditionNode,
		"name" = "条件判断",
		"callback" = func(from = null): return _create_node(CONDITION_RES,from).from_data(from)
	},
]

var nodeMap = {}

## 菜单父节点
var menu_parent:Control:
	get(): return get_node("Box/VBoxContainer/Line2")

## 是否需要保存的标记
var need_save:bool = false:
	set(new):
		need_save = new
		save_btn.disabled = !(need_save && current_resource)

## 当前选中的资源
var current_resource:EventsRes:
	set(new):
		current_resource = new
		var res_name : = "无"
		if current_resource: res_name = current_resource.title
		res_name_label.text = "当前文件： " + res_name
		_load()
		

## 用于生成新节点的位置偏移BaseEventNode
var origin:Vector2 = Vector2(-950,-500)
var offset:Vector2 = Vector2(50,50)

## 获得节点数量
var get_node_count:
	get: return node_parent.get_child_count()

## 节点初始化
func _enter_tree() -> void:
	## 初始化菜单按钮
	_init_menu_btns()
	
	node_parent.connection_request.connect(_on_connection_request)
	node_parent.gui_input.connect(_on_gui_input)
	node_parent.delete_nodes_request.connect(_delete_node)
	node_parent.connection_to_empty.connect(_quick_copy_node)
	node_parent.duplicate_nodes_request.connect(_copy_selected_node_x)
	node_parent.node_selected.connect(_node_selected)
	node_parent.node_deselected.connect(_node_unselected)
	node_parent.disconnection_request.connect(disconnect_lines)
	node_parent.popup_request.connect(show_menu)
	
	save_btn.button_up.connect(_save)
	clear_btn.button_up.connect(_clear)
	save_btn.disabled = true
	clear_btn.disabled = true
	
	_set_menu_activate(false)

	_init_popup_menu()
	_init_history()
	
	_loaded_editor_translation()
	#add_menu.hide()

func _exit_tree() -> void:
	node_parent.delete_nodes_request.disconnect(_delete_node)
	node_parent.connection_to_empty.disconnect(_quick_copy_node)
	node_parent.duplicate_nodes_request.disconnect(_copy_selected_node_x)
	node_parent.node_selected.disconnect(_node_selected)
	node_parent.node_deselected.disconnect(_node_unselected)
	node_parent.disconnection_request.disconnect(disconnect_lines)
	
	node_parent.popup_request.disconnect(show_menu)
	
	## 处理菜单按钮
	#for btn:Button in menu_list:
		#match btn.name:
			#"Start":btn.button_down.disconnect(_add_start_node)
			#"Message":btn.button_up.disconnect(_add_message_node)
			#"Option":btn.button_down.disconnect(_add_option_node)

func _loaded_editor_translation():
	#var file = FileAccess.open("res://localization/local utf-8.zh.translation", FileAccess.READ)
	var translation = ResourceLoader.load("res://localization/local utf-8.zh_CN.translation") as Translation
	if translation:
		TranslationServer.add_translation(translation)


var selected:Array[Node]
func _node_selected(node:Node):
	selected.append(node)
	print("选择了一个单位，当前单位数%s" % selected.size())

func _node_unselected(node:Node):
	selected.erase(node)
	print("取消选择了一个单位，当前单位数%s" % selected.size())


func _init_history():
	tip_label.hide()

## 初始化生成菜单按钮，如果需要加新的节点按钮请去MENU_LIST_DATA变量配置
func _init_menu_btns():
	## 根据数据生成按钮
	for config in MENU_SETTING:
		var btn:Button = Button.new()
		btn.text = config["name"]
		menu_parent.add_child(btn)
		## 连接按键被按下的信号
		var callback = config["callback"]
		btn.button_down.connect(callback)

## 改变菜单状态
func _set_menu_activate(b:bool):
	for btn in add_menu.get_children():
		if btn is Button:
			btn.disabled = !b
			
## 显示信息提示
func _show_info(msg:String):
	tip_label.text = msg
	tip_label.show()
	var timer = get_tree().create_timer(MESSAGE_SHOW_TIME)
	timer.timeout.connect(
		func():
			if tween:tween.kill()
			tween = get_tree().create_tween()
			tween.tween_property(tip_label,"modulate:a",0,0.3)
			tween.finished.connect(_clear_tip_info)
	)
	
## 显示错误
func _show_err(msg:String):
	tip_label.label_settings.font_color = Color.RED
	_show_info(msg)

## 清除提示文本的配置
func _clear_tip_info():
	tip_label.hide()
	tip_label.modulate.a = 1
	tip_label.label_settings.font_color = Color.WHITE

## 初始化右键弹窗
func _init_popup_menu():
	popup_menu2.hide()
	#popup_menu.id_pressed.connect(_on_popup_menu_click)

## 当弹窗窗口被点击
func _on_popup_menu_click(index:int):
	if index == 0:
		print("点击了",index)
		var node = popup_menu.get_item_metadata(1)
		node_parent.remove_child(node)
		node.queue_free()

## 保存资产
func _save():
	## 保存前先做一个备份

	print("保存中")
	if !current_resource: 
		printerr("保存失败，没有选择文件")
		return
	var file_name = current_resource.resource_path.get_file()
	var copy_path = "res://copy/%s" % file_name
	print("备份地址=",copy_path)
	var err:Error  = ResourceSaver.save(current_resource.duplicate(),copy_path)
	if err == Error.OK: print("备份成功")
	else: print("备份失败")
		
	var tree:BaseEventNode =  await _get_node_tree()
	if current_resource is EventsRes:
		print("正在保存")
		current_resource.tree = tree
		var path:String = current_resource.resource_path
		var err2 = ResourceSaver.save(current_resource,path)
	print("保存成功")
	need_save = false

## 载入资产
func _load():
	var res = current_resource as EventsRes
	## 清空所有节点
	node_parent.clear_connections()
	var nodes = node_parent.get_children().filter(func(i):return i is GraphNode)
	if !nodes.is_empty():
		for node:Node in nodes:
			node_parent.remove_child(node)
			node.queue_free()
	_show_err("正在载入…")
	if !res is EventsRes: return
	var tree = current_resource.tree
	print("tree=",tree is BaseEventNode)
	if tree:	await _create_child_graph_node(tree)
	_show_info("载入成功")
	clear_btn.disabled = false
	_set_menu_activate(true)
	#OS.alert("载入成功")
	#pop_node_from(root)

## 清除选择的资产
func _clear():
	current_resource = null
	_set_menu_activate(false)
	pass

## LOAD 根据节点树创建重现节点
func _create_child_graph_node(from:BaseEventNode):
	var result:BaseGN
	var config = _get_menu_config(from.node_type)
	result = config["callback"].call(from)

	if !result:
		printerr("解析节点失败，没有找到result,type为%s" % from.node_type)
		return
	print("正在解析：",result.title)
	## 将视图滚动偏移量定位到开始点的位置
	node_parent.scroll_offset = from.pos - Vector2(0,200)
	
	## 遍历当前节点的所有子类
	if from.children.size() > 0:
		var child_nodes:Array[BaseGN] = []
		for nodeConfig:ChildrenNodeConfig in from.children:
			var child_data:BaseEventNode = nodeConfig.child
			var child:BaseGN = await  _get_child_graph_node(child_data,child_nodes)
			# 判断nodeConfig中的child是否已创建过
			if child: _connect_node(result,nodeConfig,child)
	return result

func _get_child_graph_node(child_data:BaseEventNode,child_nodes:Array[BaseGN]) -> BaseGN:
	var child:BaseGN
	if !child_nodes.is_empty():
		child = _find_node_by_id(child_data.resource_scene_unique_id,child_nodes)
	if !child: 
		child = await _create_child_graph_node(child_data)
		if child: child_nodes.append(child)
	return child

## 用id找出gn
func _find_node_by_id(ori_id:StringName,group:Array[BaseGN]):
	var filters = group.filter(func(item:BaseGN):return item.ori_id == ori_id)
	if filters.is_empty():return null
	return filters.front()

func _connect_node(result,node_config:ChildrenNodeConfig,child:BaseGN):
	var from_name = node_parent.get_path_to(result).get_name(0)
	var to_name = node_parent.get_path_to(child).get_name(0)
	var from_port = node_config.from_port_index
	var to_port = node_config.to_port_index
	node_parent.connect_node(from_name,from_port,to_name,to_port)

## 获得菜单配置
func _get_menu_config(id:int):
	for config in MENU_SETTING:
		if config["id"] == id:
			return config
	return null


## 添加节点Controller
func _add_start_node(from:BaseEventNode = null) :
	if _has_node("开始"): 
		_show_err("添加开始节点失败，因为已经有1个开始节点了")
		return
	var pos:Vector2 
	if from: pos= from.pos ## 看有没有传入数据类型
	else: pos = Vector2.ZERO
	return _create_node(START_NODE_RES,from)

func _add_message_node(from:BaseEventNode = null) -> GraphNode:
	var node:GraphNode = _create_node(MESSAGE_NODE_RES,from)
	if from:
		var msgn = node as MessageGN  ## 获得Message实例
		var from_message_data  = from as MessageNode
		msgn.set_value(from_message_data.text,from_message_data.role,from_message_data.type,from_message_data.wait_time)
	return node

## 添加选项
func _add_option_node(from:BaseEventNode = null) -> GraphNode:
	var node:GraphNode = _create_node(OPTION_NODE_RES,from)
	## 处理数据还原
	if from:
		## 获得GN的数据实例
		var optgn = node as OptionGN
		var from_data = from as OptionData
		optgn.set_value(from_data.options)
	return node
	


#func _add_charactermove_node(from:BaseEventNode = null) -> BaseGN:
	#var node:BaseGN = _create_node(CHAR_MOVE_RES,from)
	#if from:
		#var gn =  node as CharacterMoveGN 
		#var data = from as CharacterMoveData
		#gn.set_value(data.move_type,data.target_char,data.step_count,data.wait_finished)
	#return node

## 创建节点
func _create_node(res:Resource,from:BaseEventNode) -> BaseGN:
	## 有from参数传入是，表示从数据中创建节点
	var pos:Vector2
	if from:pos=from.pos
	## 从零创建节点的情况
	else:pos = Vector2.ZERO
	
	var node:BaseGN =  res.instantiate()
	if from: node.ori_id = from.resource_scene_unique_id
	#var config = _get_menu_config(node.node_type)
	
	node.gui_input.connect(_on_node_click.bind(node))
	if node is MessageGN: node.on_value_changed.connect(_on_changed)
	if pos != Vector2.ZERO:
		node.position_offset = pos
	else:
		node.position_offset = get_local_in_offset()
	node_parent.add_child(node) 

	## 文件被改动
	if pos == Vector2.ZERO: _on_changed()
	return node

func get_local_in_offset():
	var mouse_pos = Vector2(500,200)
	mouse_pos += node_parent.scroll_offset
	mouse_pos /= node_parent.zoom
	return mouse_pos

## 删除节点，可以复数删除
func _delete_node(nodes: Array[StringName]):
	for nodeStr in nodes:
		print("xxx=",nodeStr)
		var node = node_parent.get_node(NodePath(nodeStr))
		print("sss=",node)
		node_parent.remove_child(node)
		node.queue_free()

func _quick_copy_node(from_node: StringName, from_port: int, release_position: Vector2):
	var node = node_parent.get_node(NodePath(from_node)) as BaseGN
	var new_node =_copy_node(node)
	var mouse_pos2 = release_position + node_parent.scroll_offset - Vector2(0,new_node.get_rect().size.y/2)
	mouse_pos2 /= node_parent.zoom
	new_node.position_offset = mouse_pos2
	var to_node = node_parent.get_path_to(new_node).get_name(0)
	node_parent.connect_node(from_node,from_port,to_node,0)

func _copy_selected_node_x():
	print(selected.size())
	for item:Node in selected:
		
		if item is BaseGN:
			_copy_node(item)
	
## 复制节点
func _copy_node(from_node:BaseGN,pos:Vector2 = Vector2.ZERO):
	var new_node:BaseGN  
	if from_node:
		new_node =  from_node.duplicate()
		new_node.from_data(from_node.to_data(node_parent))
		node_parent.add_child(new_node)
		need_save = true
		if pos != Vector2.ZERO:new_node.position_offset = pos
		else: new_node.position_offset = Vector2(from_node.position_offset.x+20,from_node.position_offset.y)
	return new_node
	
	
func _on_changed():
	need_save = true
	pass

func _on_node_click(event: InputEvent,node):
	if event is InputEventMouseButton and event.button_index == 2 and event.pressed:
		var mouse_position = event.global_position
		_show_popup_menu(mouse_position)
		popup_menu.set_item_metadata(1,node)

func _show_popup_menu(mouse_pos:Vector2):
		popup_menu2.set_position(mouse_pos)
		popup_menu2.show()
		

func _has_node(val:String) -> bool:
	var list = node_parent.get_children().filter(func(item): return item is GraphNode)
	print("list_count:",list.size())
	if list.is_empty(): return false
	var nodes = list.filter(func(item): return item.title  == val)
	if nodes.size() > 0: return true
	return false

func _on_gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.button_index == 1 and event.pressed:
		selected.clear()
	if event is InputEventMouseButton and event.button_index == 2 and event.pressed:
		# 获取鼠标在 GraphEdit 上的位置
		popup_menu2.hide()		

func _get_node_by_pos(mouse_position) -> GraphNode:
		# 遍历所有子节点，检查是否为 GraphNode
		for node in node_parent.get_children():
			if node is GraphNode:
				# 获取 GraphNode 的屏幕位置和大小
				var rect = Rect2(node.get_global_rect(), node.size)
				# 检查鼠标是否在节点的区域内
				if rect.has_point(mouse_position - node.get_global_rect()):
					return node # 找到节点后立即返回
		return null

## 获得节点树
func _get_node_tree() -> BaseEventNode:
	var tree:BaseEventNode
	var nodes = node_parent.get_children().filter(func(node):return node is BaseGN)
	print("总共找到%s个节点" % nodes.size())
	var root:GraphNode = nodes.filter(func(item): return item.name == "StartNode")[0]
	if !root: 
		print_debug("没有找到开始节点")
		return	
	## 创建所有节点
	var data_map  = {}
	for node in nodes:
		#printerr("正在生成node",node)
		var node_data = _make_node_data(node)
		if !node_data:
			printerr("出错了，没有生成储存data")
			return
		data_map[node] = node_data
	
	## 根据连线生成树
	tree = await  _set_tree_leaf(root,data_map)
	return tree

## SAVE
func _set_tree_leaf(parent_gra:GraphNode,map:Dictionary):
	## 0. 获取要操作的对象数据
	var parent_data:BaseEventNode = map[parent_gra]
	print("map=",map)
	if !parent_data: 
		printerr("出现错误，parent_data为空")
		return
	## 1. 获得所有connection连线
	var connection_list = node_parent.get_connection_list()
	## 2. 找出所有与parent有关lines
	var lines = connection_list.filter(func(line): return node_parent.get_node(NodePath(line.from_node)).name == parent_gra.name)
	if lines.size() > 0:
		## 3. 找出to的node_data，并放在parent的子节点中
		var children:Array[ChildrenNodeConfig]
		for linex in lines:
			var node = node_parent.get_node(NodePath(linex.to_node))
			node = await _set_tree_leaf(node,map)
			var child:ChildrenNodeConfig = ChildrenNodeConfig.new(linex.from_port,linex.to_port,node)
			print_stack()
			children.append(child)
		parent_data.children.append_array(children)
	return parent_data

## WARNING SAVE 请在BaseGN类重写to_data函数 
func _make_node_data(node:BaseGN):
	var vo:BaseEventNode
	vo = node.to_data(node_parent)
	return vo

func _on_connection_request(from_node: StringName, from_port: int, to_node: StringName, to_port: int):
	print("正在连接两个节点")
	node_parent.connect_node(from_node,from_port,to_node,to_port)
	pass

func disconnect_lines(from_node: StringName, from_port: int, to_node: StringName, to_port: int):
	node_parent.disconnect_node(from_node,from_port,to_node,to_port)
	pass

func show_menu(at_position:Vector2):
	var mc = at_position + node_parent.scroll_offset  
	_show_popup_menu(at_position)
	print("at_pos=",at_position)
	pass
