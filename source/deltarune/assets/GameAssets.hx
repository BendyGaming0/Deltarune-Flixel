package deltarune.assets;

import haxe.io.Bytes;
import openfl.media.Sound;
import openfl.text.Font;
import openfl.display.BitmapData;
import flixel.graphics.FlxGraphic;

class GameAssets
{
    public static var assetSystems:Array<IAssetSystem> = [];

	public static inline var MUSIC_EXT:String = #if html5 'mp3' #else 'ogg' #end;
    
    public static function graphic(image:String):FlxGraphic
    {
        for (assetSystem in assetSystems)
			if (assetSystem.exists(image)) return FlxGraphic.fromBitmapData(assetSystem.bitmap(image), false, '', false);
        return null;
    }

    public static function bitmap(image:String):BitmapData
    {
        for (assetSystem in assetSystems)
			if (assetSystem.exists(image)) return assetSystem.bitmap(image);
        return null;
    }

    public static function text(file:String):String
    {
        for (assetSystem in assetSystems)
			if (assetSystem.exists(file)) return assetSystem.text(file);
        return null;
    }

	public static function sound(audio:String):Sound
    {
        for (assetSystem in assetSystems)
			if (assetSystem.exists(audio)) return assetSystem.sound(audio);
        return null;
    }

	public static function music(audio:String):Sound
    {
        var path = '$audio.$MUSIC_EXT';
        for (assetSystem in assetSystems)
			if (assetSystem.exists(path)) return assetSystem.sound(path);
        return null;
    }

    public static function font(font:String):Font
    {
        for (assetSystem in assetSystems)
			if (assetSystem.exists(font)) return assetSystem.font(font);
        return null;
    }

    public static function bytes(file:String):Bytes
    {
        for (assetSystem in assetSystems)
			if (assetSystem.exists(file)) return assetSystem.bytes(file);
        return null;
    }

    public static function exists(file:String):Bool {
        for (assetSystem in assetSystems)
            if (assetSystem.exists(file)) return true;
        return false;
    }

    public static function directoryExists(folder:String):Bool {
        for (assetSystem in assetSystems)
			if (assetSystem.directoryExists(folder)) return true;
        return false;
    }

    public static function list(folder:String):Array<String> {
        var files:Array<String> = [];

        for (assetSystem in assetSystems) {
            var assSysFiles = assetSystem.list(folder);
            for (file in assSysFiles) {
                if (!files.contains(file))
                    files.push(file);
            }
        }

        return files;
    }
}