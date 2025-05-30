extends Control
class_name ScenePassword


var number_input:ViewNumberInput:
    get: return get_node("ViewNumberInput")

var password:String

signal on_submit()
signal on_cancel()
signal on_succuss()
signal on_fail()
signal on_select_changed

func _ready() -> void:
    number_input.on_submit.connect(_on_submit)
    number_input.on_select_changed.connect(func():on_select_changed.emit())
    pass

func set_password(_psw:String):
    self.password = _psw

func _on_submit(val):
    print("开始判断：%s" % val)
    if !val:
        on_cancel.emit()
    elif password == val: 
        print("成功触发")
        on_succuss.emit()
    else: 
        on_fail.emit()
        print("失败触发")
    call_deferred("_close_window",val)

func _close_window(val): 
    on_submit.emit(val)
#     SceneManager.backall()
