package tools;

import openfl.display.BitmapData;
import sys.io.File;

using StringTools;

class PathGenerator
{
    public static function getCharacterImage(char:String)
    {
        return "assets/characters/"+char+"/spritesheet.png";
	}

	public static function getFont(font:String)
	{
		return "assets/fonts/"+font+".ttf";
	}

	public static function getImage(image:String, format:String = 'png')
	{
		return "assets/images/"+image+"."+format;
	}

	public static function getBitmapSys(image:String)
	{
		if (sys.FileSystem.exists(Sys.getCwd() + '/assets/images/' + image + '.png'))
		{
			return BitmapData.fromFile(Sys.getCwd() + '/assets/images/' + image + '.png');
		}
		return null;
	}

	public static function getJSON(file:String, folder:String = 'data', ext:String = 'json')
	{
		var coolContent = '{"vthrow":"Error occured while loading JSON"}';
		var json = {vthrow:"Failed to parse JSON"};
		if (sys.FileSystem.exists(Sys.getCwd() + '/assets/$folder/$file.$ext'))
			coolContent = File.getContent(Sys.getCwd() + '/assets/$folder/$file.$ext');
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
	 * @return a BitmapData of the file
	 */
	public static function getOgmoBitmap(ogmopath:String)
	{
		var fixedPath = Sys.getCwd() + ogmopath.replace('../', '/assets/');
		if (sys.FileSystem.exists(fixedPath))
		{
			return BitmapData.fromFile(fixedPath);
		}
		return null;
	}

	public static function getDialouge(file:String)
	{
		return Sys.getCwd() + "/assets/data/dialouge/"+file+".json";
	}

	public static var currentMusic:String = null;

	public static function getMusic(file:String)
	{
		currentMusic = file;
		return 'assets/music/'+file+'.ogg';
	}

	public static inline function getPortrait(character:String)
	{
		return Sys.getCwd() + '/assets/images/dialouge/$character.png';
	}

	public static function getTextSound(character:String = 'default')
	{
		var fixedPath = 'assets/sounds/text_' + character.split('-')[0] + '.wav';
		if (!sys.FileSystem.exists(fixedPath))
			fixedPath = 'assets/sounds/text_default.wav';
		return fixedPath;
	}
}