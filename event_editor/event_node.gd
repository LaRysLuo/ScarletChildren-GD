extends Resource
## 这是之前的老组件，现在已经弃用了
## @deprecated:已弃用了，请改用[BaseEventNode]
class_name EventCode

# 这是事件节点语句，存入事件中用于执行事件逻辑
var childrent:Array[EventCode] # 可以放置多个子节点
@export var code_name:CodeName
@export var args:String

enum CodeName{
	MESSAGE, #信息弹窗
	TELEPORT, #场景移动 
	MOVEFORWARD,#前进 参数1Event,参数2是前进的步数
	FACEDIR, #面朝方向 参数1是目标Event,参数2可以面朝方向，也可以是面朝的角色
	FADEOUT, # 画面淡出
	FADEIN,# 画面淡入
	WAIT, #等待N秒，参数为时间
	MOVEDOWN, #向上移动
	MOVELEFT, #向左移动
	MOVERIGHT, #向右移动
	MOVEUP, #向上移动
	FACEDOWN, # 面朝下
	FACELEFT, # 面朝左
	FACERIGHT,# 面朝右
	FACEUP, # 面朝上
}
