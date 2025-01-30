extends CharacterBody2D


const SPEED = 3.0
const JUMP_VELOCITY = -4.0
var threshold := 0
var dragging := false

func calcDistanceToMouse(mousePos: Vector2):
	var distX = abs(mousePos.x - global_position.x)
	var distY = abs(mousePos.y - global_position.y)
	var radius = floor(sqrt(pow(distX, 2) + pow(distY, 2)))
	return radius
	
func _ready() -> void:
	var c = get_node('CollisionShape2D')
	threshold = c.shape.radius

func _input(event: InputEvent) -> void:
	var spriteNode = get_node("Sprite2D")
	if not spriteNode: return 
	if event is InputEventMouseButton:
		
		if event.is_pressed() and event.button_index == 1 and calcDistanceToMouse(event.global_position) < threshold:
			print("ok")
			
			
			#dragging = true
			#position = Vector2(-50, 0)

func _physics_process(delta: float) -> void:
	if dragging:
		print("dragging")
