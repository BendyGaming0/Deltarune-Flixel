package deltarune.assets;

import haxe.io.Bytes;
import haxe.io.Path;
import openfl.Assets;
import openfl.display.BitmapData;
import openfl.media.Sound;
import openfl.text.Font;

using StringTools;

class OpenFLAssetSystem implements IAssetSystem
{
	public var label:String;
	public var root:String = 'assets';

	public function new(label:String, ?root:String)
	{
		this.label = label;

		if (root != null)
			this.root = root;
	}

	public function list(directory:String, subdirectory:Bool = false):Array<String>
	{
		while (directory.endsWith('/') || directory.endsWith('\\'))
		{
			directory = directory.substr(0, directory.length - 1);
		}

		var dirs:Array<String> = [];

		for (fileName in Assets.list())
		{
			var filePath = new Path(fileName);
			if (subdirectory ? filePath.dir.substr(root.length).startsWith(directory) : filePath.dir.substr(root.length) == directory)
				dirs.push(fileName.substring(directory.length));
		}

		return dirs;
	}

	public function exists(file:String):Bool
	{
		return Assets.exists('assets/${file}', null);
	}

	public function directoryExists(directory:String):Bool
	{
		for (fileName in Assets.list())
			if (fileName.substr(root.length).startsWith(directory))
				return true;
		return false;
	}

	public function text(file:String):String
	{
		return Assets.getText('assets/${file}');
	}

	public function bytes(file:String):Bytes
	{
		return Assets.getBytes('assets/${file}');
	}

	public function font(file:String):Font
	{
		return Assets.getFont('assets/${file}');
	}

	public function bitmap(image:String):BitmapData
	{
		return Assets.getBitmapData('assets/${image}');
	}

	public function sound(sound:String):Sound
	{
		return Assets.getSound('assets/${sound}');
	}
}
