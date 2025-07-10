extends PanelContainer

var item_grid:Control:
    get: return get_node("MarginContainer/VBoxContainer/VBoxContainer/HBoxContainer")

func _ready() -> void:
    _init_chapters()

func _init_chapters():
    var chapters = item_grid.get_children().filter(func(item): return item is ChapterItem)
    for chap:ChapterItem in chapters:
        chap.on_click.connect(_handle_chapter_clicked)
    pass

## 章节被点击时: 根据对应的章节symbol，生成对应章节的内容
func _handle_chapter_clicked(symbol:String):
    print("当前被点击的是，", symbol)
    ChapterSelector.load_chapter(symbol)
