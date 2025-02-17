extends CanvasLayer
class_name SceneFileRead

### 资料阅读逻辑
	## 启用阅读模式
 	# 资料名：xxx
	## 连接各种消息框
 	# 对话key:xxx
 	# 文本预览：xxx
	## 等待所有信息结束，关闭阅读模式
	## 当没有把所有信息阅读完前，无法关闭

const ALL_READED_CLOSE = 1
const CLOSE_ANY_TIME = 2
	
## 组件引用
# 标题组件
@onready var title_label:Label = get_node("MarginContainer/PanelContainer/MarginContainer/VBoxContainer/Label")

# 正文组件
@onready var content_label:RichTextLabel = get_node("MarginContainer/PanelContainer/MarginContainer/VBoxContainer/RichTextLabel")

# 底部按键提示栏
@onready var key_tip:KeyTipsBottom = get_node("MarginContainer2/KeyTipsBottom")


## 属性
@export var page_list:Array[String] 
var wait_input:bool = false
var page_index = -1
var close_type:int = ALL_READED_CLOSE

## 信号
signal read_finished ## 所有消息被读完了

func _ready() -> void:
	self.hide()

## 启动阅读模式
func read_pre(file_title,close_type = 1) -> SceneFileRead:
	
	self.close_type = close_type
	title_label.text = tr(file_title)
	if self.close_type == ALL_READED_CLOSE:
		key_tip.disable_key(KeyTipsBottom.keyType.key_b)
	next_page(true)
	return self
	

## 加入页面
func add_page(page_text:String):
	page_list.append(page_text)
	
## 下一页
func next_page(ingore_se:bool = false):
	if !nextable():
		_close_window()
		return
	page_index += 1
	render_content()
	if !ingore_se: AudioManager.play_turnpage()
	if closable(): key_tip.enable_key(KeyTipsBottom.keyType.key_b)
	if !nextable(): key_tip.disable_key(KeyTipsBottom.keyType.key_rt)
	if backable():key_tip.enable_key(KeyTipsBottom.keyType.key_lf)
	

	
func prev_page():
	page_index -= 1
	AudioManager.play_turnpage()
	render_content()
	if !backable():key_tip.disable_key(KeyTipsBottom.keyType.key_lf)
	if nextable(): key_tip.enable_key(KeyTipsBottom.keyType.key_rt)
	
func backable() -> bool:
	if page_index == 0:return false
	return true

## 是否可下一页
func nextable()-> bool:
	if page_index < page_list.size() -1: return true
	return false

## 是否可关闭的
func closable() -> bool:
	if close_type == ALL_READED_CLOSE && nextable():
		return false
	return true

## 开始阅读模式
# 当所有页面都加入数组后使用
func read_start():
	wait_input = true
	key_tip.disable_key(KeyTipsBottom.keyType.key_lf)
	self.show()

## 渲染内容
func render_content():
	var content = page_list[page_index]
	content_label.text = tr(content)

func _close_window():
	SceneManager.backto()
	
	
var input_triggered := false
	
func _input(event: InputEvent) -> void:
	if !wait_input :  return
	## 左右移动
	if event.is_action_pressed("left") && backable():
		prev_page()
	if event.is_action_pressed("right") && nextable():
		next_page()
	## 下一页
	if event.is_action_pressed("submit") && !input_triggered:
		self.input_triggered = true
		next_page()
	## 关闭reading_mode
	if event.is_action_pressed("cancel") && !input_triggered && closable():
		self.input_triggered = true
		_close_window()
	if event.is_released():
		self.input_triggered = false
