package states;

import flixel.FlxG;
import flixel.addons.ui.FlxUIState;
import flixel.FlxSprite;

class BattleBoxTestState extends FlxUIState
{
    var box:BattleBox;

    override function create()
    {
        var bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height);
        add(bg);
        box = new BattleBox();
        super.create();
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        if (FlxG.keys.justPressed.ESCAPE || Controls.back.justPressed)
            FlxG.switchState(new states.MenuState());
    }
}