extends EventEx
class_name DoorEx

## 目标场景名
@export var scene_path:String

## 场景转换前移动步数
@export var step1:int = 2
## 场景转换后移动步数
@export var step2:int = 1

## 目标坐标
@export var target_pos:Vector2i

## 目标事件坐标点：该变量必须正确填写，否则会导致事件反复触发
@export var target_scene_door:Vector2i


## 组合event_res
func _make_event_res() ->Events_Res:
	var start = StartData.new()
	var playanim_node_01 = PlayAnimData.new(BaseEventNode.PlayEventAnim,Vector2.ZERO,"open")
	var wait_node_02 = WaitData.new(BaseEventNode.Wait,Vector2.ZERO,0.1)
	var playanim_ndoe_03 = PlayAnimData.new(BaseEventNode.PlayEventAnim,Vector2.ZERO,"opened")
	var charmove_node_04 = CharacterMoveData.new(BaseEventNode.CharacterMove,Vector2.ZERO,0,{"label":"玩家","coord":"player"},step1,1,true)
	var script_node_05 = ScriptData.new(BaseEventNode.Scripts,Vector2.ZERO,"await GameManager.fadeout_black(0.5)")
	var transport_node_06 = TransportData.new(BaseEventNode.CharacterMove,Vector2.ZERO,scene_path,true,target_pos,false)
	var playanim_node_10 = PlayAnimData.new(BaseEventNode.PlayEventAnim,Vector2.ZERO,"opened","other",target_scene_door) ## 在对应的位置切换门动画
	var wait_node_07 = WaitData.new(BaseEventNode.Wait,Vector2.ZERO,0.2)
	var charmove_node_08 = CharacterMoveData.new(BaseEventNode.CharacterMove,Vector2.ZERO,0,{"label":"玩家","coord":"player"},step2,1,false)
	var script_node_09 = ScriptData.new(BaseEventNode.Scripts,Vector2.ZERO,"await GameManager.fadein()")
	var playanim_node_11 = PlayAnimData.new(BaseEventNode.PlayEventAnim,Vector2.ZERO,"close","other",target_scene_door) ## 在对应的位置切换门动画
	var playanim_node_12 = PlayAnimData.new(BaseEventNode.PlayEventAnim,Vector2.ZERO,"default","other",target_scene_door) ## 在对应的位置切换门动画
	
	
	## START节点
	
	start.children.append(ChildrenNodeConfig.new(0,0,playanim_node_01))
	playanim_node_01.children.append(ChildrenNodeConfig.new(0,0,wait_node_02)) ## 播放门动画
	wait_node_02.children.append(ChildrenNodeConfig.new(0,0,playanim_ndoe_03)) ## 等待
	playanim_ndoe_03.children.append(ChildrenNodeConfig.new(0,0,charmove_node_04)) ## 切换门动画为开启
	charmove_node_04.children.append(ChildrenNodeConfig.new(0,0,script_node_05)) ## 向前移动2步
	script_node_05.children.append(ChildrenNodeConfig.new(0,0,transport_node_06)) ## 淡出
	transport_node_06.children.append(ChildrenNodeConfig.new(0,0,playanim_node_10)) ## 移动场景
	playanim_node_10.children.append(ChildrenNodeConfig.new(0,0,wait_node_07)) ## 切换门动画
	wait_node_07.children.append(ChildrenNodeConfig.new(0,0,charmove_node_08)) ## 等待
	charmove_node_08.children.append(ChildrenNodeConfig.new(0,0,script_node_09)) ## 角色向前移动
	script_node_09.children.append(ChildrenNodeConfig.new(0,0,playanim_node_11))
	playanim_node_11.children.append(ChildrenNodeConfig.new(0,0,playanim_node_12))
	var event_res = Events_Res.new(start)
	event_res.is_collsion = true
	return event_res
	
