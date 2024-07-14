package deltarune.assets;

import openfl.display.BitmapData;

#if sys
import sys.io.File;
#end

using StringTools;

class Paths
{
	public static var currentMusic:String = null;

    public static function getCharacterImage(char:String)
        return 'characters/$char/spritesheet.png';

	public static function getFont(font:String)
		return 'fonts/$font.ttf';

	public static function getImage(image:String, format:String = 'png')
		return 'images/$image.$format';

	public static function getDialouge(file:String)
		return 'data/dialouge/$file.json';

	public static function getMusic(file:String) {
		currentMusic = file;
		return 'music/$file';
	}

	public static inline function getPortrait(character:String)
		return 'images/dialouge/$character.png';

	public static function getBitmapSys(image:String) {
		if (GameAssets.exists('/images/$image.png'))
			return GameAssets.bitmap('/images/' + image + '.png');
		return null;
	}

	public static function getJSON(file:String, folder:String = 'data', ext:String = 'json'):Dynamic {
		var coolContent = '{"vthrow":"Error occured while loading JSON"}';
		var json = {vthrow:"Failed to parse JSON"};
		if (GameAssets.exists('$folder/$file.$ext'))
			coolContent = GameAssets.text('$folder/$file.$ext');
		try
		{
			json = haxe.Json.parse(coolContent);
		}
		catch(e)
		{
			trace('failed to parse JSON');
			trace('throw error:'+e.message);
			return null;
		}
		return json;
	}

	/**
	 * [Description]
	 * @param ogmopath the path according to ogmo editor eg: ../images/cyberassetsmini.png to C:/gamedir/assets/images/cyberassetsmini.png
	 * @return a String of the path
	 */
	public static function getOgmoBitmap(path:String, fileLocation:String)
	{
		var fixedPath = Sys.getCwd() + path.replace('../', '/assets/');
		if (GameAssets.exists(fixedPath))
		{
			return GameAssets.bitmap(fixedPath);
		}
		return null;
	}

	public static function getTextSound(character:String = 'default')
	{
		var fixedPath = 'sounds/text_' + character.split('-')[0] + '.wav';
		if (!GameAssets.exists(fixedPath))
			fixedPath = 'sounds/text_default.wav';
		return fixedPath;
	}
}