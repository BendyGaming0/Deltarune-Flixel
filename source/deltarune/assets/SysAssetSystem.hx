package deltarune.assets;

import haxe.io.Bytes;
import openfl.display.BitmapData;
import openfl.media.Sound;
import openfl.text.Font;
#if sys
import sys.FileSystem;
import sys.io.File;
#end

class SysAssetSystem implements IAssetSystem
{
	public var label:String;
	public var root:String;

	public function new(label:String, ?root:String)
	{
		this.label = label;
		if (root == null)
		{
			#if sys
			#if android
			this.root = Sys.programPath();
			#else
			this.root = Sys.getCwd() + '/assets';
			#end
			#else
			this.root = '';
			#end
		}
		else
		{
			this.root = root;
		}
	}

	public function list(directory:String, subdirectory:Bool = false):Array<String>
	{
		#if sys
		var dirs:Array<String> = FileSystem.readDirectory('$root/$directory');
		var i:Int = 0;
		while (dirs.length > i)
		{
			if (FileSystem.isDirectory(dirs[i]))
			{
				if (subdirectory)
				{
					dirs = dirs.concat(FileSystem.readDirectory('$root/$directory/${dirs[i]}'));
				}
				dirs.splice(i, 1);
			}
			else
			{
				i++;
			}
		}

		return dirs;
		#else
		#if debug
		throw new NotImplementedException();
		#else
		return null;
		#end
		#end
	}

	public function exists(file:String):Bool
	{
		#if sys
		return FileSystem.exists('${root}/${file}') && !FileSystem.isDirectory('${root}/${file}');
		#else
		return false;
		#end
	}

	public function directoryExists(directory:String):Bool
	{
		#if sys
		return FileSystem.isDirectory('${root}/${directory}');
		#else
		return false;
		#end
	}

	public function text(file:String):String
	{
		#if sys
		return File.getContent('${root}/${file}');
		#else
		#if debug
		throw new NotImplementedException();
		#else
		return null;
		#end
		#end
	}

	public function bytes(file:String):Bytes
	{
		#if sys
		return File.getBytes('${root}/${file}');
		#else
		#if debug
		throw new NotImplementedException();
		#else
		return null;
		#end
		#end
	}

	public function font(file:String):Font
	{
		// some random file loading functions inside the respective classes (not openfl.Assets) dont use the openfl assets system? but not always?
		#if sys
		return Font.fromFile('${root}/${file}');
		#else
		#if debug
		throw new NotImplementedException();
		#else
		return null;
		#end
		#end
	}

	public function bitmap(image:String):BitmapData
	{
		// yet again, weird
		#if sys
		return BitmapData.fromFile('${root}/${image}');
		#else
		#if debug
		throw new NotImplementedException();
		#else
		return null;
		#end
		#end
	}

	public function sound(sound:String):Sound
	{
		// ...
		#if sys
		return Sound.fromFile('${root}/${sound}');
		#else
		#if debug
		throw new NotImplementedException();
		#else
		return null;
		#end
		#end
	}
}
