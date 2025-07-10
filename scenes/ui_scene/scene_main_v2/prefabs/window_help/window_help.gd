extends Control
class_name WindowHelp

var help_label:Label:
    get: return get_node("PanelContainer/MarginContainer/Label")

func _ready() -> void:
    hide()

func set_data(text:String):
    help_label.text = text


