extends PointLight2D
class_name FlashLight

var dirs = [ Vector2i.DOWN,Vector2i.LEFT,Vector2i.RIGHT,Vector2i.UP]

	
## 更新光线的方向
func refresh(dir:Vector2i):
	self.rotation = Vector2(dir).angle()
