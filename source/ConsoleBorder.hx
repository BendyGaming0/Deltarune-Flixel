package;

import cpp.abi.Abi;
import openfl.display.Bitmap;
import openfl.geom.Rectangle;
import openfl.utils.Assets;
import openfl.events.Event;
import openfl.display.Sprite;

import openfl.display.Tile;
import openfl.display.Tilemap;
import openfl.display.Tileset;

class ConsoleBorder extends Sprite
{
	public static var ids:Map<String, Int> = [];
	public static var names:Map<Int, String> = [];

    public static var borderName:String;
    var bitmap:Bitmap;
    public var curId(default, null):Int;
    var nextId:Null<Int>;
    var state:String = 'done'; //fadeOut, fadeIn, done

	public function new()
	{
		super();

        bitmap = new Bitmap(Assets.getBitmapData('assets/images/borders.png'));
		addChild(bitmap);

		addBorder('default', 0);
		addBorder('forest', 1);
		addBorder('dark_castle', 2);
		addBorder('castle', 2);
		addBorder('sunset', 3);
		addBorder('cyber', 4);
		addBorder('queen_castle', 5);
		addBorder('queen', 5);
	}

	public function switchToId(id:Int = 0)
	{
		nextId = id;
		state = 'fadeOut';
	}

    public function switchTo(id:String = 'default')
    {
        if (ids.get(id) == curId) {return;}
		nextId = ids.get(id);
        if (nextId == null) {nextId = 0;}
        state = 'fadeOut';
    }

    function addBorder(name:String, id:Int)
    {
        ids.set(name, id);
        names.set(id, name);
    }

    override function __enterFrame(delta:Int)
    {
        super.__enterFrame(delta);
		bitmap.scaleX = bitmap.scaleY = Math.max(stage.stageWidth / 1920, stage.stageHeight / 1080);
		bitmap.x = (stage.stageWidth - (1924 * bitmap.scaleX)) / 2;
		bitmap.y = (stage.stageHeight - (1084 * bitmap.scaleY)) / 2;

		bitmap.y -= (1084 * bitmap.scaleY) * curId;

        var elapsed = delta / 1000;

        switch(state)
        {
            case 'fadeOut':
				bitmap.alpha -= elapsed * (1/0.6);
                if (bitmap.alpha <= 0)
                {
                    bitmap.alpha = 0;
                    state = 'fadeIn';
					curId = nextId;
                }
			case 'fadeIn':
				bitmap.alpha += elapsed * (1/0.6);
				if (bitmap.alpha >= 1)
				{
					bitmap.alpha = 1;
					state = 'done';
				}
            default:
                //prob done
        }
    }
}

class SingleBorder extends Tile
{
    var name(get, set):String;

    inline function get_name()
		return ConsoleBorder.names.get(id);

	inline function set_name(value:String)
	{
		id = ConsoleBorder.ids.get(value);
        return value;
	}

	function update(delta)
	{

	}
}