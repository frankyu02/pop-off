extends Node

#these pieces should be passed in as props
var playerOnePieces := ["kumagama", "kumagama", "kumagama"]
var playerTwoPieces := ["kumagama", "kumagama", "kumagama"]
var pieceInstances: Array[BasePiece] = []
var curTurnIndex := 0
@onready var end_turn_button: Button = %EndTurnButton

func startPieceTurn(idx: int) -> void:
	print(idx)
	assert(idx < len(pieceInstances), "something went wrong with start turn order logic. Got index: " + str(idx))
	var curInstance = pieceInstances[idx]
	if is_instance_valid(curInstance):
		curInstance.get_node("CapBase").startTurn()
	else:
		curTurnIndex = (curTurnIndex + 1) % len(pieceInstances)
		startPieceTurn(curTurnIndex)
	
func endPieceTurn(idx: int) -> void:
	assert(idx < len(pieceInstances), "something went wrong with end turn order logic")
	pieceInstances[idx].get_node("CapBase").endTurn()
	
func handleEndTurn() -> void:
	endPieceTurn(curTurnIndex)
	curTurnIndex = (curTurnIndex + 1) % len(pieceInstances)
	startPieceTurn(curTurnIndex)

func handlePieceDeath(id: int) -> void:
	var curPieceId = pieceInstances[curTurnIndex].get_instance_id()
	#pieceInstances = pieceInstances.filter(func (instance: BasePiece): return instance.get_instance_id() != id)
	
	# if current playing piece dies, move onto next piece. Otherwise, wait for end turn
	if curPieceId == id:
		startPieceTurn(curTurnIndex)
	
	
func _ready() -> void:
	self.end_turn_button.pressed.connect(handleEndTurn)
	var playerOneCaps = self.get_node("%Player1Caps")
	var playerTwoCaps = self.get_node("%Player2Caps")
	var playerOneChildren = playerOneCaps.get_children()
	var playerTwoChildren = playerTwoCaps.get_children()
	for i in range(len(playerOneChildren)):
		var p1Child = playerOneChildren[i]
		var p1Pos = p1Child.position
		p1Child.free()
		var p1Piece = ResourceLoader.load("res://Scenes/Caps/" + playerOnePieces[i] + ".tscn").instantiate() as BasePiece
		p1Piece.died.connect(handlePieceDeath)
		playerOneCaps.add_child(p1Piece)
		p1Piece.position = p1Pos
		
		var p2Child = playerTwoChildren[i]
		var p2Pos = p2Child.position
		p2Child.free()
		var p2Piece = ResourceLoader.load("res://Scenes/Caps/" + playerTwoPieces[i] + ".tscn").instantiate() as BasePiece
		p2Piece.died.connect(handlePieceDeath)
		playerTwoCaps.add_child(p2Piece)
		p2Piece.position = p2Pos
		
		pieceInstances.append(p1Piece)
		pieceInstances.append(p2Piece)
	# waits for all pieces to load
	await get_tree().process_frame
	startPieceTurn(curTurnIndex)

func getVelocity(piece: BasePiece):
	var rigidBody = piece.get_node("CapBase")
	if not rigidBody:
		return 0
	return rigidBody.linear_velocity.length()
	
func _process(_delta: float) -> void:
	var sumVelocity = 0
	for piece in pieceInstances:
		# checks if piece was free'd
		if(is_instance_valid(piece)):
			sumVelocity += getVelocity(piece)
	if sumVelocity != 0:
		self.end_turn_button.hide()
	else:
		self.end_turn_button.show()
		
	
