package;

import flixel.FlxObject;

class WarpPoint extends InteractableSprite
{
	public function new(X:Float, Y:Float, WIDTH:Float, HEIGHT:Float)
	{
		super(X, Y);
		//autoTriggered = true;
        visible = false;
		interactionHitbox = new FlxObject(X, Y, 10*WIDTH, 10*HEIGHT);
		trace('height:' + (10 * HEIGHT));
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