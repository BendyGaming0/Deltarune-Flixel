package;

import haxe.Template;
import flixel.FlxG;
import openfl.display.Graphics;
import flixel.util.FlxColor;
import flixel.FlxObject;

class BattleBox extends FlxObject
{
	var tlCorner:Point<Float>;
	var blCorner:Point<Float>;
	var trCorner:Point<Float>;
	var brCorner:Point<Float>;

	var fillColor:FlxColor = 0x000000;
    var lineColor:FlxColor = 0x00EE11;

    public function new()
    {
        super(0, 0, 1, 1);
		tlCorner.x = blCorner.x = FlxG.width * 0.3;
		trCorner.x = brCorner.x = FlxG.width * 0.7;
		tlCorner.y = trCorner.y = FlxG.height * 0.3;
		blCorner.y = brCorner.y = FlxG.height * 0.3;
    }

    public function resetBox()
    {
		tlCorner.x = blCorner.x = FlxG.width * 0.3;
		trCorner.x = brCorner.x = FlxG.width * 0.7;
		tlCorner.y = trCorner.y = FlxG.height * 0.3;
		blCorner.y = brCorner.y = FlxG.height * 0.3;
    }

    override public function draw()
    {
        //dont call super, it really isn't needed as its for debugBoundingBoxes
		var gfx:Graphics = beginDrawDebug(camera);
        
        gfx.moveTo(tlCorner.x, tlCorner.y);
        gfx.beginFill(fillColor);
		gfx.lineStyle(2, lineColor, 1);
		gfx.lineTo(blCorner.x, blCorner.y);
		gfx.lineTo(brCorner.x, brCorner.y);
		gfx.lineTo(trCorner.x, trCorner.y);
		gfx.lineTo(tlCorner.x, tlCorner.y);
        gfx.endFill();

		//var avrg = Point.multFloatNum(Point.addFloat(Point.addFloat(blCorner, brCorner), Point.addFloat(trCorner, tlCorner)), 0.25);

		endDrawDebug(camera);
    }
}

/*
 * simillar to a glsl vec3,
 * three properties with multiple accessors
 */
class Point<T>
{
    public var x:T;
	public var y:T;
	public var z:T;
	public var r(get, set):T;
	public var g(get, set):T;
	public var b(get, set):T;
	function get_r() return x;
	function get_g() return y;
	function get_b() return z;
	function set_r(value:T) return x = value;
	function set_g(value:T) return y = value;
	function set_b(value:T) return z = value;
    public function new () {}

    @:op(A + B) private static inline function add(lhs:Point<Int>, rhs:Point<Int>):Point<Int>
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
	}
}