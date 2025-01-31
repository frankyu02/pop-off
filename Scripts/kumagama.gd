extends BaseCap

func _init() -> void:
	self.mass = 1
	#self.mass = floor(RandomNumberGenerator.new().randf_range(1.0, 5.0))
	self.friction = RandomNumberGenerator.new().randf()
#func customOnReady() -> void:
	#self.scaleCap(5)
