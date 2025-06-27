package deltarune.scripting;

import flixel.FlxG;
import haxe.Exception;
#if hscript
import deltarune.game.states.PlayState;
import flixel.FlxSprite;
import hscript.*;
import openfl.Assets;

//idea, seperate this from hscript to allow other scripting languages
class GameScript #if hscript extends Interp #end
{
	public static var extensions(default, null):Array<String> = [".hx", ".hxc", ".hxs", ".hscript", ".hxscript", ".haxescript"];

	public var compiled(default, null):Bool = false;
	public var canceled:Bool = false;

	#if hscript
	var parser:Parser;
	var expression:Expr;
	#end
	
	public function new()
	{
		#if hscript
		super();

		parser = new Parser();

		setVariable("import", function(clPth:String)
		{
			var aliasSplit = clPth.split(' as ');
			var pathParts = aliasSplit[0].split('.');
			var className = pathParts.pop();
			var classAlias = aliasSplit[1] != null ? aliasSplit[1] : className;
			var classPath = pathParts.join('.');
			var impClass = Type.resolveClass(classPath + '.$className');
			var impEnum = Type.resolveEnum(classPath + '.$className');
			if (impEnum != null)
			{
				setVariable(classAlias, impEnum);
			}
			else
			{
				setVariable(classAlias, impClass);
			}
		});
		setVariable("PlayState", PlayState);
		setVariable("FlxSprite", FlxSprite);
		setVariable("InteractableSprite", deltarune.game.objects.InteractableSprite);
		setVariable("FlxG", FlxG);
		setVariable("game", PlayState.instance);
		setVariable("startDialogue", function(content, id)
		{
			PlayState.instance.startDialogue(content);
			PlayState.instance.dielogue.dialogueProgressedCallback = function(num)
			{
				callFunction('dialogueProgressed', [id, num]);
			}
			PlayState.instance.dielogue.finishedCallback = function()
			{
				callFunction('dialogueEnded', [id]);
			}
		});
		setVariable("cancelFunction", function()
		{
			canceled = true;
		});
		#else
		FlxG.log.warn("HScript is not supported on this platform");
		#end
	}

	public function loadFile(path:String)
	{
		#if hscript
		if (haxe.io.Path.extension(path) == '' && !fileExists(path))
		{
			for (ext in extensions)
			{
				if (fileExists(path + ext))
					path += ext;
			}
		}

		if (fileExists(path))
			return loadString(getContents(path));
		throw new Exception("Script File doesn't exist");
		#else
		FlxG.log.warn("HScript is not supported on this platform");
		#end
	}

	public function loadString(str:String)
	{
		#if hscript
		try
		{
			expression = parser.parseString(str);
			var toReturn:Dynamic = execute(expression);
			compiled = true;
			return toReturn;
		}
		catch (e)
		{
			trace('Failed to compile HScript');
			trace('${e.message}');
			return e;
		}
		#else
		FlxG.log.warn("HScript is not supported on this platform");
		#end
	}

	public function callFunction(functionName:String, arguments:Array<Dynamic>)
	{
		#if hscript
		canceled = false;
		var func:Dynamic = getVariable(functionName);
		try
		{
			if (func != null)
			{
				return func(arguments);
			}
			else
			{
				return;
			}
		}
		catch (e)
		{
			FlxG.log.error('${e.message}');
			return;
		}
		#else
		FlxG.log.warn("HScript is not supported on this platform");
		#end
	}

	public function setVariable(field:String, value:Dynamic)
	{
		#if hscript
		return setVar(field, value);
		#else
		FlxG.log.warn("HScript is not supported on this platform");
		#end
	}

	public function getVariable(field:String)
	{
		#if hscript
		return variables.get(field);
		#else
		FlxG.log.warn("HScript is not supported on this platform");
		#end
	}

	function fileExists(path:String)
		return #if sys sys.FileSystem.exists(Sys.getCwd() + '/' + path) #else Assets.exists(path) #end;

	function getContents(path:String)
		return #if sys sys.io.File.getContent(Sys.getCwd() + '/' + path) #else Assets.getText(path) #end;
}
#end
