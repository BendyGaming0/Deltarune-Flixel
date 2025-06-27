package deltarune.assets;

import flixel.graphics.FlxGraphic;
import flixel.text.FlxBitmapFont;
import haxe.io.Bytes;
import openfl.display.BitmapData;
import openfl.media.Sound;
import openfl.text.Font;

class GameAssets
{
	public static var assetSystems:Array<IAssetSystem> = [];

	public static final supportedAudio:Array<String> = [
		"mp3",
		#if !html5 "ogg", #end 
		#if cpp "opus", #end
		"wav" ]; // missing .flac support...

	public static final supportedImage:Array<String> = []; // to-do, maybe write haxe decoder for QOI

	public static inline var MUSIC_EXT:String = #if html5 'mp3' #else 'ogg' #end;

	public static var cachedBitmapFonts:Map<String, FlxBitmapFont> = [];

	public static function graphic(image:String):FlxGraphic
	{
		for (assetSystem in assetSystems)
			if (assetSystem.exists(image))
				return FlxGraphic.fromBitmapData(assetSystem.bitmap(image), false, '', false);
		return null;
	}

	public static function bitmap(image:String):BitmapData
	{
		for (assetSystem in assetSystems)
			if (assetSystem.exists(image))
				return assetSystem.bitmap(image);
		return null;
	}

	public static function text(file:String):String
	{
		for (assetSystem in assetSystems)
			if (assetSystem.exists(file))
				return assetSystem.text(file);
		return null;
	}

	public static function sound(audio:String):Sound
	{
		for (assetSystem in assetSystems)
			if (assetSystem.exists(audio))
				return assetSystem.sound(audio);
		return null;
	}

	public static function music(audio:String):Sound
	{
		var path = '$audio.$MUSIC_EXT'; // redo this to support other formats
		for (assetSystem in assetSystems)
			if (assetSystem.exists(path))
				return assetSystem.sound(path);
		return null;
	}

	public static function font(font:String):Font
	{
		for (assetSystem in assetSystems)
			if (assetSystem.exists(font))
				return assetSystem.font(font);
		return null;
	}

	public static function bytes(file:String):Bytes
	{
		for (assetSystem in assetSystems)
			if (assetSystem.exists(file))
				return assetSystem.bytes(file);
		return null;
	}

	public static function exists(file:String):Bool // switch to Null<String> that includes the asset system label
	{
		for (assetSystem in assetSystems)
			if (assetSystem.exists(file))
				return true;
		return false;
	}

	// public static function musicExists(file:String):Bool
	// {
	//	for (assetSystem in assetSystems) {}
	// }

	public static function directoryExists(folder:String):Bool
	{
		for (assetSystem in assetSystems)
			if (assetSystem.directoryExists(folder))
				return true;
		return false;
	}

	/**
	 * [Description]
	 * List all files in a directory across all connected asset systems, removing duplicates
	 * 
	 * DOES NOT PREFIX FILES WITH SEARCH DIRECTORY!
	 * @param folder 
	 * @return Array<String>
	 */
	public static function list(folder:String, recursive:Bool = false):Array<String>
	{
		var files:Array<String> = [];

		for (assetSystem in assetSystems)
		{
			var assetSysFiles = assetSystem.list(folder, recursive);
			for (file in assetSysFiles)
			{
				if (!files.contains(file))
					files.push(file);
			}
		}

		return files;
	}
}
