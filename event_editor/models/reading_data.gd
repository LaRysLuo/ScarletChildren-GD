extends BaseEventNode
class_name ReadingData

@export var title:String
@export var close_any_time:bool

## 构造函数
func _init(cmd:int = BaseEventNode.Wait,pos:Vector2 = Vector2.ZERO,title:String = "",close_any_time:bool = false) -> void:
	self.node_type = cmd
	self.pos = pos
	self.title = title
	self.close_any_time = close_any_time

## 获得所有页面
func _get_pages() -> Array[ReadingPageData]:
	const from_port = 1
	var result:Array[ReadingPageData] = []
	var page = super.next(from_port)
	if !page: return result
	if page is ReadingPageData:
		result.append(page)
		page.get_next_page(result)
	else:
		printerr("出错了，连接的节点不对")
	return result

## 重写虚方法
# 开启阅读模式
func _execute(ent:Event,args:Dictionary):
	## 获得页面节点上所有的页面
	var pages = _get_pages()
	
	## 如果页面是空的，跳过该节点的执行
	if pages.is_empty():return
	
	## 跳转到阅读模式的场景
	var reading_node = await SceneManager.navigate_to("scene_reading_mode")
	
	## INFO 关于通过代码启动阅读器的改动
	# 时间 2025-01-31
	# 通过传入参数close_any来覆盖原有事件上的随时关闭的选项。
	# 主要用于物品栏的阅读器调用和其他事件的调用能使用同一个EventRes
	var _close_any_time:bool = close_any_time
	var close_any_force
	if args: 
		close_any_force = args.get("close_any")
		_close_any_time = close_any_force
	## INFO 关于通过代码启动阅读器的改动 END
	
	if reading_node is SceneFileRead:
		## 遍历所有页面，加入到阅读模式中
		for page:ReadingPageData in pages:
			reading_node.add_page(page.content)
		## 初始化阅读模式的标题和开闭模式
		reading_node.read_pre(title,2 if _close_any_time else 1)
		## 开始阅读模式
		reading_node.read_start()
	## 等待阅读模式结束，才继续执行下一个节点
	await  SceneManager.reading_mode_close
