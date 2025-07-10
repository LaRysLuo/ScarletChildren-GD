extends BaseEventNode
class_name ReadingPageData

@export var content:String

func _init(_cmd:int = BaseEventNode.Wait,_pos:Vector2 = Vector2.ZERO,_content:String = "") -> void:
	self.node_type = _cmd
	self.pos = _pos
	self.content = _content

## 获得下一页
func get_next_page(result:Array[ReadingPageData]):
	var page =  next()
	print("递归中的page为",page)
	if !page:return
	if page is ReadingPageData:
		result.append(page)
		print("当前pages为",result.size())
		page.get_next_page(result)
	else:
		printerr("出错了，连接的节点不对")

## 重写虚方法
func _execute(_ent:Event,_args):
	pass
