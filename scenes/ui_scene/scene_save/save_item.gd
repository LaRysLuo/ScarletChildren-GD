extends Control
class_name SaveItem

const COLOR_SCARLET = Color("#891d62")
const COLOR_WHITE = Color("#000418")
const COLOR_DISABLE = Color("#535353af")

## 地图名称
var map_name_label:Label:
    get: return get_node("VBoxContainer/PanelContainer/Control/VBoxContainer/MapName")

## 游戏时间
var game_time_label:Label:
    get: return get_node("VBoxContainer/PanelContainer/Control/VBoxContainer/GameTime")

## 存档时间
var save_time_label:Label:
    get:return get_node("VBoxContainer/PanelContainer/Control/VBoxContainer/SaveTime")

var slot_name_label:Label:
    get: return get_node("VBoxContainer/Label")

var color_rect:ColorRect:
    get: return get_node("VBoxContainer/PanelContainer/ColorRect")

var empty_label:Label:
    get: return get_node("VBoxContainer/PanelContainer/EmptyLabel")

var data:SaveData

func set_value(_slot:int,_data:SaveData):
    slot_name_label.text = "存档%s" % (_slot +1)
    self.data = _data


var style_box_flat:StyleBoxFlat = preload("res://scenes/ui_scene/scene_save/style_box_flat.tres")

var new_style_boxL:StyleBoxFlat

var style_box_panel: Control:
    get: return get_node("VBoxContainer/PanelContainer")
        
        # var panel:Control = get_node("VBoxContainer/PanelContainer")
        # panel.add_theme_stylebox_override("panel",)

func _ready() -> void:
    _init_style()
    deactive()
    _refresh_data()
    
func _init_style(): 
    new_style_boxL = style_box_flat.duplicate()
    style_box_panel.add_theme_stylebox_override("panel",new_style_boxL)

func _refresh_data():
    if data:
        color_rect.show()
        empty_label.hide()
        map_name_label.text = data.map_name
        _refresh_time(data.game_time)
        save_time_label.text = data.create_time
    else:
        empty_label.show()
        color_rect.hide()
        map_name_label.hide()
        game_time_label.hide()
        save_time_label.hide()
        disable()

func _refresh_time(time):
    var hours = int(time / 3600)
    var minutes = int((time % 3600) / 60)
    var secs = time % 60
    game_time_label.text =  "%sh%sm%ss" % [str(hours),str(minutes),str(secs)] 

func is_empty() -> bool:
    return !data

## 激活
func active(): 
    new_style_boxL.border_color = COLOR_SCARLET
    


## 冻结
func deactive(): 
    new_style_boxL.border_color = COLOR_WHITE

func disable():
    new_style_boxL.border_color = COLOR_DISABLE
