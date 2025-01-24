@tool
extends BaseGN
class_name OptionGN


var option_item_prefab = preload("res://event_editor/nodes/option/component/option_item_comp.tscn")
var option_list:Array[Node]:
	get(): return get_children().filter(func(item): return item is OptionItem)
	

func _enter_tree() -> void:
	add_option(2)
	_refresh_option_list()

func _exit_tree() -> void:
	#for item:OptionItem in option_list:
		#item.on_add.disconnect(add_option)
		#item.on_delte.disconnect(remove_option)
	pass

## 刷新选项列表的状态
func _refresh_option_list():
	var index:int = 0
	for item:OptionItem in option_list:
		## 设置前面两个选项不能显示删除按钮
		if index != 0 && index != 1: 
			item.set_option_visible(OptionItem.DEL,true)
		else: item.set_option_visible(OptionItem.DEL,false)
		## 只有最后一个元素才显示添加按钮
		if index == option_list.size() -1:
			item.set_option_visible(OptionItem.ADD,true)
		else: item.set_option_visible(OptionItem.ADD,false)
		var is_input:bool = false
		if index == 0: is_input = true
		self.set_slot(index,is_input,0,Color.WHITE,true,0,Color.WHITE)
		index +=1
	

## 添加选项
func add_option(count:int = 1):
	var option:OptionItem
	for n in count:
		## 新建一个option
		option = option_item_prefab.instantiate()
		option.set_text("",option_list.size())
		add_child(option)
		option.on_add.connect(add_option)
		option.on_delte.connect(remove_option)
	_refresh_option_list()
	return option

## 移出选项
func remove_option(item:OptionItem,count:int = 1):
	remove_child(item)
	item.on_add.disconnect(add_option)
	item.on_delte.disconnect(remove_option)
	item.queue_free()
	_refresh_option_list()
	
func set_value(options:Array[Dictionary]):
	## 根据键创建选项，如果选项不够，则增加
	var index:int = 0
	for opt:Dictionary in options:
		var name:String = opt['name']
		if index > option_list.size() - 1 : add_option().set_text(name,index)
		else: option_list[index].set_text(name,index)
		index += 1

## 将节点转换为节点数据并返回
func to_data(edit:GraphEdit) -> BaseEventNode:
	var result:OptionData = OptionData.new(BaseEventNode.Option,self.position_offset)
	var index:int = 0
	for opt:OptionItem in option_list:
		print("选项内容为：%s" %opt.text.text)
		var connection_list = edit.get_connection_list()
		var lines = connection_list.filter(func(line): return edit.get_node(NodePath(line.from_node)).name == self.name && line.from_port == index)
		var obj:Dictionary ={}
		obj['id'] = index
		obj['name'] =  opt.text.text
		if lines && lines[0]:	obj['child_index'] = index
		else: obj['child_index'] = -1
		result.options.append(obj)
		index+=1
	return result
	return null
