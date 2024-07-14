package deltarune.game.objects;

import flixel.FlxObject;

import deltarune.game.states.PlayState;

/**
 * An Object that when interacted with opens a dialouge box
 */
class InvisibleSign extends InteractableSprite
{
    public function new(X:Float,Y:Float,WIDTH:Float,HEIGHT:Float)
    {
        super(X,Y);
		interactionHitbox = new FlxObject(X, Y, 10*WIDTH, 10*HEIGHT);
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);
        interactionHitbox.setPosition(x,y);
    }

	override public function onInteraction()
	{
		super.onInteraction();
		PlayState.instance.startDialouge('room_${PlayState.instance.levelString}_sign${objectValues.dialouge}');
	}
}