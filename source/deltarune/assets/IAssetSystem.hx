package deltarune.assets;

import openfl.display.BitmapData;
import openfl.media.Sound;
import openfl.text.Font;

import haxe.io.Bytes;

interface IAssetSystem
{
	public function list(directory:String, subdirectory:Bool = false):Array<String>;
	public function exists(file:String):Bool;
	public function directoryExists(directory:String):Bool;
	public function text(file:String):String;
	public function bytes(file:String):Bytes;
	public function font(file:String):Font;
	public function bitmap(image:String):BitmapData;
	public function sound(sound:String):Sound;
}