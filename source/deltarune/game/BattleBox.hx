package deltarune.game;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import openfl.display.Graphics;

class BattleBox extends FlxObject
{
	public var showMiddle:Bool = false;
	public var tlCorner:Point<Float> = new Point<Float>(0, 0, 0);
	public var blCorner:Point<Float> = new Point<Float>(0, 0, 0);
	public var trCorner:Point<Float> = new Point<Float>(0, 0, 0);
	public var brCorner:Point<Float> = new Point<Float>(0, 0, 0);

	public var middlePoint(default, null):Point<Float> = new Point<Float>(0, 0, 0);

	public var fillColor:FlxColor = 0x000000;
	public var lineColor:FlxColor = 0x00EE11;

	public function new()
	{
		super(0, 0, 1, 1);
		tlCorner.x = blCorner.x = (FlxG.width * 0.5) - 100;
		trCorner.x = brCorner.x = (FlxG.width * 0.5) + 100;
		tlCorner.y = trCorner.y = (FlxG.height * 0.5) - 100;
		blCorner.y = brCorner.y = (FlxG.height * 0.5) + 100;
	}

	public function resetBox()
	{
		tlCorner.x = blCorner.x = (FlxG.width * 0.5) - 100;
		trCorner.x = brCorner.x = (FlxG.width * 0.5) + 100;
		tlCorner.y = trCorner.y = (FlxG.height * 0.5) - 100;
		blCorner.y = brCorner.y = (FlxG.height * 0.5) + 100;
	}

	override public function draw()
	{
		// dont call super, it really isn't needed as its for debugBoundingBoxes
		var gfx:Graphics = #if FLX_DEBUG beginDrawDebug(camera) #else null #end;

		gfx.moveTo(tlCorner.x, tlCorner.y);
		gfx.beginFill(fillColor);
		gfx.lineStyle(4, lineColor, 1, false, NORMAL, SQUARE, MITER);
		gfx.lineTo(blCorner.x, blCorner.y);
		gfx.lineTo(brCorner.x, brCorner.y);
		gfx.lineTo(trCorner.x, trCorner.y);
		gfx.lineTo(tlCorner.x, tlCorner.y);
		gfx.endFill();

		middlePoint = Point.findMiddle([tlCorner, trCorner, blCorner, brCorner]);

		if (showMiddle)
		{
			gfx.moveTo(middlePoint.x - 2, middlePoint.y - 2);
			gfx.beginFill(0xFFFFFF);
			gfx.lineStyle();
			gfx.lineTo(middlePoint.x - 2, middlePoint.y + 2);
			gfx.lineTo(middlePoint.x + 2, middlePoint.y + 2);
			gfx.lineTo(middlePoint.x + 2, middlePoint.y - 2);
			gfx.lineTo(middlePoint.x - 2, middlePoint.y - 2);
			gfx.endFill();
		}
		// var avrg = Point.multFloatNum(Point.addFloat(Point.addFloat(blCorner, brCorner), Point.addFloat(trCorner, tlCorner)), 0.25);

		endDrawDebug(camera);
	}
}

/*
 * simillar to a glsl vec3,
 * three properties with multiple accessors
 * tried my best to make it work with math functions
 */
class Point<T>
{
	public var x:T;
	public var y:T;
	public var z:T;
	public var r(get, set):T;
	public var g(get, set):T;
	public var b(get, set):T;

	function get_r()
		return x;

	function get_g()
		return y;

	function get_b()
		return z;

	function set_r(value:T)
		return x = value;

	function set_g(value:T)
		return y = value;

	function set_b(value:T)
		return z = value;

	public function new(?x:T, ?y:T, ?z:T)
	{
		if (x != null)
		{
			this.x = x;
		}
		if (y != null)
		{
			this.y = y;
		}
		if (z != null)
		{
			this.z = z;
		}
	}

	public static function fromFlxPoint(flixelPoint:FlxPoint, ?z:Float = 0):Point<Float>
	{
		var point = new Point<Float>(flixelPoint.x, flixelPoint.y, z);
		flixelPoint.putWeak();
		return point;
	}

	public static inline function distance(p:Point<Float>, point:Point<Float>)
	{
		return Math.sqrt(Math.pow((p.x - point.x), 2) + Math.pow((p.y - point.y), 2) + Math.pow((p.z - point.z), 2));
	}

	public static inline function distance2D(p:Point<Float>, point:Point<Float>)
	{
		return Math.sqrt(Math.pow((p.x - point.x), 2) + Math.pow((p.y - point.y), 2));
	}

	#if FLX_MOUSE
	public static inline function distanceMouse(p:Point<Float>)
	{
		return Math.sqrt(Math.pow((p.x - FlxG.mouse.viewX), 2) + Math.pow((p.y - FlxG.mouse.viewY), 2));
	}
	#end

	public static inline function findMiddle(points:Array<Point<Float>>)
	{
		var totalPoint = new Point<Float>();

		totalPoint.x = 0;
		totalPoint.y = 0;
		totalPoint.z = 0;

		for (pnt in points)
		{
			totalPoint.x += pnt.x;
			totalPoint.y += pnt.y;
			totalPoint.z += pnt.z;
		}

		totalPoint.x /= points.length;
		totalPoint.y /= points.length;
		totalPoint.z /= points.length;

		return totalPoint;
	}
	/*@:op(A + B) private static inline function add(lhs:Point<Int>, rhs:Point<Int>):Point<Int>
		{
			var point:Point<Int>;
			point.x = lhs.x + rhs.x;
			point.y = lhs.y + rhs.y;
			point.z = lhs.z + rhs.z;
			return point;
		}

		@:commutative @:op(A + B) private static inline function addIntFloat(lhs:Point<Int>, rhs:Point<Float>):Point<Float>
		{
			var point:Point<Float>;
			point.x = lhs.x + rhs.x;
			point.y = lhs.y + rhs.y;
			point.z = lhs.z + rhs.z;
			return point;
		}

		@:op(A + B) public static inline function addFloat(lhs:Point<Float>, rhs:Point<Float>):Point<Float>
		{
			var point:Point<Float>;
			point.x = lhs.x + rhs.x;
			point.y = lhs.y + rhs.y;
			point.z = lhs.z + rhs.z;
			return point;
		}


		@:op(A * B) private static inline function mult(lhs:Point<Int>, rhs:Point<Int>):Point<Int>
		{
			var point:Point<Int>;
			point.x = lhs.x * rhs.x;
			point.y = lhs.y * rhs.y;
			point.z = lhs.z * rhs.z;
			return point;
		}

		@:commutative @:op(A * B) private static inline function multIntFloat(lhs:Point<Int>, rhs:Point<Float>):Point<Float>
		{
			var point:Point<Float>;
			point.x = lhs.x * rhs.x;
			point.y = lhs.y * rhs.y;
			point.z = lhs.z * rhs.z;
			return point;
		}

		@:op(A * B) private static inline function multFloat(lhs:Point<Float>, rhs:Point<Float>):Point<Float>
		{
			var point:Point<Float>;
			point.x = lhs.x * rhs.x;
			point.y = lhs.y * rhs.y;
			point.z = lhs.z * rhs.z;
			return point;
		}

		@:op(A * B) private static inline function multNum(lhs:Point<Int>, rhs:Float):Point<Float>
		{
			var point:Point<Float>;
			point.x = lhs.x * rhs;
			point.y = lhs.y * rhs;
			point.z = lhs.z * rhs;
			return point;
		}

		@:op(A * B) private static inline function multNumInt(lhs:Point<Int>, rhs:Int):Point<Int>
		{
			var point:Point<Int>;
			point.x = lhs.x * rhs;
			point.y = lhs.y * rhs;
			point.z = lhs.z * rhs;
			return point;
		}

		@:op(A * B) public static inline function multFloatNum(lhs:Point<Float>, rhs:Float):Point<Float>
		{
			var point:Point<Float>;
			point.x = lhs.x * rhs;
			point.y = lhs.y * rhs;
			point.z = lhs.z * rhs;
			return point;
	}*/
}
