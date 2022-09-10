package;

import tools.PathGenerator;
import openfl.Assets;
import flixel.system.FlxSound;
import flixel.math.FlxPoint;
import openfl.display.BitmapData;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.input.keyboard.FlxKey;
import flixel.util.typeLimit.OneOfTwo;
import flixel.text.FlxText;
import flixel.group.FlxSpriteGroup;
import flixel.FlxSprite;
import flixel.addons.text.FlxTypeText;
import states.PlayState;

typedef DialougeStructure = {
    var style:String;
	var dialouge:Array<DialougeLine>;
}

typedef DialougeLine = {
    var portrait:String;
    var text:String;
    var speed:Float;
    var pausespeed:Float;
    var autocontinue:Bool;
    var skippable:Bool;
}

typedef DialougeFile = OneOfTwo<DialougeStructure, String>;

class DeltaDialougeBox extends FlxSpriteGroup {
    //sprite order
    var background:FlxSprite;
    var portrait:FlxSprite;
    var astrix:FlxText;
    var typetext:FlxTypeText;

    var shadowPow:Int = 1;

    var nicedialouge:DialougeStructure;

    var dialougeIndex:Int;

    var linefinished:Bool;

    public var activated(default, set):Bool;

    function set_activated(value:Bool)
    {
        if (typetext != null) {
			for (sound in typetext.sounds)
				sound.volume = value ? 1 : 0;
        }
		activated = value;
		return value;
    }

    public var finishedCallback:Void->Void;
    public var dialougeProgressedCallback:Int->Void;

    var defaultfile:DialougeStructure =
    {
        style: "darkworld",
        dialouge: [
            {
                portrait: "none",
                text: "dialouge failed to load, please check the path/json",
                speed: 1,
                pausespeed: 1,
                autocontinue: false,
				skippable: true
            },
        ]
    };

	public function new(X:Float = 0, Y:Float = 0, dialouge : DialougeFile)
	{
        super();
        constructor(dialouge);
    }

	public function reconstruct(dialouge : DialougeFile)
	{
        remove(background);
        background.destroy();
        remove(portrait);
        portrait.destroy();
        remove(astrix);
        astrix.destroy();
        remove(typetext);
        typetext.destroy();
        constructor(dialouge);
    }

	function constructor(dialouge : DialougeFile)
	{
		if ((dialouge is String))
		{
            var jsonstr:String = dialouge;
            if (sys.FileSystem.exists(dialouge))
                jsonstr = sys.io.File.getContent(dialouge);
            try
            {
                nicedialouge = haxe.Json.parse(jsonstr);
            }
            catch(e:Any)
            {
                trace('failed to parse dialouge');
                nicedialouge = defaultfile;
            }
        }
        else
			nicedialouge = dialouge;
		activated = false;
        dialougeIndex = 0;
		linefinished = false;

        trace('DIALOUGE FILE LOADED');

		background = new FlxSprite(0, 0, "assets/images/" + nicedialouge.style + "Box.png");
		if (nicedialouge.style == "darkworld")
		{
			background.offset.x = 8;
			background.offset.y = 8;
        }
		background.scale.x = 2;
		background.scale.y = 2;
        background.antialiasing = false;
        background.updateHitbox();

		add(background);

		trace('BOX LOADED');

		portrait = new FlxSprite(0, 0);
		portrait.scale.x = 2;
		portrait.scale.y = 2;
        portrait.antialiasing = false;
        portrait.updateHitbox();

		add(portrait);

		trace('PORTRAIT CREATED');

		astrix = new FlxText(24, 26, 48, "*");
		astrix.setFormat(PathGenerator.getFont("8bitoperator_jve"), 32, FlxColor.WHITE, LEFT);
		astrix.antialiasing = false;
		astrix.setBorderStyle(SHADOW, 0xFF171769, 1, 1);
		astrix.shadowOffset.x = shadowPow;
		astrix.shadowOffset.y = shadowPow;

        add(astrix);

		typetext = new FlxTypeText(52, 24, 496, getCurrentLine().text); // x, y, width
		typetext.setFormat(PathGenerator.getFont("8bitoperator_jve"), 32, FlxColor.WHITE, LEFT);
		typetext.antialiasing = false;
		typetext.start(0.06 / getCurrentLine().speed, true, false, [], dialougeLineFinished);
		typetext.setBorderStyle(SHADOW, 0xFF171769, 1, 1);
		typetext.shadowOffset.x = shadowPow;
		typetext.shadowOffset.y = shadowPow;

		add(typetext);

		trace('TEXT CREATED');

		dialougeIndex = -1;
		continueDialouge();

		trace('EVERYTHING HAS BEEN LOADED!');
    }

    var disableControls:Bool = false;

	override public function update(elapsed:Float)
    {
        super.update(elapsed);

		if (FlxG.keys.justPressed.R && Main.args.contains('debugmode') && !disableControls)
        {
            activated = true;
            dialougeIndex = -1;
            continueDialouge();
        }

        if (PlayState.instance != null) {
            if (!activated) {
                if (PlayState.instance.player.controlArray.contains('dialouge'))
                    PlayState.instance.player.controlArray.remove('dialouge');
                return;
            }
            else if (!PlayState.instance.player.controlArray.contains('dialouge')) {
                PlayState.instance.player.controlArray.push('dialouge');
            }
        }


		if ((Controls.primary.justPressed || Controls.secondary.pressed || Controls.tetritary.pressed && !disableControls)
			&& !linefinished && getCurrentLine().skippable)
		{
            typetext.skip();
        }

		if ((Controls.primary.justPressed || Controls.tetritary.pressed) && linefinished && !disableControls)
		{
            continueDialouge();
        }
    }

    function position(start:Float)
    {
        return start + getCurrentLine().portrait == "none" ? 0 : 100;
    }

    function positionSprite(sprite:FlxSprite, xv:Float = null, yv:Float = null)
    {
        if (xv != null)
            sprite.x = xv + x - offset.x;
		if (yv != null)
			sprite.y = yv + y - offset.y;
    }

    function getSpritePosition(sprite:FlxSprite)
    {
		return new FlxPoint(sprite.x, sprite.y).subtract(x - offset.x, y - offset.y);
    }

    public function dialougeLineFinished()
    {
		linefinished = true;
		if (getCurrentLine().autocontinue && !disableControls)
			continueDialouge();
    }

    public function continueDialouge(?reset:Bool = false)
    {
		linefinished = false;

		if (dialougeIndex + 1 >= nicedialouge.dialouge.length && !reset)
		{
            activated = false;
			if (finishedCallback != null)
                finishedCallback();
        }
        else
        {
            if (!reset)
                dialougeIndex++;
			if (dialougeProgressedCallback != null)
			    dialougeProgressedCallback(dialougeIndex);

			updatePortrait();

			typetext.resetText(getCurrentLine().text);
			typetext.start(0.06 / getCurrentLine().speed, true, false, [], dialougeLineFinished);
        }
    }

    function updatePortrait()
    {
		if ((getCurrentLine().portrait == "none" || getCurrentLine().portrait == "")
			&& !sys.FileSystem.exists(PathGenerator.getPortrait(getCurrentLine().portrait)))
		{
			trace('FAILED FILE CHECK : ${getCurrentLine().portrait}');
			portrait.visible = false;
			astrix.offset.x = 0;
			typetext.offset.x = 0;
			typetext.fieldWidth = 496;
		}
		else
		{
			trace('COMPLETED FILE CHECK : ${getCurrentLine().portrait}');
			portrait.visible = true;
			portrait.loadGraphic(BitmapData.fromFile(PathGenerator.getPortrait(getCurrentLine().portrait)));
            portrait.updateHitbox();
			positionSprite(portrait, ((100 - portrait.width) / 2) + 24, (160 - portrait.height) / 2);
			astrix.offset.x = -(portrait.width + getSpritePosition(portrait).x);
			typetext.offset.x = -(portrait.width + getSpritePosition(portrait).x);
			typetext.fieldWidth = 400;
		}

		trace('CREATED DIALOUGE PORTRAIT');

		if (Assets.exists(PathGenerator.getTextSound(getCurrentLine().portrait))) {
			typetext.sounds = [new FlxSound().loadEmbedded(PathGenerator.getTextSound(getCurrentLine().portrait))];
		} else {
			typetext.sounds = [new FlxSound().loadEmbedded(PathGenerator.getTextSound())];
		}

		trace('ADDED SOUNDS');

		activated = activated;

		trace('CORRECTED SOUNDS');
    }

    override public function draw()
    {
        if (activated) {
            super.draw();
        }
    }

    public inline function getCurrentLine()
    {
		return nicedialouge.dialouge[dialougeIndex];
    }
}