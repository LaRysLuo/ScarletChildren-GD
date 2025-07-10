extends Control
class_name StoryBook

const text = [
    "降魔山，那是恶魔降临的地方",
    "那一晚，雨下得很大，穿过迷雾环绕的树林后，就能找到那座洋馆",
    "那里住着一位美丽的少女，她给了我温饱，给了我财富，让一无所有的我拥有了荣华",
    "可是我没想到的是，这一切的代价却那么大",
    "诅咒随之降临——不仅是我，连同整个村子，都陷入了死亡的阴影中",
    "人们一个接一个无声地衰弱、死去，如同被无形的手一点点抽离了生命",
    "原以为是恩人的她，竟然是吞噬灵魂的恶魔",
    "马上就要轮到我",
    "我彷佛已经听见， 她那轻柔却冰冷的脚步声正在靠近我的床前……",
]


var label:Label:
    get: return get_node("Label")

var index:int = -1

## 当前文本
var current_text:String:
    get: return text[index]

func _ready() -> void:
    hide_message(0)
    await wait(1)
    next_message()

## 显示下一段信息
func next_message():
    if index >= text.size() - 1: 
        ## 故事结束了
        return 
    index+=1
    if label.text != "":
        await hide_message()
    label.text = current_text
    await show_message()
    await wait(current_text.length() * 0.2)
    next_message()

## 显示消息，把不透明变成1
func show_message(_duration:float = 0.5):
    var tween = create_tween()
    tween.tween_property(label,"modulate:a",1,_duration)
    tween.play()
    await tween.finished

func hide_message(_duration:float = 0.5):
    var tween = create_tween()
    tween.tween_property(label,"modulate:a",0,_duration)
    tween.play()
    await tween.finished

func wait(time:float):
    await get_tree().create_timer(time).timeout
