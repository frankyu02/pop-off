class_name BaseCap

extends RigidBody2D

var dragging := false
var threshold := 0
var applied_forces = Vector2(0,0)
var friction = 0.8
var moving_force = 0.5
var label = null
var initialMousePosition: Vector2 = Vector2.ZERO
var releasedMousePosition: Vector2 = Vector2.ZERO
var spriteNode = null
var collisionNode = null
var arrow = preload("res://Scenes/arrow.tscn")
var arrowInstance := arrow.instantiate()
var launched := false

func calcDistanceToMouse(mousePos: Vector2):
	var distX = abs(mousePos.x - global_position.x)
	var distY = abs(mousePos.y - global_position.y)
	var radius = floor(sqrt(pow(distX, 2) + pow(distY, 2)))
	return radius

func scaleCap(factor: int) -> void:
	var spriteNode = get_node("AnimatedSprite2D")
	if spriteNode: spriteNode.scale = Vector2(factor, factor)
	if(collisionNode):
		# 64 bit sprites * scale factor / 2 for radius
		collisionNode.shape.radius = (64 * factor) / 2
	
func customOnReady() -> void:
	pass
	
func _ready() -> void:
	spriteNode = get_node("AnimatedSprite2D")
	collisionNode = get_node('CollisionShape2D')
	assert(collisionNode, "Inherited Caps should have ")
	threshold = collisionNode.shape.radius
	gravity_scale = 0
	lock_rotation = true
	label = self.find_child("VelocityLabel")
	#if(label): label.text = str(self.mass)
	if(label): 
		label.text = "Ready"
		label.set("theme_override_colors/font_color", Color.BLACK)
	 
	var weightLabel = self.find_child("WeightLabel")
	if weightLabel:
		weightLabel.text = str(self.friction)
		weightLabel.set("theme_override_colors/font_color", Color.BLACK)
	
	customOnReady()

func _input(event: InputEvent) -> void:
	var spriteNode = get_node("AnimatedSprite2D")
	assert(spriteNode, "Inherited Caps should have animated Sprite")
	if not spriteNode: return 
	if event is InputEventMouseButton:
		# don't allow movement while launching
		if launched:
			return
		if event.is_pressed() and event.button_index == 1 and calcDistanceToMouse(event.global_position) < threshold:
			initialMousePosition = event.global_position
			dragging = true
		if event.is_released() and event.button_index == 1 and initialMousePosition.length() != 0:
			releasedMousePosition = event.global_position
			dragging = false
			
func _physics_process(delta: float) -> void:
	if(linear_velocity.length() < 30):
		linear_velocity = Vector2.ZERO
		
	if linear_velocity.length() == 0 and label:
		label.text = str(linear_velocity.length())
	else:
		label.text = str(linear_velocity.length())
	
	if dragging:
		add_child(arrowInstance)
		arrowInstance.scale.x = self.spriteNode.scale.x
		var distance = get_global_mouse_position().distance_to(initialMousePosition)
		var dir = -(get_global_mouse_position() - initialMousePosition).normalized()
		#arrowInstance.position = Vector2(0, 0)
		# don't touch this. Idk what this means
		arrowInstance.rotation = dir.angle() - 270.2
		var distanceKey = distance / 100.0
		var gradient_data := {
		}
		gradient_data[0.0] = Color.RED
		gradient_data[distanceKey] = Color.BLACK
		var gradient := Gradient.new()
		gradient.offsets = gradient_data.keys()
		gradient.colors = gradient_data.values()
		
		var gradient_texture := GradientTexture2D.new()
		gradient_texture.gradient = gradient
		gradient_texture.gradient.interpolation_mode = Gradient.GRADIENT_INTERPOLATE_LINEAR
		arrowInstance.global_position = self.global_position
		arrowInstance.texture = gradient_texture
		if label: label.text = "Dragging"
	if not dragging:
		remove_child(arrowInstance)
		if releasedMousePosition.length() != 0:
			var dir = -(releasedMousePosition - initialMousePosition).normalized()
			var forcePercentage = min(100, floor(releasedMousePosition.distance_to(initialMousePosition)))
			#linear_velocity = dir * delta * 30000
			if forcePercentage > 5:
				launched = true
				apply_force(300 * forcePercentage * dir)
			releasedMousePosition = Vector2.ZERO
			initialMousePosition = Vector2.ZERO
	
		
		
