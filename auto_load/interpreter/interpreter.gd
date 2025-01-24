extends Node
class_name Interpreter

## Scripts解释器
# WARNING 未完工 

## 解释器本体
@onready var exps:Expression = Expression.new()
const inputs:Dictionary = {
	
}

## 解释
func eval(code:String):
	var err = exps.parse("code",inputs.keys())
	if err != OK:
		printerr("出错了")
		return 
	pass
