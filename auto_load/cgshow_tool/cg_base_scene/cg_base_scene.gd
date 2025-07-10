extends Control
class_name CGBaseScene

var textureRect:TextureRect:
    get: return get_node("TextureRect")

func set_cg(_texture:Texture2D):
    textureRect.texture = _texture