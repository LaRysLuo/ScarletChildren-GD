## 会在不用的时候自动释放
extends RefCounted
class_name EventThread

signal on_complete

var args:Dictionary

## 构造函数
func _init() -> void:
	pass

## 触发事件封装
func trigger_event(event:BaseEventNode,trigger_self:Event,args = {}):
	self.args = args
	_do_next(event,trigger_self)
	return self

## 内部方法
func _do_next(event:BaseEventNode,trigger_self:Event):
	## 获得下一个事件
	event = event.next()
	print("下一个事件=",event)
	if !event: 
		## 发送事件处理完毕的信号
		on_complete.emit()
		print("事件全部执行结束")
		return
	## 执行事件的逻辑
	await event._execute(trigger_self,self.args)
	## 继续判断下一个
	_do_next(event,trigger_self)
