extends Node

#these pieces should be passed in as props
var playerOnePieces := ["kumagama", "kumagama", "kumagama"]
var playerTwoPieces := ["kumagama", "kumagama", "kumagama"]
var pieceInstances = []
var curTurn = 0
func _ready() -> void:
	var playerOneCaps = self.get_node("%Player1Caps")
	var playerTwoCaps = self.get_node("%Player2Caps")
	var playerOneChildren = playerOneCaps.get_children()
	var playerTwoChildren = playerTwoCaps.get_children()
	for i in range(len(playerOneChildren)):
		var p1Child = playerOneChildren[i]
		var p1Pos = p1Child.position
		p1Child.queue_free()
		var p1Piece = load("res://Scenes/Caps/" + playerOnePieces[i] + ".tscn").instantiate()
		playerOneCaps.add_child(p1Piece)
		p1Piece.position = p1Pos
		
		var p2Child = playerTwoChildren[i]
		var p2Pos = p2Child.position
		p2Child.queue_free()
		var p2Piece = await load("res://Scenes/Caps/" + playerTwoPieces[i] + ".tscn").instantiate()
		playerTwoCaps.add_child(p2Piece)
		p2Piece.position = p2Pos
		
		pieceInstances.append(p1Piece)
		pieceInstances.append(p2Piece)
	# waits for all pieces to load
	await get_tree().process_frame
	pieceInstances[curTurn].get_node("CapBase").startTurn()
