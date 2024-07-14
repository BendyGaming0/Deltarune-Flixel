package deltarune.scripting;

import flixel.FlxG;
import haxe.Exception;

#if hscript
import hscript.*;

import flixel.FlxSprite;
import openfl.Assets;
import deltarune.game.states.PlayState;

class GameScript #if hscript extends Interp #end
{
    public static var extensions(default, null):Array<String> = [".hx", ".hxc", ".hxs", ".hscript", ".hxscript", ".haxescript"];

    public var compiled(default, null):Bool = false;
    public var canceled:Bool = false;

    var parser:Parser;
    var expression:Expr;

    public function new()
    {
        #if hscript
        super();

        parser = new Parser();

        setVariable("import", function(clPth:String) {
            var aliasSplit = clPth.split(' as ');
            var pathParts = aliasSplit[0].split('.');
            var className = pathParts.pop();
            var classAlias = aliasSplit[1] != null ? aliasSplit[1] : className;
            var classPath = pathParts.join('.');
            var impClass = Type.resolveClass(classPath + '.$className');
            var impEnum = Type.resolveEnum(classPath + '.$className');
            if (impEnum != null) {setVariable(classAlias, impEnum);} else {setVariable(classAlias, impClass);}
        });
        setVariable("PlayState", PlayState);
		setVariable("FlxSprite", FlxSprite);
		setVariable("InteractableSprite", deltarune.game.objects.InteractableSprite);
		setVariable("FlxG", FlxG);
        setVariable("game", PlayState.instance);
        setVariable("startDialouge", function(content, id) {PlayState.instance.startDialouge(content);
			PlayState.instance.dielouge.dialougeProgressedCallback = function(num) {callFunction('dialougeProgressed', [id, num]);}
			PlayState.instance.dielouge.finishedCallback = function() {callFunction('dialougeEnded', [id]);}
        });
        setVariable("cancelFunction", function() {canceled = true;});
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
        try {
			expression = parser.parseString(str);
			var toReturn:Dynamic = execute(expression);
            compiled = true;
            return toReturn;
        } catch(e) {
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
        try {
            if (func != null)
            {
                return func(arguments);
            } else {
                return;
            }
        } catch (e) {
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
		return #if sys sys.FileSystem.exists(Sys.getCwd() + '/' + path) #else Assets.exists(path) #end ;

	function getContents(path:String)
		return #if sys sys.io.File.getContent(Sys.getCwd() + '/' + path) #else Assets.getText(path) #end;
}
#end