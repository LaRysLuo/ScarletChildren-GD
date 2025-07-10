extends Control
class_name SceneMenuV2


# =====================================
# 常量
# =====================================
const no_fade_pos = 608
const fade_pos = 68
const FADE_TIME = 0.2

const tachie_01 = preload("res://scenes/ui_scene/scene_main_v2/assets/250621.png")
const tachie_02 = preload("res://scenes/ui_scene/scene_main_v2/assets/250621_bag.png")


var tachie_tr:TextureRect:
    get: return get_node("TextureRect")

var phone_trans:PhoneMenu:
    get: return get_node("Phone")

var panel_bg:TextureRect:
    get: return get_node("PanelBg")

var window_item:WindowItemV2:
    get: return get_node("WindowItem")


var window_help:WindowHelp:
    get: return get_node("WindowHelp")

var page_controller:PageController:
    get: return get_node("Phone/PhoneBase2/Page")    

var tachie_index:int = 0


func _ready() -> void:
    _init_phone_cmd()
    _init_window_item()
    _init_window_help()
    _tachie_changed(.3)
    await  _phone_fade_animation()
    phone_trans.activate()

func _init_phone_cmd():
    phone_trans.set_handler("cancel",_phone_fadeout_animation)
    phone_trans.set_handler("camera",_handle_cam)
    phone_trans.set_handler("item",_handle_item)
    phone_trans.set_handler("memo",_handle_memo)
    phone_trans.set_handler("picture",_handle_picture)
    


func _init_window_item():
    window_item.set_handler("cancel",_handle_item_close)
    window_item.hide()

func _init_window_help():
    window_item.on_item_changed.connect(_handle_item_changed)

## 立绘转换
func _tachie_changed(fade_time:float = 0):
    # tachie_tr.texture = tachie_01 if tachie_index == 0 else tachie_02
    var to = tachie_01 if tachie_index == 0 else tachie_02
    await  _tachie_cross_fade(to,fade_time)
    tachie_index = 1 if tachie_index == 0 else 0

func _tachie_cross_fade(to:Texture2D,duration:float = 0):
    var from_tr:TextureRect = tachie_tr
    var to_tr:TextureRect = tachie_tr.duplicate()
    to_tr.texture = to
    to_tr.modulate.a = 0
    from_tr.add_sibling(to_tr)
    var tween = create_tween()
    tween.tween_property(to_tr,"modulate:a",1,duration)
    tween.tween_property(from_tr,"modulate:a",0,duration)
    await tween.finished
    remove_child(from_tr)
    from_tr.queue_free()

    to_tr.name = from_tr.name


## 手机进入场景
func _phone_fade_animation():
    phone_trans.position.y =  no_fade_pos
    var tween = create_tween()
    tween.tween_property(phone_trans,"position:y",fade_pos,FADE_TIME)
    await tween.finished

func _phone_fadeout_animation():
    var tween = create_tween()
    tween.tween_property(phone_trans,"position:y",no_fade_pos,FADE_TIME)
    tween.finished.connect(func():UIManager.pop_all() )

    
## 设置屏幕图片
func set_mapshot(_mapshot:Texture2D):
    panel_bg.texture =  _mapshot as Texture2D
    print_debug("texture:",_mapshot as Texture2D)
    # self.mapshot = _mapshot

const old_cam_event_res = preload("res://event_res/item_res/effect/02i_1_老式拍立得.tres")



## 拍照功能
func _handle_cam() -> bool:
    phone_trans.deactivate()
    # 0. 退出主菜单
    UIManager.pop_all()
    # 等待恢复正常
    GameManager.trigger_event_res(old_cam_event_res)
    return true

## 显示物品栏
func _handle_item():
    phone_trans.deactivate()
    phone_trans.hide()
    window_help.show()
    window_item.show_window()
    await  Interpreter.play_se("bag_open",false,10)
    await _tachie_changed(0.5)
    window_item.activate()
    return 

func _handle_item_close() -> void:
    window_item.deactivate()
    window_help.hide()
    phone_trans.activate()
    await  _tachie_changed(0.3)
    phone_trans.show()

func _handle_item_changed(item:Item) -> void:
    var info = item.item_desc if item else ""
    # print("被选中的道具是%s" % item.item_desc)
    window_help.set_data(info)

## 显示备忘录
func _handle_memo():
    phone_trans.deactivate()
    page_controller.push_page("phone_memo")
    await page_controller.all_finished
    phone_trans.activate()
    
func _handle_picture():
    phone_trans.deactivate()
    page_controller.push_page("phone_picture")
    await page_controller.all_finished
    phone_trans.activate()
