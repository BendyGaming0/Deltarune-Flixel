package deltarune.game.objects;

import flixel.FlxObject;

/**
 * Used for pre-defined collision in the room
 */
class CollisionObject extends FlxObject
{
    public function new(X:Float, Y:Float, Width:Float, Height:Float)
    {
        super(X, Y, Width, Height);
        immovable = true;
    }
}