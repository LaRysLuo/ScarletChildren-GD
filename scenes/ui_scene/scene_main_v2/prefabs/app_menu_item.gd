extends VBoxContainer
class_name AppMenuItem

const style:StyleBoxFlat = preload("res://scenes/ui_scene/scene_main_v2/prefabs/app_menu_item_style.tres")

var COLOR_SELECTED = Color("#c03264")
var COLOR_NORMAL = Color("#3d2c2c")

## 图标
var tex_rect:TextureRect:
    get: return get_node("Icon/TextureRect")

## app文本
var label:Label:
    get: return get_node("Label")

var icon_panel:Panel:
    get: return get_node("Icon")

var icon_tex:TextureRect:
    get: return get_node("Icon/TextureRect")    

var symbol:String

func _ready() -> void:
    unfocus()

## 获得选择的状态
func get_style(is_selected:bool) -> StyleBoxFlat:
    var new_style:StyleBoxFlat = icon_panel.get_theme_stylebox("panel").duplicate()
    new_style.border_color = COLOR_SELECTED if is_selected else COLOR_NORMAL
    return new_style

func focus():
    icon_panel.add_theme_stylebox_override("panel",get_style(true))
    label.self_modulate = COLOR_SELECTED
    
func unfocus():
    icon_panel.add_theme_stylebox_override("panel",get_style(false))
    label.self_modulate = COLOR_NORMAL

func set_data(_name:String,_tex:Texture2D,_symbol:String):
    label.text = _name
    icon_tex.texture = _tex
    self.symbol = _symbol