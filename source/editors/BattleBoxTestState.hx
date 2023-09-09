package editors;

import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.addons.ui.FlxUIState;
import flixel.FlxSprite;
import BattleBox;

class BattleBoxTestState extends FlxUIState
{
    var box:BattleBox;
    var movingPoint:Point<Float>;

    override function create()
    {
        var bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.GRAY);
        add(bg);
        box = new BattleBox();
        add(box);
        super.create();
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        if (FlxG.keys.justPressed.ESCAPE || Controls.back.justPressed)
			FlxG.switchState(new states.MenuState());

		if (FlxG.keys.justPressed.SPACE)
			box.showMiddle = !box.showMiddle;

		if (FlxG.keys.justPressed.R)
			box.resetBox();

        if (FlxG.mouse.justPressed)
        {
            var lowestDist = 1000.0;
			movingPoint = null;

			if (lowestDist > Point.distanceMouse(box.tlCorner)) {
				lowestDist = Point.distanceMouse(box.tlCorner);
				movingPoint = box.tlCorner;
			}

			if (lowestDist > Point.distanceMouse(box.blCorner)) {
				lowestDist = Point.distanceMouse(box.blCorner);
				movingPoint = box.blCorner;
			}

			if (lowestDist > Point.distanceMouse(box.trCorner)) {
				lowestDist = Point.distanceMouse(box.trCorner);
				movingPoint = box.trCorner;
			}

			if (lowestDist > Point.distanceMouse(box.brCorner)) {
				lowestDist = Point.distanceMouse(box.brCorner);
				movingPoint = box.brCorner;
			}
        }

        if (FlxG.mouse.pressed && movingPoint != null)
        {
			movingPoint.x = FlxG.mouse.screenX;
			movingPoint.y = FlxG.mouse.screenY;
        }
    }
}