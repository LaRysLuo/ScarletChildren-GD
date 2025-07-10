@tool
extends Node
class_name VariableCore

## 变量的核心代码
enum VariableType {
	STRING =  4, # 字符串
	INT = 2, # 整型
	BOOL = 1, # 布尔
	#FLOAT = 3, # 浮点
}

const CONFIG_ROUTE = "res://variable_config.tres"

## 获取存储的变量值
var get_vars:Dictionary = {}

func _init():
	_load_variable_config()

## 保存数据
func save():
	var config:VariableConfig = VariableConfig.new()
	#var vars:Array[VariableData] = []
	#for item in get_vars.values():
		#vars.append(VariableData.new(item.key,item.type,item.initial_value,item.saved_value))
	config.vars = get_vars.duplicate()
	
	print("要保存的数据大小为：%s" % config.vars.size())
	var err:Error = ResourceSaver.save(config,CONFIG_ROUTE)
	if err != OK:
		print("[VariableCore]保存失败：失败原因:%s" % err)
	print("[VariableCore]保存成功")

	

## 读取自定义变量的复制
func _load_variable_config(): 
	if FileAccess.file_exists(CONFIG_ROUTE):
		var loaded = ResourceLoader.load(CONFIG_ROUTE) as VariableConfig
		if loaded: get_vars = loaded.vars.duplicate()  

## 查询已存在的变量列表
func list() -> Dictionary: return get_vars
	

## 注册变量
func add(key:String,type:VariableType,initial_value) -> Error:
	## 判断是否已经存在变量名
	if has(key): return ERR_ALREADY_EXISTS ## 添加失败,已经存在该key
	var add_vari := VariableData.new(key,type,initial_value)
	get_vars[key] = add_vari
	print("get_vars=",get_vars)
	return OK


## 判断库是否有这个变量
func has(key:String):
	return get_vars.has(key)
	
func get_value(key:String) :
	if !has(key): return ERR_DOES_NOT_EXIST
	var vari:VariableData = get_vars.get(key)
	return vari
		

## 设置值
func set_value(key:String,value:Variant):
	var vari = get_value(key)
	## 判断设置的值是否匹配
	if vari is VariableData &&  typeof(value) == vari.type:
		vari.saved_value = value
	else:
		push_error("变量%s不存在或者类型%s不正确" % [key,vari.type])

## 将变量名恢复为默认值
func reset(key:String): 
	var vari = get_value(key)
	if vari && vari is VariableData: vari.reset()

## 移除变量
func remove(key:String): if has(key): get_vars.erase(key)
