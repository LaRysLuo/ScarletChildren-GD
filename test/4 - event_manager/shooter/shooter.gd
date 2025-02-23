extends Node
class_name Shooter

signal on_shoot

## 发射信号
func emit(event_name:String,args:Array = []):
    # 将信号发射出去
    on_shoot.emit(event_name,args)
    pass