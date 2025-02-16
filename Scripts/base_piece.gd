class_name BasePiece
extends Node2D

signal died(pieceId: int)
@onready var cap_base: BaseCap = get_node("CapBase")
@onready var killCollission: CharacterBody2D = CharacterBody2D.new()
var tween: Tween = null
#func startTurn() -> void:
	#print("starting")
	#cap_base.startTurn()
func kill() -> void:
	var id = self.get_instance_id()
	if tween:
		tween.kill()
	tween = create_tween()
	tween.parallel().tween_property(cap_base, "linear_velocity", cap_base.linear_velocity * 0.3, 0)
	tween.parallel().tween_property(cap_base.spriteNode, "scale", Vector2(), 1)
	tween.tween_callback(self.queue_free)
	tween.tween_callback(func (): self.died.emit(id))

func _ready() -> void:
	killCollission.set_collision_layer_value(10, true)
	killCollission.set_collision_layer_value(1, false)
	killCollission.set_collision_mask_value(1, false)
	var circle = CircleShape2D.new()
	circle.radius = 10.0
	var centerCollision = CollisionShape2D.new()
	centerCollision.shape = circle
	centerCollision.position = cap_base.position
	killCollission.add_child(centerCollision)
	self.add_child(killCollission)

func _physics_process(delta: float) -> void:
	killCollission.move_and_collide(self.cap_base.linear_velocity * delta)
