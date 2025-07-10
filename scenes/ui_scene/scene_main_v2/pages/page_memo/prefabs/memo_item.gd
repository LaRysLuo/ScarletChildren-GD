extends ListItemBase
class_name MemoItem

# ===========================
# 常量
# ===========================

const NORMAL_COLOR = Color("#282828")

const SELECTED_COLOR = Color("#7c1a44")

const FINISHED_ALPHA = 0.5

# ============================
# 组件引用
# ============================

var check_box:CheckBox:
    get: return get_node("MarginContainer/HBoxContainer/HBoxContainer/CheckBox")

var title_label:Label:
    get: return get_node("MarginContainer/HBoxContainer/HBoxContainer/Label")

var desc_label:Label:
    get:return get_node("MarginContainer/HBoxContainer/Label2")    


# =============================
# 实现基类的函数
# =============================

func set_data(_data:Dictionary):
    if _data == {}:
        title_label.text = ""
        desc_label.text = ""
        check_box.hide()
        return
    title_label.text = _data.get("title")
    desc_label.text = _data.get("desc")
    var is_finish = _data.get("finished",false)
    if is_finish: 
        _set_finished()
        check_box.show()
    else: check_box.hide()

## 聚焦
func focus():  _set_style_color(SELECTED_COLOR)

## 失焦
func unfocus(): _set_style_color(NORMAL_COLOR)


# ==============================
# 内部函数
# ==============================

## 获取样式源
func _get_style_origin() -> StyleBoxFlat:
    return get_theme_stylebox("panel")

func _set_style_color(color:Color):
    var style:StyleBoxFlat = _get_style_origin().duplicate()
    style.bg_color = color
    add_theme_stylebox_override("panel",style)

func _set_finished():
    self.modulate.a = FINISHED_ALPHA