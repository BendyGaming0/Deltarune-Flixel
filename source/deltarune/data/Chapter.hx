package deltarune.data;

import deltarune.assets.IAssetSystem;

class Chapter
{
	public var active:Bool = false;

	public var id(get, never):String;
	public var chapterId:String;
	public var group:String;

	public var previousChapter:String;

	public var rawDat:ChapterFile;

	public var assetsSystems:Array<IAssetSystem> = [];
	public var saveSelectStyles:Map<String, ChapterSaveSelectStyle> = [];

	function get_id():String
		return '$group;$chapterId';

	public function new(file:ChapterFile)
	{
		chapterId = file.id;
		group = file.group;
		previousChapter = file.previousChapter ?? '';
		for (style in Reflect.fields(file.saveStyles)) {
			saveSelectStyles.set(style, Reflect.field(file.saveStyles, style));
		}
		rawDat = file;
	}
}

typedef ChapterFile =
{
	var id:String;
	var group:String;
	var type:String;
	var ?previousChapter:String;
	var ?requiredChapters:Array<String>;
	var ?assetSystemImports:Array<String>;
	var chapterSelect:
		{
			var ?UIScript:String;
			var label:String; // can be language resource
			var title:String; // can be language resource
			var iconSuffix:String;
			var ?iconScale:Float;
			var ?bg:String; // can be language resource
			var ?bgScale:Float;
		};
	var ?saveCount:Int; // defaults to 1, 0 is no save, -1 is unlimited
	var ?saveStyles:Dynamic; // Map<String, ChapterSaveSelectStyle>
}

typedef ChapterSaveSelectStyle =
{
	var ?UIScript:String;
	var ?bgElements:Array<
		{
			var ?image:String;
			var ?shader:
				{
					var file:String;
					var properties:Dynamic;
				}
		}>;

	var saveBox:
		{
			var ?texture:String;
			var ?color:String;
			var ?width:Int;
			var ?height:Int;
			var ?spacing:Float;
		};
	var ?dialogs:
		{
			var ?fileSelect:String;
			var ?copyFrom:String;
			var ?copyTo:String;
			var ?overwriteFile:String;
			var ?eraseFile:String;
			var ?confirmStartFile:String;
			var ?cancelStartFile:String;
			var ?confirmNewFile:String;
			var ?cancelNewFile:String;
			var ?overwriteWarn:String;
			var ?confirmOverwrite:String;
			var ?cancelOverwrite:String;
			var ?eraseWarn:String;
			var ?confirmErase:String;
			var ?cancelErase:String;
			var ?reallyEraseWarn:String;
			var ?confirmReallyErase:String;
			var ?cancelReallyErase:String;
		}
	var ?chapterLabel:String;
	var ?creditInfo:String;
}
