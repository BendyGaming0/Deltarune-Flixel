package deltarune;

import deltarune.assets.GameAssets;
import flixel.math.FlxMath;
import openfl.system.System;
import deltarune.game.states.substates.Options;
import deltarune.assets.Paths;

import openfl.text.TextFormat;
import openfl.display.FPS;

/* 
 * Styled version of `openfl.display.FPS`
 */
class GameFps extends FPS
{
    public static var memoryPeak:Int = 0;

	@:noCompletion private var cachedMem:Int;

	var fpsText:String = '';
	var dcText:String = '';
	var memText:String = '';

    public function new()
    {
        super(10, 8, 0xFFFFFFFF);
		var format = new TextFormat(GameAssets.font(Paths.getFont('8bitoperator_jve')).fontName, 16, 0xFFFFFFFF);
		setTextFormat(format);
    }

    public override function __enterFrame(delta:Float)
	{
		currentTime += delta;
		times.push(currentTime);

		while (times[0] < currentTime - 1000)
		{
			times.shift();
		}

		var currentCount = times.length;
		currentFPS = Math.round((currentCount + cacheCount) / 2);

        var memoryUsed = System.totalMemory;
        if (memoryUsed > memoryPeak) {memoryPeak = memoryUsed;}

		if (Options.generalData.show_fps)
		{
			if (currentCount != cacheCount /*&& visible*/)
			{
				fpsText = "FPS: " + currentFPS;

				#if (gl_stats && !disable_cffi && (!html5 || !canvas))
				dcText = "\ntotalDC: " + Context3DStats.totalDrawCalls();
				dcText += "\nstageDC: " + Context3DStats.contextDrawCalls(DrawCallContext.STAGE);
				dcText += "\nstage3DDC: " + Context3DStats.contextDrawCalls(DrawCallContext.STAGE3D);
				#end
			}
		}

        if (Options.generalData.show_memory)
        {
			if (memoryUsed != cachedMem /*&& visible*/)
			{
                memText = '\nMemory: ${formatBytes(memoryUsed)}';
				memText += '\nMem Peak: ${formatBytes(memoryPeak)}';
            }
		}

        text = fpsText + dcText + memText;

        cachedMem = memoryUsed;
		cacheCount = currentCount;
    }

    public static function formatBytes(bytes:Int):String
    {
        if (bytes > 1000000000) { //GB
			return '${FlxMath.roundDecimal(bytes / 1000000000, 2)} GB';
        } else if (bytes > 1000000) { //MB
            return '${FlxMath.roundDecimal(bytes / 1000000, 2)} MB';
        } else if (bytes > 1000) { //KB
			return '${FlxMath.roundDecimal(bytes / 1000, 2)} KB';
        } else { //B
			return '${bytes} B';
        }
    }
}