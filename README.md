# ModularSpriteAnimationFactory
![NeonCatIcon](https://github.com/kyboon/ModularSpriteAnimationFactory/blob/master/addons/modular_sprite_animation_factory/msaf_logo.png)

A Godot 4 plugin to generate animations for modular 2d sprites. Generated animations will have multiple tracks, one for each Sprite2D node.

## Installation
1. Download the plugin from github and place the `addons` directory to your Godot project root folder. Alternatively, you can install it from the `AssetLib` in the Godot editor.
2. In the Godot editor, go to `Project` > `Project Settings` > `Plugins` and enable `Modular Sprite Animation Factory`.

## Usage
1. Prepare your sprites. Split it to different parts and convert them to white (or greyscale). Example below:
   
   Original:
   ![Original](https://github.com/kyboon/ModularSpriteAnimationFactory/blob/master/example/assets/character_base_16x16.png)
   Head:
   ![Head](https://github.com/kyboon/ModularSpriteAnimationFactory/blob/master/example/assets/character_base_head.png)
   Body:
   ![Head](https://github.com/kyboon/ModularSpriteAnimationFactory/blob/master/example/assets/character_base_body.png)
   Eyes:
   ![Head](https://github.com/kyboon/ModularSpriteAnimationFactory/blob/master/example/assets/character_base_eyes.png)
   Outline:
   ![Head](https://github.com/kyboon/ModularSpriteAnimationFactory/blob/master/example/assets/character_base_outlines.png)
   
2. Setup your nodes, it has to be a `Node2D`, **contains an `AnimationPlayer` and at least a `Sprite2D`** among its children. It's recommended to name the `Sprite2D`s accordingly. Example below:
   
   - `Node2D`
       - `AnimationPlayer`
       - `Sprite2D`
       - `Sprite2D`
       - ... more `Sprite2D`s
         
    ![image](https://github.com/kyboon/ModularSpriteAnimationFactory/assets/24255335/c5050f25-0de4-4c87-ba66-6975068d67ed)
3. Set the textures of the `Sprite2D`s with your sprites. And set the Hframes and Vframes (under the `Sprite2D > Animation` section), in the example it's a 4x4 spritesheet.
   
   ![image](https://github.com/kyboon/ModularSpriteAnimationFactory/assets/24255335/03a9659c-f43c-424b-a997-981b6bbd1a71)

4. You can now customize your character by setting different colors to each part of the sprite. To do so, in the `CanvasItem > Visibility` section, change the modulate color. You can also change that via a script. Alternatively, you can also customize your character by changing the texture. For example, you can have a `Sprite2D` node named `Hat`, and you can change the character's hat to different styles, instead of just changing the hat color.
   
   ![image](https://github.com/kyboon/ModularSpriteAnimationFactory/assets/24255335/2ad46b56-953e-4cd3-8344-af3e188a8624)
   ![image](https://github.com/kyboon/ModularSpriteAnimationFactory/assets/24255335/ff7a6a07-c91e-47ef-a7eb-7ee72fcfc041)
  
5. When you select the root Node2D, a tab will apear on the right panel, named `MSAF`. You can then manage and generate animations using it.
   
   ![image](https://github.com/kyboon/ModularSpriteAnimationFactory/assets/24255335/534c81bf-99f8-450d-8a85-a35ffd3902e2)

6. The result of the generated animation:

   ![image](https://github.com/kyboon/ModularSpriteAnimationFactory/assets/24255335/d2c96a0b-db67-4e16-ade0-01085408a640)

