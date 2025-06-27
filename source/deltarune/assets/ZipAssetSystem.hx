package deltarune.tools;

import haxe.io.Bytes;
import haxe.io.Input;
import haxe.io.Path;
import haxe.zip.Entry;
import haxe.zip.Reader;
import haxe.zip.Tools;
import lime.media.AudioBuffer;
import openfl.display.BitmapData;
import openfl.media.Sound;
import openfl.text.Font;

using StringTools;

class ZipAssetSystem implements IAssetSystem
{
	public var label:String;
	public var filePath:String;
	public var root:String = '';

	var entries:Map<String, Entry>;
	var directories:Array<String>;

	public function new(label:String, data:Input, ?root:String, decompress:Bool = false)
	{
		this.label = label;
		entries = new Map<String, Entry>();
		directories = new Array<String>();
		for (entry in Reader.readZip(data))
		{
			entries.set(entry.fileName, entry);
			var entryPath = new Path(entry.fileName);
			if (!directories.contains(entryPath.dir))
				directories.push(entryPath.dir);
		}
		if (decompress)
			decompressAll();
		if (root != null)
			this.root = root;
	}

	public function decompressAll()
	{
		for (entry in entries)
			Tools.uncompress(entry);
	}

	function decompressEntry(entry:Entry):Bytes
	{
		if (entry.compressed)
			Tools.uncompress(entry);
		return entry.data;
	}

	public function list(directory:String, subdirectory:Bool = false):Array<String>
	{
		while (directory.endsWith('/') || directory.endsWith('\\'))
			directory.substr(0, directory.length - 1);

		var dirs:Array<String> = [];

		for (fileName => entry in entries)
		{
			var filePath = new Path(fileName);
			if (subdirectory ? filePath.dir.startsWith(directory) : filePath.dir == directory)
				dirs.push(fileName.substring(directory.length));
		}

		return dirs;
	}

	public function exists(file:String):Bool
	{
		return entries.exists('${root}/${file}');
	}

	public function directoryExists(directory:String):Bool
	{
		return directories.contains(directory);
	}

	public function text(file:String):String
	{
		return bytes(file).toString();
	}

	public function bytes(file:String):Bytes
	{
		return decompressEntry(entries.get('${root}/${file}'));
	}

	public function font(file:String):Font
	{
		return Font.fromBytes(bytes(file));
	}

	public function bitmap(image:String):BitmapData
	{
		return BitmapData.fromBytes(bytes(image));
	}

	public function sound(sound:String):Sound
	{
		return Sound.fromAudioBuffer(AudioBuffer.fromBytes(bytes(sound)));
	}
}
