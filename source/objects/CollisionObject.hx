package objects;

import flixel.FlxObject;

class CollisionObject extends FlxObject
{
    public function new(X:Float, Y:Float, Width:Float, Height:Float)
    {
        super(X, Y, Width, Height);
        immovable = true;
    }
}