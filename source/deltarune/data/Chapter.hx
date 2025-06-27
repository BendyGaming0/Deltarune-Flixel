package deltarune.data;

import deltarune.assets.IAssetSystem;

class Chapter
{
	public var active:Bool = false;

	public var id(get, never):String;
	public var chapterId:String;
	public var group:String;

	public var previousChapter:String;

	public var assetsSystems:Array<IAssetSystem> = [];

	function get_id():String
		return '$group:$chapterId';
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
	var ?saveSelect:ChapterSaveSelectStyle;
	var ?extraSaveStyles:Dynamic; // Map<String, ChapterSaveSelectStyle>
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
