@tool
extends Control

var sprite_node_names
var selected_sprite_nodes: Array[bool] = []

var selected_library = ""
var lib_names: Array[StringName] = []

var animation_parts: Array[MSAFPart] = []

var checked_tex = preload("res://addons/modular_sprite_animation_factory/assets/checkbox-circle.png")
var unchecked_tex = preload("res://addons/modular_sprite_animation_factory/assets/checkbox-blank-circle.png")

var anim_player: AnimationPlayer


func setup_dock(node_names, animation_player):
	anim_player = animation_player
	sprite_node_names = node_names
	
	refresh_all()

func refresh_all():
	update_library_list()
	update_sprite_node_list()
	update_visible_anim()
	update_animation_list()
	%ChangeNotAppliedLabel.visible = false

func update_sprite_node_list():
	%SpriteNodeItemList.clear()
	selected_sprite_nodes.clear()
	
	var existing_selected_nodes: Array[String] = []
	var lib = anim_player.get_animation_library(selected_library)
	var has_animation = false
	# Check the first animation in the library, to set the default selected state of the sprite nodes
	if lib:
		if lib.get_animation_list().size() > 0:
			var first_anim = lib.get_animation(lib.get_animation_list()[0])
			has_animation = true
			for i in first_anim.get_track_count():
				var path = first_anim.track_get_path(i)
				if path.get_subname_count() > 0 and path.get_subname(0) == "frame" and path.get_name_count() > 0:
					existing_selected_nodes.append(path.get_name(0))
	
	for i in sprite_node_names.size():
		if !has_animation or existing_selected_nodes.has(sprite_node_names[i]):
			# If no animation in the library, default to true
			# Or existing animation contains the node track, then its true as well
			selected_sprite_nodes.append(true)
			%SpriteNodeItemList.add_item(sprite_node_names[i], checked_tex, true)
		else:
			selected_sprite_nodes.append(false)
			%SpriteNodeItemList.add_item(sprite_node_names[i], unchecked_tex, true)
			
		%SpriteNodeItemList.set_item_icon_modulate(i, Color.WHITE)
		
func update_library_list():
	lib_names = anim_player.get_animation_library_list()
	%LibraryItemList.clear()
	
	for i in lib_names.size():
		var item_string: String
		if lib_names[i] == "":
			item_string = "[Global]"
		else:
			item_string = lib_names[i]
			
		if lib_names[i] == selected_library:
			%LibraryItemList.select(i)
			item_string += " (selected)"
			
		%LibraryItemList.add_item(item_string, null, true)

func update_visible_anim():
	animation_parts.clear()
	var lib = anim_player.get_animation_library(selected_library)
	
	if !lib:
		return
	
	var visible_anims = lib.get_animation_list()
	
	# convert all animation to MSAFPart
	for anim_name in visible_anims:
		var animation = lib.get_animation(anim_name)
		
		var new_part = MSAFPart.new()
		new_part.animation_name = anim_name
		new_part.loop = animation.loop_mode != Animation.LOOP_NONE
		
		if animation.get_track_count() > 0:
			var key_count = animation.track_get_key_count(0)
			if key_count > 1:
				new_part.start_index = animation.track_get_key_value(0, 0)
				new_part.end_index = animation.track_get_key_value(0, key_count - 1)
				new_part.fps = key_count / animation.length
			else:
				new_part.start_index = animation.track_get_key_value(0, 0)
				new_part.end_index = animation.track_get_key_value(0, 0)
				new_part.fps = 1
		else:
			new_part.start_index = -1
			new_part.end_index = -1
			new_part.fps = -1
		
		animation_parts.append(new_part)

func update_animation_list():
	%AnimationItemList.clear()
	
	for anim_part in animation_parts:
		var item_string = anim_part.animation_name
		if anim_part.loop:
			item_string += " (loop)"
		if anim_part.fps > 0:
			item_string += " [%d - %d]" % [anim_part.start_index, anim_part.end_index]
			item_string += " %.2f fps" % anim_part.fps
		else:
			item_string += " [? - ?] ? fps"
			
		%AnimationItemList.add_item(item_string, null, true)

func _on_library_item_list_item_selected(index):
	var previously_selected_lib = selected_library
	
	if index < lib_names.size():
		selected_library = lib_names[index]
		
	if previously_selected_lib != selected_library:
		if selected_library == "":
			print("MSAF Selected library: [Global]")
		else:
			print("MSAF Selected library: ", selected_library)
		refresh_all()
	
func _on_sprite_node_item_list_item_selected(index):
	# toggle item
	if selected_sprite_nodes[index]:
		%SpriteNodeItemList.set_item_icon(index, unchecked_tex)
	else:
		%SpriteNodeItemList.set_item_icon(index, checked_tex)
	selected_sprite_nodes[index] = !selected_sprite_nodes[index]


func _on_select_all_button_pressed():
	print("MSAF select all sprite nodes")
	for i in sprite_node_names.size():
		%SpriteNodeItemList.set_item_icon(i, checked_tex)
		selected_sprite_nodes[i] = true

func _on_select_none_button_pressed():
	print("MSAF select none sprite nodes")
	for i in sprite_node_names.size():
		%SpriteNodeItemList.set_item_icon(i, unchecked_tex)
		selected_sprite_nodes[i] = false

func _on_delete_anim_button_pressed():
	var selected_item_indexes = %AnimationItemList.get_selected_items()
	if selected_item_indexes.size() > 0:
		var selected_index = selected_item_indexes[0]
		print("MSAF deleted animation: ", animation_parts[selected_index].animation_name)
		animation_parts.remove_at(selected_index)
	update_animation_list()
	%ChangeNotAppliedLabel.visible = true

func _on_add_anim_button_pressed():
	print("MSAF added new animation")
	
	if %AnimNameLineEdit.text == "" or %AnimNameLineEdit.text.contains("/"):
		$AcceptDialog.dialog_text = "Invalid animation name"
		%AcceptDialog.popup_centered()
		return
		
	if !%StartFrameLineEdit.text.is_valid_int() or !%EndFrameLineEdit.text.is_valid_int():
		$AcceptDialog.dialog_text = "Start and end frame needs to be integer"
		%AcceptDialog.popup_centered()
		return
	
	if !%FPSLineEdit.text.is_valid_float() and float(%FPSLineEdit.text) <= 0:
		$AcceptDialog.dialog_text = "Invalid FPS number"
		%AcceptDialog.popup_centered()
		return
		
	var new_part = MSAFPart.new()
	new_part.animation_name = %AnimNameLineEdit.text
	new_part.loop = %LoopCheckButton.button_pressed
	new_part.start_index = int(%StartFrameLineEdit.text)
	new_part.end_index = int(%EndFrameLineEdit.text)
	new_part.fps = float(%FPSLineEdit.text)
	animation_parts.append(new_part)
	
	update_animation_list()
	%ChangeNotAppliedLabel.visible = true

func _on_generate_button_pressed():
	var lib = anim_player.get_animation_library(selected_library)
	if !lib:
		$AcceptDialog.dialog_text = "No library selected"
		%AcceptDialog.popup_centered()
		return
	
	if %OverwriteCheckBox.button_pressed: # overwrite is checked
		for existing_anim in lib.get_animation_list():
			lib.remove_animation(existing_anim)
	
	for anim_part in animation_parts:
		if anim_part.fps <= 0:
			# invalid animation part, skip this one
			continue
		
		if lib.has_animation(anim_part.animation_name): # if already exist
			if !%OverwriteCheckBox.button_pressed: # overwrite is not checked
				continue # skip this one
			
		var animation = Animation.new()
		animation.length = float(anim_part.end_index - anim_part.start_index + 1) / anim_part.fps
		
		if anim_part.loop:
			animation.loop_mode = Animation.LOOP_LINEAR
		else:
			animation.loop_mode = Animation.LOOP_NONE
		
		for i in sprite_node_names.size():
			if !selected_sprite_nodes[i]:
				# this sprite node is not selected, skip it
				continue
				
			# add a track for each sprite node
			animation.add_track(Animation.TYPE_VALUE)
			animation.value_track_set_update_mode(i, Animation.UPDATE_DISCRETE)
			animation.track_set_path(i, "%s:frame" % sprite_node_names[i])

			# add a the frames to the track
			for j in range(anim_part.start_index, anim_part.end_index + 1):
				animation.track_insert_key(i, float(j - anim_part.start_index) / anim_part.fps, j)

		lib.add_animation(anim_part.animation_name, animation)
	
	%ChangeNotAppliedLabel.visible = false
	refresh_all()

func _on_refresh_button_pressed():
	refresh_all()
