extends Node

#these pieces should be passed in as props
var playerOnePieces := ["kumagama", "kumagama", "kumagama"]
var playerTwoPieces := ["kumagama", "kumagama", "kumagama"]
var pieceInstances: Array[GamePiece] = []
var curTurnIndex := 0
@onready var end_turn_button: Button = %EndTurnButton

func validPieceInstance(piece) -> bool:
	return is_instance_valid(piece) and not piece.is_queued_for_deletion()
	
func startPieceTurn(idx: int) -> void:
	print(idx)
	assert(idx < len(pieceInstances), "something went wrong with start turn order logic. Got index: " + str(idx))
	var curInstance := pieceInstances[idx]
	if validPieceInstance(curInstance.piece):
		curInstance.piece.get_node("CapBase").startTurn()
	else:
		curTurnIndex = (curTurnIndex + 1) % len(pieceInstances)
		startPieceTurn(curTurnIndex)
	
func endPieceTurn(idx: int) -> void:
	assert(idx < len(pieceInstances), "something went wrong with end turn order logic")
	pieceInstances[idx].piece.get_node("CapBase").endTurn()
	
func handleEndTurn() -> void:
	endPieceTurn(curTurnIndex)
	curTurnIndex = (curTurnIndex + 1) % len(pieceInstances)
	startPieceTurn(curTurnIndex)

func handlePieceDeath(id: int) -> void:
	var curPieceId := pieceInstances[curTurnIndex].piece.get_instance_id()
	#pieceInstances = pieceInstances.filter(func (instance: BasePiece): return instance.get_instance_id() != id)
	
	# if current playing piece dies, move onto next piece. Otherwise, wait for end turn
	if curPieceId == id:
		startPieceTurn(curTurnIndex)
	
	
func _ready() -> void:
	self.end_turn_button.pressed.connect(handleEndTurn)
	var playerOneCaps := self.get_node("%Player1Caps") as Node
	var playerTwoCaps := self.get_node("%Player2Caps") as Node
	var playerOneChildren := playerOneCaps.get_children()
	var playerTwoChildren := playerTwoCaps.get_children()
	for i in range(len(playerOneChildren)):
		var p1Child := playerOneChildren[i] as Node2D
		var p1Pos := p1Child.position
		p1Child.free()
		var p1Piece = ResourceLoader.load("res://Scenes/Caps/" + playerOnePieces[i] + ".tscn").instantiate() as BasePiece
		p1Piece.died.connect(handlePieceDeath)
		playerOneCaps.add_child(p1Piece)
		p1Piece.position = p1Pos
		var p1PieceObject = GamePiece.new()
		p1PieceObject.piece = p1Piece
		p1PieceObject.side = p1PieceObject.SIDE.P1
		
		var p2Child := playerTwoChildren[i] as Node2D
		var p2Pos := p2Child.position
		p2Child.free()
		var p2Piece := ResourceLoader.load("res://Scenes/Caps/" + playerTwoPieces[i] + ".tscn").instantiate() as BasePiece
		p2Piece.died.connect(handlePieceDeath)
		playerTwoCaps.add_child(p2Piece)
		p2Piece.position = p2Pos
		var p2PieceObject := GamePiece.new()
		p2PieceObject.piece = p2Piece
		p2PieceObject.side = p2PieceObject.SIDE.P2
		
		pieceInstances.append(p1PieceObject)
		pieceInstances.append(p2PieceObject)
	# waits for all pieces to load
	await get_tree().process_frame
	startPieceTurn(curTurnIndex)

func getVelocity(piece: BasePiece):
	var rigidBody := piece.get_node("CapBase") as BaseCap
	if not rigidBody:
		return 0
	return rigidBody.linear_velocity.length()
	
func _process(_delta: float) -> void:
	var sumVelocity = 0
	for piece in pieceInstances:
		# checks if piece was free'd
		if(validPieceInstance(piece.piece)):
			sumVelocity += getVelocity(piece.piece)
	if sumVelocity != 0:
		self.end_turn_button.hide()
	else:
		self.end_turn_button.show()
		
	
