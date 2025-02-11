extends Area2D

func _on_body_entered(body: Node2D) -> void:
	print("collision")
	body.get_parent().kill()
