extends Control
class_name WindowItemV2

## 游戏道具类的引用
var _game_items:GameItems:
	get: return GameManager.game_items

## 游戏道具数据源，只获取类型为道具的
var items:Array[Item]:
	get: return _game_items.get_items_catagory(1)




var item_list:ItemListV2:
	get: return get_node("PanelContainer/MarginContainer/ItemList")

signal on_item_changed(item:Item)


## 激活
func _ready() -> void:
	item_list.set_data(changedItems(items))
	item_list.on_select_changed.connect(_handle_item_changed)
	item_list.on_item_confirm.connect(_handle_use_item)
	hide()

func show_window():
	item_list.show_window()
	show()

func activate() -> void:
	if not visible: show_window()
	item_list.activate()

func deactivate()->void:
	item_list.deactivate()
	hide()

func set_handler(symbol:String,callback:Callable) -> void:
	item_list.set_handler(symbol,callback)
	

func changedItems(_items:Array[Item]) -> Array[Dictionary]:
	var result:Array[Dictionary] 
	for item:Item in _items:
		result.append(
			{
				"name":item.item_name,
				"icon":null,
				"symbol":item.item_id
			}
		)
	return result

## 道具变化时，发射信号
func _handle_item_changed(_index:int,_last:int,symbol:String) ->void:
	on_item_changed.emit(_get_item(symbol))

## 使用道具
func _handle_use_item(symbol:String):
	var item = _get_item(symbol)
	if not item or  not _game_items.usable(item):
		AudioManager.play_se("blip03")
		return
	item_list.deactivate()
	UIManager.pop_all()
	await _game_items.use_item(item)
	item_list.activate()
	
## 获得道具
func _get_item(symbol:String) -> Item:
	var filters = items.filter(func(item:Item): return str(item.item_id) == symbol)
	if filters.is_empty(): return
	return filters.front()
