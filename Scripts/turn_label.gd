extends RichTextLabel

@onready var game_manager: GameManager = %GameManager
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func handlePlayTurnSwitchAnimation(side: GamePiece.SIDE):
	if animation_player.is_playing():
		animation_player.stop()
	match side:
		GamePiece.SIDE.P1:
			self.clear()
			self.append_text("[color=#000000][color=#4ab3ff]P1's[/color] turn[/color]")
		GamePiece.SIDE.P2:
			self.clear()
			self.append_text("[color=#000000][color=#eb2214]P2's[/color] turn[/color]")
	self.animation_player.play("Show")
func _ready() -> void:
	self.bbcode_enabled = true
	self.z_index = 20
	self.game_manager.switchTurn.connect(handlePlayTurnSwitchAnimation)
