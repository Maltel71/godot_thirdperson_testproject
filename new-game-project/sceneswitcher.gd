extends Area3D

# This exports a variable to the Inspector, allowing you to select the scene file.
@export_file("*.tscn") var target_scene_path: String

# The name of the player node we're looking for.
const PLAYER_NAME = "Player"

func _on_body_entered(body: Node3D):
	# Check if the name of the node that entered the Area3D matches "Player".
	if body.name == PLAYER_NAME:
		# Use the exported scene path to switch scenes.
		get_tree().change_scene_to_file(target_scene_path)
