package deltarune.tools;

import flixel.FlxG;
import flixel.util.FlxSave;
import haxe.Exception;
import openfl.errors.Error;
import openfl.net.SharedObject;
import openfl.net.SharedObjectFlushStatus;

// variation of FlxSave that saves in the same directory as the application
// do not use on html (duh)

@:allow(flixel.util.LocalSharedObject)
class LocalSave extends FlxSave
{
	public function new()
	{
		super();
	}

	override public function bind(name:String, ?path:String, ?backupParser:(String, Exception) -> Null<Any>):Bool
	{
		destroy();

		name = FlxSave.validateAndWarn(name, "name");
		if (path != null)
			path = FlxSave.validateAndWarn(path, "path");

		try
		{
			_sharedObject = LocalSharedObject.getLocal(name, path);
			status = BOUND(name, path);
		}
		catch (e:Error)
		{
			FlxG.log.error('Error:${e.message} name:"$name", path:"$path".');
			destroy();
			return false;
		}
		data = _sharedObject.data;
		return true;
	}
}

@:access(openfl.net.SharedObject)
@:access(flixel.util.FlxSave)
private class LocalSharedObject extends SharedObject
{
	#if (flash || android || ios)
	/** Use SharedObject as usual */
	public static inline function getLocal(name:String, ?localPath:String):SharedObject
	{
		return SharedObject.getLocal(name, localPath);
	}

	public static inline function exists(name:String, ?path:String)
	{
		return true;
	}
	#else
	static var all:Map<String, LocalSharedObject>;

	static function init()
	{
		if (all == null)
		{
			all = new Map();

			var app = lime.app.Application.current;
			if (app != null)
				app.onExit.add(onExit);
		}
	}

	static function onExit(_)
	{
		for (sharedObject in all)
			sharedObject.flush();
	}

	/**
	 * Returns the company name listed in the Project.xml
	 */
	static function getDefaultLocalPath()
	{
		var meta = openfl.Lib.current.stage.application.meta;
		var path = meta["company"];
		if (path == null || path == "")
			path = "HaxeFlixel";
		else
			path = FlxSave.validate(path);

		return path;
	}

	public static function getLocal(name:String, ?localPath:String):SharedObject
	{
		if (name == null || name == "")
			throw new Error('Error: Invalid name:"$name".');

		if (localPath == null)
			localPath = "";

		var id = localPath + "/" + name;

		init();

		if (!all.exists(id))
		{
			var encodedData = null;

			try
			{
				if (~/(?:^|\/)\.\.\//.match(localPath))
					throw new Error("../ not allowed in localPath");

				encodedData = getData(name, localPath);
			}
			catch (e:Dynamic) {}

			if (localPath == "")
				localPath = getDefaultLocalPath();

			final sharedObject = new LocalSharedObject();
			sharedObject.data = {};
			sharedObject.__localPath = localPath;
			sharedObject.__name = name;

			if (encodedData != null && encodedData != "")
			{
				try
				{
					final unserializer = new haxe.Unserializer(encodedData);
					final resolver = {resolveEnum: Type.resolveEnum, resolveClass: SharedObject.__resolveClass};
					unserializer.setResolver(cast resolver);
					sharedObject.data = unserializer.unserialize();
				}
				catch (e:Dynamic) {}
			}

			all.set(id, sharedObject);
		}

		return all.get(id);
	}

	#if (js && html5)
	static function getData(name:String, ?localPath:String)
	{
		final storage = js.Browser.getLocalStorage();
		if (storage == null)
			return null;

		function get(path:String)
		{
			return storage.getItem(path + ":" + name);
		}

		// do not check for legacy saves when path is provided
		if (localPath != "")
			return get(localPath);

		var encodedData:String;
		// check default localPath
		encodedData = get(getDefaultLocalPath());
		if (encodedData != null)
			return encodedData;

		// check pre-5.0.0 default local path
		encodedData = get(js.Browser.window.location.pathname);
		if (encodedData != null)
			return encodedData;

		// check pre-4.6.0 default local path
		return get(js.Browser.window.location.href);
	}

	public static function exists(name:String, ?localPath:String)
	{
		final storage = js.Browser.getLocalStorage();

		if (storage == null)
			return false;

		inline function has(path:String)
		{
			return storage.getItem(path + ":" + name) != null;
		}

		return has(localPath)
			|| has(getDefaultLocalPath())
			|| has(js.Browser.window.location.pathname)
			|| has(js.Browser.window.location.href);
	}

	// should include every sys target
	#else
	static function getData(name:String, ?localPath:String)
	{
		var path = getPath(localPath, name);
		if (sys.FileSystem.exists(path))
			return sys.io.File.getContent(path);

		// No save found, check the legacy save path
		path = getLegacyPath(localPath, name);
		if (sys.FileSystem.exists(path))
			return sys.io.File.getContent(path);

		return null;
	}

	static function getPath(localPath:String, name:String):String
	{
		// Avoid ever putting .sol files directly in AppData
		if (localPath == "")
			localPath = getDefaultLocalPath();

		var directory = Sys.getCwd();
		var path = haxe.io.Path.normalize('$directory/$localPath') + "/";

		name = StringTools.replace(name, "//", "/");
		name = StringTools.replace(name, "//", "/");

		if (StringTools.startsWith(name, "/"))
		{
			name = name.substr(1);
		}

		if (StringTools.endsWith(name, "/"))
		{
			name = name.substring(0, name.length - 1);
		}

		if (name.indexOf("/") > -1)
		{
			var split = name.split("/");
			name = "";

			for (i in 0...(split.length - 1))
			{
				name += "#" + split[i] + "/";
			}

			name += split[split.length - 1];
		}

		return path + name + ".sol";
	}

	/**
	 * Whether the save exists, checks both the old and new path.
	 */
	public static inline function exists(name:String, ?localPath:String)
	{
		return newExists(localPath, name) || legacyExists(localPath, name);
	}

	/**
	 * Whether the save exists, checks the NEW location
	 */
	static inline function newExists(name:String, ?localPath:String)
	{
		return sys.FileSystem.exists(getPath(localPath, name));
	}

	static inline function getLegacyPath(localPath:String, name:String)
	{
		return SharedObject.__getPath(localPath, name);
	}

	/**
	 * Whether the save exists, checks the LEGACY location
	 */
	static inline function legacyExists(name:String, ?localPath:String)
	{
		return sys.FileSystem.exists(getLegacyPath(localPath, name));
	}

	override function flush(minDiskSpace:Int = 0)
	{
		if (Reflect.fields(data).length == 0)
		{
			return SharedObjectFlushStatus.FLUSHED;
		}

		var encodedData = haxe.Serializer.run(data);

		try
		{
			var path = getPath(__localPath, __name);
			var directory = haxe.io.Path.directory(path);

			if (!sys.FileSystem.exists(directory))
				SharedObject.__mkdir(directory);

			var output = sys.io.File.write(path, false);
			output.writeString(encodedData);
			output.close();
		}
		catch (e:Dynamic)
		{
			return SharedObjectFlushStatus.PENDING;
		}

		return SharedObjectFlushStatus.FLUSHED;
	}

	override function clear()
	{
		data = {};

		try
		{
			var path = getPath(__localPath, __name);

			if (sys.FileSystem.exists(path))
				sys.FileSystem.deleteFile(path);
		}
		catch (e:Dynamic) {}
	}
	#end
	#end
}
