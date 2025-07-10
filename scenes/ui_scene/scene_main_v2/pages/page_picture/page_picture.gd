extends SelectableScene
class_name PagePicture

# ========================
# 常量
# ========================
const FADE_DURATION = 0.15
const FADE_OFFSET_X = 280

## 数据源
var _data:Array:
    get: return Save.get_save_data_list()

var page_tabs:PageTabs:
    get: return get_node("MarginContainer/VBoxContainer/PageTabs")

var page_trans:VBoxContainer:
    get: return get_node("MarginContainer/VBoxContainer")

var empty_label:Label:
    get: return get_node("MarginContainer/VBoxContainer/PanelContainer/EmptyLabel")

var slot_label:Label:
    get: return get_node("MarginContainer/VBoxContainer/Label")
# var info_trans:Control:
#     get: return get_node("MarginContainer/VBoxContainer/PanelContainer/MarginContainer")

var color_rect:ColorRect:
    get: return get_node("MarginContainer/VBoxContainer/PanelContainer/ColorRect")

var map_name:Label:
    get: return get_node("MarginContainer/VBoxContainer/PanelContainer/MarginContainer/VBoxContainer/MapName")

var game_time:Label:
    get: return get_node("MarginContainer/VBoxContainer/PanelContainer/MarginContainer/VBoxContainer/GameTime")

var save_time:Label:
    get: return get_node("MarginContainer/VBoxContainer/PanelContainer/MarginContainer/VBoxContainer/SaveTime")

var page_num:int = 0

# =============================
# 信号
# =============================

signal finished

# ==============================
# 重写回调
# ==============================
func _ready() -> void:
    super._ready()
    _init_handlers()
    _init_tabs()
    _init_list()
    activate()

func _get_selection_mode() ->int:
    return TYPE_HORIZONTAL


## 初始化输入器
func _init_handlers():
    set_handler("cancel",_handle_cancel)
    pass

## 初始化分页器
func _init_tabs():
    page_tabs.init_page(_data.size(),page_num)
    

func _init_list():
    for i in _data: _list.append("")
    on_select_changed.connect(_render)
    select(0)

## 渲染
func _render(index:int,last:int,_symbol):
    var from:Control
    print("to_index是%s,from_index是%s,dir是%s" % [index,last,last - index])
    if last != -1: from = await _slice_start(last - index)
    self.page_num = index
    var current_data = self._data[index]
    slot_label.text = "照片%s" % (index+1)
    if current_data:
        var info:SaveData  = Save.get_save_data_info(current_data,index)
        color_rect.show()
        empty_label.hide()
        map_name.text = info.map_name
        _format_time(info.game_time)
        save_time.text = info.create_time
        map_name.show()
        game_time.show()
        save_time.show()
    else: _render_empty()
    if last != -1 :await  _slice_end(last - index,from)
    page_tabs.update_page_num(index,last)


## 滑动开始
func _slice_start(dir:int):
    deactivate()
    var tween = create_tween()
    var from:Control = page_trans.duplicate()
    page_trans.add_sibling(from)
    tween.tween_property(page_trans,"position:x",-dir * FADE_OFFSET_X,0)
    tween.tween_callback(_tween_complete.bind(tween))
    return from

func _tween_complete(tween:Tween):
    tween.kill()
    tween = null



## 滑动结束
func _slice_end(dir:int,from:Control):
    # 将from向别外部移动
    var to = page_trans
    var tween = create_tween()
    tween = create_tween()
    tween.tween_property(from,"position:x",dir * FADE_OFFSET_X,FADE_DURATION)
    tween.tween_property(to,"position:x",0,FADE_DURATION)
    await  tween.finished
    
    from.get_parent().remove_child(from)
    from.name = to.name
    from.queue_free()
    tween.kill()
    activate()

func _render_empty():
    empty_label.show()
    color_rect.hide()
    map_name.hide()
    game_time.hide()
    save_time.hide()

func _format_time(time):
    var hours = int(time / 3600)
    var minutes = int((time % 3600) / 60)
    var secs = time % 60
    game_time.text =  "%sh%sm%ss" % [str(hours),str(minutes),str(secs)] 

func _handle_cancel():
    finished.emit()