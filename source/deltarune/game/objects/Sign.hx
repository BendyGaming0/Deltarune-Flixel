package deltarune.game.objects;

import deltarune.assets.GameAssets;
import flixel.FlxObject;

import deltarune.game.states.PlayState;

import deltarune.assets.Paths;

class Sign extends InteractableSprite
{
    public function new(X:Float,Y:Float)
    {
        super(X-10,Y-10);
		interactionHitbox = new FlxObject(X-2,Y-2,44,44);
        loadGraphic(GameAssets.bitmap(Paths.getImage('commonObjects')), true, 20, 20);
        animation.add('sign',[8],1,true);
		animation.play('sign');
		scale.x = 2;
		scale.y = 2;
		updateHitbox();
		immovable = true;
    }

    override public function setPosition(x:Float = 0.0, y:Float = 0.0)
    {
		super.setPosition(x, y);
		interactionHitbox.setPosition(x-2, y-2);
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);
        interactionHitbox.setPosition(x-2,y-2);
    }

	override public function onInteraction()
	{
		super.onInteraction();
		PlayState.instance.startDialouge('room_${PlayState.instance.levelString}_sign${objectValues.dialouge}');
	}
}