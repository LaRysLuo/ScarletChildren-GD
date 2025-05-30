extends Node
class_name EventPageHandler

## 获得你的页面
var pages:Array[Node]:
    get: return get_children()

var events:Array:
    get: return get_tree().get_nodes_in_group("events")

func _ready() -> void:
    call_deferred("_valid_event_exist")
    call_deferred("_init_pages_and_event")

## 校验所有添加的页是否合法
func _valid_event_exist():
    for page in pages:
        if not page is BasePage:
            push_error("EventPages下添加的组件存在不是BasePage的")
            continue
        var exist = events.any(func(item:Event):return item.ori_cell_pos == page.pos)

        if !exist:
            push_error("坐标为%s的事件页%s没有在地图中添加对应的Event" % [page.pos,page.name])

## 初始化页面
func _init_pages_and_event():
    # for page in pages:
    #     page.
    pass

## 尝试获取获取事件页
func try_get_event_page(coord:Vector2i,ignore_condition:bool = false) -> EventPage:
    var _pages = pages.filter(func(child:Node2D): return child is EventPage && child.visible)
    if _pages.is_empty(): return null
    var filter = _pages.filter(
        func(item): 
            ## INFO 2025.1.31修改 - 改为复数条件
            return item.pos == coord and ((item is EventPage and item.get_condition_result()) or ignore_condition)
    )
    if filter.is_empty():return null
    print("1111",filter.front())
    return filter.front()

func try_get_ex_page(coord:Vector2i,ignore_condition:bool = false) -> ExPage:
    var _pages = pages.filter(func(child): return child is ExPage)
    if _pages.is_empty(): return null
    var filter = _pages.filter(
        func(item:ExPage): 
            ## INFO 2025.1.31修改 - 改为复数条件
            return item.pos == coord  or ignore_condition
    )
    if filter.is_empty():return null
    return filter.front()