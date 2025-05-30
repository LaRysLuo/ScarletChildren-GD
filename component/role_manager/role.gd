extends Resource
class_name  Role


## 角色名字
@export var role_name:String

@export var theme_color:Color

## 立绘
@export var tachie_normal:Texture2D # 普通
@export var tachie_smile:Texture2D # 微笑
@export var tachie_shy:Texture2D # 害羞
@export var tachie_cry:Texture2D # 哭泣
@export var tachie_surprise:Texture2D # 惊讶
@export var tachie_displeased:Texture2D # 不满
@export var tachie_sleepy:Texture2D # 困倦
@export var tachie_scared:Texture2D # 害怕
@export var tachie_puzzled:Texture2D # 疑惑
@export var tachie_speechless:Texture2D # 无语

## 角色简介
@export var desc:String

func get_tachie(id:int) -> Texture2D:
    match id:
        0: return tachie_normal
        1: return tachie_smile
        2: return tachie_shy
        3: return tachie_cry
        4: return tachie_surprise
        5: return tachie_displeased
        6: return tachie_sleepy
        7: return tachie_scared
        8: return tachie_puzzled
        9: return tachie_speechless
    return null