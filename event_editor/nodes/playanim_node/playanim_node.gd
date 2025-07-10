@tool
extends BaseGN
class_name PlayAnimGN

var anim_name_input:TextEdit:
    get:return get_node("VBoxContainer/HSplitContainer/TextEdit")

## 目标角色
var target_character:OptionButton:
    get():return get_node("VBoxContainer/HSplitContainer2/HBoxContainer/Label")

var selected_character:Dictionary = {}

## 选择按钮
var character_selcted_btn:Button:
    get():return get_node("VBoxContainer/HSplitContainer2/HBoxContainer/Button")


func _enter_tree() -> void:
    character_selcted_btn.button_down.connect(show_character_selected_window)	
    
func _exit_tree() -> void:
    character_selcted_btn.button_down.disconnect(show_character_selected_window)	
    
const character_selection_window_pre = preload("res://event_editor/component/character_selection_window/window_character_selection.tscn")
var character_selected_window:Popup 
func show_character_selected_window():
    character_selected_window = Popup.new()
    character_selected_window.transient = true

    character_selected_window.title = "选择事件"
    #character_selected_window.close_requested.connect(func(): 
        #get_tree().root.remove_child(character_selected_window)
        #character_selected_window.queue_free()
    #)
    #print("character_selection_window_pre",character_selection_window_pre)
    var child = character_selection_window_pre.instantiate()
    child.on_selection_complete.connect(func(item):
        selected_character = item
        _refresh_selected()
        #call_deferred("close_popup")
        var timer = get_tree().create_timer(0.1)
        timer.timeout.connect(close_popup)
    
        #get_tree().root.remove_child(character_selected_window)
        #character_selected_window.queue_free()
    )
    character_selected_window.size = Vector2(300,300)
    #character_selected_window = Vector2(300, 200)
    get_tree().root.add_child(character_selected_window)
    character_selected_window.add_child(child)
    
    character_selected_window.popup_centered()  # 弹窗居中显示
    #character_selected_window.show()

func close_popup():
    character_selected_window.hide()

func _refresh_selected():
    target_character.text = selected_character['label']

func from_data(data:BaseEventNode) -> BaseGN:
    if data is PlayAnimData:
        anim_name_input.text = data.anim_name
        selected_character = data.ori_data
        _refresh_selected()
    return self

func to_data(_edit:GraphEdit) -> BaseEventNode:
    var value = selected_character['coord']
    # var label = selected_character['label']
    var _event_type = value if typeof(value) == TYPE_STRING else "other"
    var _anim_name:String = anim_name_input.text
    var _coord:Vector2i = value if typeof(value) == TYPE_VECTOR2I else null
    return PlayAnimData.new(BaseEventNode.PlayEventAnim,self.position_offset,_anim_name,_event_type,_coord,selected_character)


    
