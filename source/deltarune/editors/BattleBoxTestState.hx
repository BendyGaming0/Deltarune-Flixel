package deltarune.editors;

import deltarune.game.BattleBox;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.ui.FlxUIState;
import flixel.util.FlxColor;

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

	var cornersTouched:Array<Null<Int>> = [null, null, null, null];

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.keys.justPressed.ESCAPE || Controls.back.justPressed)
			FlxG.switchState(() -> new deltarune.game.states.MenuState());

		if (FlxG.keys.justPressed.SPACE)
			box.showMiddle = !box.showMiddle;

		if (FlxG.keys.justPressed.R)
			box.resetBox();

		#if FLX_MOUSE
		if (FlxG.mouse.justPressed)
		{
			var lowestDist = 1000.0;
			movingPoint = null;

			if (lowestDist > Point.distanceMouse(box.tlCorner))
			{
				lowestDist = Point.distanceMouse(box.tlCorner);
				movingPoint = box.tlCorner;
			}

			if (lowestDist > Point.distanceMouse(box.blCorner))
			{
				lowestDist = Point.distanceMouse(box.blCorner);
				movingPoint = box.blCorner;
			}

			if (lowestDist > Point.distanceMouse(box.trCorner))
			{
				lowestDist = Point.distanceMouse(box.trCorner);
				movingPoint = box.trCorner;
			}

			if (lowestDist > Point.distanceMouse(box.brCorner))
			{
				lowestDist = Point.distanceMouse(box.brCorner);
				movingPoint = box.brCorner;
			}
		}

		if (FlxG.mouse.pressed && movingPoint != null)
		{
			movingPoint.x = FlxG.mouse.viewX;
			movingPoint.y = FlxG.mouse.viewY;
		}
		#elseif FLX_TOUCH
		/*for (touch in FlxG.touches.justStarted())
			{
				var touchPoint = new Point<Float>(touch.screenX, touch.screenY, 0);
				var num = -1;

				var lowestDist = 800.0;
				movingPoint = null;

				if (cornersTouched[0] != null && lowestDist > Point.distance2D(box.tlCorner, touchPoint)) {
					lowestDist = Point.distance2D(box.tlCorner, touchPoint);
					num = 0;
				}

				if (cornersTouched[1] != null && lowestDist > Point.distance2D(box.blCorner, touchPoint)) {
					lowestDist = Point.distance2D(box.blCorner, touchPoint);
					num = 1;
				}

				if (cornersTouched[2] != null && lowestDist > Point.distance2D(box.trCorner, touchPoint)) {
					lowestDist = Point.distance2D(box.trCorner, touchPoint);
					num = 2;
				}

				if (cornersTouched[3] != null && lowestDist > Point.distance2D(box.brCorner, touchPoint)) {
					lowestDist = Point.distance2D(box.brCorner, touchPoint);
					num = 3;
				}

				
		}*/
		#end
	}
}
