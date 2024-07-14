package deltarune.assets;

import openfl.display.BitmapData;
import openfl.media.Sound;
import openfl.text.Font;

import haxe.io.Bytes;

#if sys
import sys.io.File;
import sys.FileSystem;
#end

class SysAssetSystem implements IAssetSystem
{
    public var root:String;

    public function new(?root:String)
    {
        if (root == null) {
            #if sys
            this.root = Sys.getCwd() + '/assets';
            #else
            this.root = '';
            #end
        } else {
            this.root = root;
        }
    }

    public function list(directory:String, subdirectory:Bool = false):Array<String> {
        #if sys
		var dirs:Array<String> = FileSystem.readDirectory(directory);
        var i:Int = 0;
        while (dirs.length > i) {
            if (FileSystem.isDirectory(dirs[i])) {
                if (subdirectory)
                    dirs = dirs.concat(FileSystem.readDirectory(directory+'/'+dirs[i]));
                dirs.splice(i, 1);
            } else {
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

    public function exists(file:String):Bool {
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

    public function text(file:String):String {
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

    public function bytes(file:String):Bytes {
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

    public function font(file:String):Font {
        //some random file loading functions inside the respective classes (not openfl.Assets) dont use the openfl assets system? but not always?
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

    public function bitmap(image:String):BitmapData {
        //yet again, weird
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

    public function sound(sound:String):Sound {
        //...
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