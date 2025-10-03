extends Area2D

class_name Pellet

signal pellet_eaten(pallet: Pellet)

@export var should_allow_eating_ghost = false

func _on_body_entered(body: Node2D):
	if body is Player:
		pellet_eaten.emit(self)
		queue_free()
		# TODO: add interaction with Player class to enable eating ghosts
		if should_allow_eating_ghost:
			pass
		
