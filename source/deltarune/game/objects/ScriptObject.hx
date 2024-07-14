package deltarune.game.objects;

import flixel.addons.editors.ogmo.FlxOgmo3Loader.EntityData;
import flixel.FlxObject;

import deltarune.scripting.GameScript;

#if hscript
class ScriptObject extends InteractableSprite
{
    public var script:GameScript;
    public var entity:EntityData;
	public function new(X:Float, Y:Float, Entity:EntityData, Values:Dynamic, Script:GameScript)
    {
        super(X, Y);
        objectValues = Values;
        entity = Entity;
        script = Script;
        script.setVariable('object', this);
        script.callFunction('objectCreate', [X, Y, Entity, Values]);
		if (interactionHitbox == null)
		{
			interactionHitbox = new FlxObject(X, Y, 0, 0);
        }
    }

    override public function update(elapsed:Float)
    {
        script.callFunction('update', [elapsed]);
		super.update(elapsed);
		script.callFunction('updatePost', [elapsed]);
    }

    override public function draw()
	{
		script.callFunction('draw', []);
        super.draw();
    }

    override public function destroy() {
        script.callFunction('destroy', []);
        super.destroy();
    }

    override public function onInteraction()
	{
        super.onInteraction();
		script.callFunction('onInteraction', [interactionCount]);
    }
}
#end