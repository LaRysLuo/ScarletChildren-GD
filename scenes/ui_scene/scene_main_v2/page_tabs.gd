extends HBoxContainer
class_name PageTabs

const PAGE_POINT_RES = preload("res://scenes/ui_scene/scene_main_v2/prefabs/page_point.tscn")

const PAGE_POINT_STYLE = preload("res://scenes/ui_scene/scene_main_v2/prefabs/page_point_style.tres")

const COLOR_NORMAL = Color("#a9a9a9")
const COLOR_CURRENT = Color("#CA828B")

## 根据当前的页数设定

var page_num:int = -1
var page_max:int = 0

var point_list = []


# 初始化页码
func init_page(_page_max:int,_page_num:int):
	self.page_num = _page_num
	self.page_max = _page_max
	_render_page_points()
	_refresh_page()

	
func update_page_num(index:int,from:int):
	self.page_num = index
	_refresh_page(from)

# 渲染页码点
func _render_page_points():
	for i in self.page_max:
		_render_page_point()

func _render_page_point():
	var p = PAGE_POINT_RES.instantiate()
	add_child(p)
	var style = PAGE_POINT_STYLE.duplicate()
	style.bg_color = COLOR_NORMAL
	p.add_theme_stylebox_override("panel",style)
	point_list.append(p)

# 刷新页码
func _refresh_page(from:int = -1):
	if from != -1:
		var old = point_list[from].get_theme_stylebox("panel")
		old.bg_color = COLOR_NORMAL
		point_list[from].add_theme_stylebox_override("panel",old)
	var style = point_list[self.page_num].get_theme_stylebox("panel")
	style.bg_color = COLOR_CURRENT
	point_list[self.page_num].add_theme_stylebox_override("panel",style)
