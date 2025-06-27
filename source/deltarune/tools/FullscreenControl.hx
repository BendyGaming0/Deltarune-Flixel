package deltarune.tools;

import flixel.FlxBasic;
import flixel.FlxG;

// just allows F4/Alt+Enter/F11 to be pressed any time for fullscreen
class FullscreenControl extends FlxBasic
{
    public function new()
    {
        super();
    }

    public static function init()
    {
        FlxG.plugins.addIfUniqueType(new FullscreenControl());
    }

    override public function update(elapsed:Float)
    {
        if (FlxG.keys.justPressed.F4 || FlxG.keys.justPressed.F11 || (FlxG.keys.pressed.ALT && FlxG.keys.justPressed.ENTER)) {
            FlxG.fullscreen = !FlxG.fullscreen;
        }
    }
}
