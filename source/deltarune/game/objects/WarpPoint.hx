package deltarune.game.objects;

import flixel.FlxObject;

import deltarune.game.states.PlayState;

class WarpPoint extends InteractableSprite
{
	public function new(X:Float, Y:Float, WIDTH:Float, HEIGHT:Float)
	{
		super(X, Y);
		//autoTriggered = true;
        visible = false;
		interactionHitbox = new FlxObject(X, Y, WIDTH, HEIGHT);
		trace('height:' + (HEIGHT));
	}

	override public function setPosition(x:Float = 0.0, y:Float = 0.0)
	{
		super.setPosition(x, y);
		interactionHitbox.setPosition(x, y);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		autoTriggered = true;
		interactionHitbox.setPosition(x, y);
	}

	override public function onInteraction()
	{
		if (interactionCount == 0) {
		    super.onInteraction();
			trace('going to room:' + objectValues.targetRoom + ' with tag' + objectValues.entranceTag);
			PlayState.instance.changeRoom(objectValues.targetRoom, objectValues.entranceTag, PlayState.instance.player.x - x, PlayState.instance.player.y - y);
        }
	}
}