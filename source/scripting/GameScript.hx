package scripting;

import states.PlayState;
import haxe.Exception;
import openfl.Assets;
#if hscript
import hscript.*;

import flixel.FlxSprite;

class GameScript extends Interp
{
    var parser:Parser;
    var expression:Expr;

    public function new()
    {
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
        trace('import added');
        setVariable("PlayState", PlayState);
        setVariable("FlxSprite", FlxSprite);
        setVariable("game", PlayState.instance);
        setVariable("startDialouge", function(content, id) {PlayState.instance.startDialouge(content);
			PlayState.instance.dielouge.dialougeProgressedCallback = function(num) {callFunction('dialougeProgressed', [id, num]);}
			PlayState.instance.dielouge.finishedCallback = function() {callFunction('dialougeEnded', [id]);}
        });
        setVariable("cancelFunction", function() {canceled = true;});
    }

    var extensions:Array<String> = [".hx", ".hxs", ".hsc", ".hscript", ".hxscript", ".haxescript"];

    public function loadFile(path:String)
    {
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
        return new Exception('File doesnt exist');
    }

    public var compiled(default, null):Bool = false;

    public function loadString(str:String)
    {
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
    }

    public var canceled:Bool = false;

    public function callFunction(functionName:String, arguments:Array<Dynamic>)
    {
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
            trace('${e.message}');
            return;
        }
    }

    public function setVariable(field:String, value:Dynamic)
    {
        return setVar(field, value);
    }

    public function getVariable(field:String)
    {
        return variables.get(field);
    }

    function fileExists(path:String)
		return #if sys sys.FileSystem.exists(Sys.getCwd() + '/' + path) #else Assets.exists(path) #end ;

	function getContents(path:String)
		return #if sys sys.io.File.getContent(Sys.getCwd() + '/' + path) #else Assets.getText(path) #end;
}
#end