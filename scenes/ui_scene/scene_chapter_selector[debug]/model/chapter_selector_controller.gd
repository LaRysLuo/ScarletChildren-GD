extends Resource
class_name ChapterSelector


## 章节选择器的字典
const _chapter_selector_dict = {
    "e1c1": {
        "scene": "蔷薇馆·中厅1F", ## 这是scene的symbol
        "items":[], ## 与进度相关的道具
        "ability":["running","open_main_menu"],## 玩家的功能解锁

    }
}


## 载入对应的章节
static func load_chapter(symbol:String):
    var chapter = _chapter_selector_dict.get(symbol)
    var scene_id = chapter.get("scene")
    await SceneManager.move(scene_id)
    await  GameManager.get_tree().process_frame

    var ability:Array[String] =  []
    for item in chapter.get("ability"):
        if item is String:
            ability.append(item)
    
    GameManager.game_player.player_ability = ability