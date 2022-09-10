package objects;

import flixel.FlxSprite;
import flixel.FlxObject;

/**
 * Base class for interactable objects, IMPORTANT! When extending 
 * use super() first before anything
 */
class InteractableSprite extends FlxSprite
{
    public var interactionHitbox:FlxObject;
    public var autoTriggered:Bool;
    public var interactionCount:Int;
    public var objectValues:Dynamic;

    public function new(X:Float, Y:Float)
    {
		  autoTriggered = false;
		  interactionCount = 0;
		  super(X,Y);
    }

    public function onInteraction()
    {
	    interactionCount++;
    }
}