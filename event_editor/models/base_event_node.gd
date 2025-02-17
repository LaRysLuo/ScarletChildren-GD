extends Resource
class_name BaseEventNode


const Start = 0 ## 开始节点
const Message = 1 ##显示消息
const Option = 2 ##分支选项
const CharacterMove = 3 ## 角色移动
const Fadeout = 4 ## 画面淡出
const Fadein = 5 ## 画面导入
const Wait = 6 ## 等待
const FaceDir = 7 ## 面向朝向
const Transport = 8 ## 场景移动
const Scripts = 9 ##脚本
const SubThread = 10 ## 子线程
const PlayEventAnim = 11 ## 播放事件动画
const Keyword = 12 ## 关键词节点
const Itemlink = 13 ## 物品联想节点
const Reading = 14 ## 阅读模式
const ReadingPage = 15 ## 阅读Ex - 页面
const CinemaMode = 16 ## 启动剧场模式
const ConditionNode = 17 ## 条件判断


## graph节点

## 子节点
@export var children:Array[ChildrenNodeConfig]

## 节点类型
@export var node_type:int

## 位置
@export var pos:Vector2

## 初始化
func _init(_node_type:int = 0,_pos:Vector2 = Vector2.ZERO,_children:Array[ChildrenNodeConfig] = []) -> void:
	self.node_type = _node_type
	self.pos = _pos
	self.children = _children

## 找到下一个子节点
func next(index:int=0) -> BaseEventNode:
	if !children || children.is_empty(): return null
	var filters:Array[ChildrenNodeConfig] = children.filter(func(item:ChildrenNodeConfig):return item.from_port_index == index)
	if filters.is_empty():return null
	return filters[0].child

## 查看语句数量，未完善
#func size() -> int:
	#var count:int = 1
	#var node = self
	#while(true):
		#node = next() ## 获得下一个
		#if node: count+=1
		#else: break
	#return count

## 在游戏中执行事件
func _execute(_event,_args):
	printerr("没有重写%s游戏内逻辑" %node_type)
