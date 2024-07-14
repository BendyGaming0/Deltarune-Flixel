package deltarune.game.objects;

import flixel.FlxSprite;
import flixel.FlxObject;

/**
 * Base class for interactable objects, IMPORTANT! When extending 
 * use super() first before anything
 */
class InteractableSprite extends FlxSprite implements IInteractableSprite
{
    public var interactionHitbox:FlxObject;
    public var autoTriggered:Bool;
    public var interactionCount:Int;
    public var objectValues:Dynamic;

    public function new(X:Float, Y:Float)
    {
        autoTriggered = false;
        interactionCount = 0;
		objectValues = {};
        super(X,Y);
    }

    public function getInteractionHitbox():FlxObject
        return interactionHitbox;

    public function onInteraction()
	    interactionCount++;

    override public function destroy()
    {
        interactionHitbox.destroy();
		autoTriggered = false;
        objectValues = {};

        super.destroy();
    }
}

interface IInteractableSprite
{
    public var autoTriggered:Bool;
    public var interactionCount:Int;

    public function getInteractionHitbox():FlxObject;
    public function onInteraction():Void;
}