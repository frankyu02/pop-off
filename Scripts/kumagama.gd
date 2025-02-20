extends BaseCap

func _init() -> void:
	self.mass = 1
	self.linear_damp = 0.5

func customOnReady():
	assert(self.collisionNode, "Inherited Caps should have CollisionNode2D")
	self.threshold = self.collisionNode.shape.radius
	self.scaleCap(0.8)
	
