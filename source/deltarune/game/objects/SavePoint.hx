package deltarune.game.objects;

import deltarune.assets.GameAssets;
import deltarune.assets.Paths;
import deltarune.game.states.PlayState;
import flixel.FlxObject;

class SavePoint extends InteractableSprite
{
	public function new(X:Float, Y:Float)
	{
		super(X - 10, Y - 10);
		interactionHitbox = new FlxObject(X - 2, Y - 2, 44, 44);
		loadGraphic(GameAssets.bitmap(Paths.getImage('commonObjects')), true, 20, 20);
		animation.add('save', [0, 1, 2, 3, 4, 5], 4, true);
		animation.play('save');
		scale.x = 2;
		scale.y = 2;
		updateHitbox();
		immovable = true;
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		interactionHitbox.setPosition(x - 2, y - 2);
	}

	override public function onInteraction()
	{
		super.onInteraction();
		PlayState.instance.startDialogue('room_${PlayState.instance.levelString}_save');
	}
}
