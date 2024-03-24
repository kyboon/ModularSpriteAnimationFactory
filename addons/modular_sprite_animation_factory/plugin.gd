@tool
extends EditorPlugin

const AUTOLOAD_NAME = "ModularSpriteAnimationFactory"

var dock

func _enter_tree():
	dock = preload("res://addons/modular_sprite_animation_factory/dock/msaf_dock.tscn").instantiate()

func _exit_tree():
	dock.queue_free()
	
func _handles(object):
	return object_is_valid_candidate(object)

func _edit(object):
	if object:
		if !dock.get_parent():
			add_control_to_dock(EditorPlugin.DOCK_SLOT_RIGHT_UL, dock)
			
		var sprite_children = get_sprite_2d_children(object)
		var anim_children = get_anim_player_children(object)
		dock.setup_dock(sprite_children.map(get_node_name), anim_children[0])
	else:
		remove_control_from_docks(dock)

func object_is_valid_candidate(object):
	# The heirachy should be as below
	# - Node2D
	#	- AnimationPlayer
	#	- Sprite2D 1
	#	- Sprite2D 2
	#	- ...
	
	# When selected the parent Node2D, handles it
	if object and object is Node2D:
		var children = object.get_children()
		return children.any(is_anim_player) and children.any(is_sprite_2d)
	return false
	
func is_sprite_2d(object):
	return object is Sprite2D
	
func is_anim_player(object):
	return object is AnimationPlayer
	
func get_node_name(object):
	return object.name
	
func get_sprite_2d_children(object: Node2D):
	var children = object.get_children()
	return children.filter(is_sprite_2d)
	
func get_anim_player_children(object: Node2D):
	var children = object.get_children()
	return children.filter(is_anim_player)
