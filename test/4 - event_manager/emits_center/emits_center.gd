extends Node
class_name EmitsCenter


var emits:Dictionary = {}


## 添加emit
func add_emit(key:String, callback:Callable):
    emits[key] = callback

## 移出emit
func remove_emit(key:String):
    emits.erase(key)



## 连接所有信号发射器
# 每次场景载入时，将触发该函数
func _connect_all_shooters():
    var shooters =  get_tree().get_nodes_in_group("shooters")

    for shooter in shooters:
        shooter.connect("on_shoot",_on_shoot)

## 有信号发射了
func _on_shoot(key:String,args:Array):
    print("收到名为:%s的信号了" % key)
    if emits.has(key):
        emits[key].callv(args)