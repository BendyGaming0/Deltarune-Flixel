package deltarune.game;

import deltarune.assets.GameAssets;
import openfl.display.BitmapData;
import openfl.Assets;

import flixel.addons.text.FlxTypeText;
import flixel.group.FlxSpriteContainer;
import flixel.util.typeLimit.OneOfTwo;
import flixel.util.FlxColor;
import flixel.sound.FlxSound;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.FlxSprite;
import flixel.FlxG;

import deltarune.game.states.PlayState;

import deltarune.assets.Paths;

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

class DeltaDialougeBox extends FlxSpriteContainer
{

    public var activated(default, set):Bool;

    public var finishedCallback:()->Void;
    public var dialougeProgressedCallback:(Int)->Void;

    //sprite order
    var background:FlxSprite;
    var portrait:FlxSprite;
    var astrix:FlxText;
    var typetext:FlxTypeText;

    var shadowPow:Int = 1;

    var nicedialouge:DialougeStructure;

    var dialougeIndex:Int;

    var linefinished:Bool;

    var disableControls:Bool = false;

    function set_activated(value:Bool)
    {
        if (typetext != null) {
			for (sound in typetext.sounds)
				sound.volume = value ? 1 : 0;
        }
		activated = value;
		return value;
    }

    var defaultfile:DialougeStructure =
    {
        style: "darkworld",
        dialouge: [
            {
                portrait: "none",
                text: "Dialouge failed to load, please check the path or dialouge file for issues",
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
            if (GameAssets.exists(dialouge))
                jsonstr = GameAssets.text(dialouge);
            try
            {
                nicedialouge = haxe.Json.parse(jsonstr);
            }
            catch(e:Any)
            {
                FlxG.log.warn("Failed to parse/load Dialouge");
                nicedialouge = defaultfile;
            }
        }
        else
			nicedialouge = dialouge;

		activated = false;
        dialougeIndex = 0;
		linefinished = false;

		background = new FlxSprite(0, 0, GameAssets.bitmap('images/${nicedialouge.style}Box.png'));
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

		portrait = new FlxSprite(0, 0);
		portrait.scale.x = 2;
		portrait.scale.y = 2;
        portrait.antialiasing = false;
        portrait.updateHitbox();

		add(portrait);

		astrix = new FlxText(24, 26, 48, "*");
		astrix.setFormat('', 32, FlxColor.WHITE, LEFT);
        @:privateAccess
		astrix._defaultFormat.font = GameAssets.font(Paths.getFont('8bitoperator_jve')).fontName;
		astrix.antialiasing = false;
		astrix.setBorderStyle(SHADOW, 0xFF171769, 1, 1);
		astrix.shadowOffset.x = shadowPow;
		astrix.shadowOffset.y = shadowPow;

        add(astrix);

		typetext = new FlxTypeText(52, 24, 496, getCurrentLine().text); // x, y, width
		typetext.setFormat('', 32, FlxColor.WHITE, LEFT);
		@:privateAccess
        typetext._defaultFormat.font = GameAssets.font(Paths.getFont('8bitoperator_jve')).fontName;
		typetext.antialiasing = false;
		typetext.start(0.06 / getCurrentLine().speed, true, false, [], dialougeLineFinished);
		typetext.setBorderStyle(SHADOW, 0xFF171769, 1, 1);
		typetext.shadowOffset.x = shadowPow;
		typetext.shadowOffset.y = shadowPow;

		add(typetext);

		dialougeIndex = -1;
		continueDialouge();
    }

	override public function update(elapsed:Float)
    {
        super.update(elapsed);

		if (FlxG.keys.justPressed.R && Game.developerMode && !disableControls)
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

        var justContinued:Bool = false;

		if ((Controls.primary.justPressed || Controls.tetritary.pressed) && linefinished && !disableControls)
		{
            continueDialouge();
			justContinued = true;
        }

		if (((Controls.primary.justPressed && !justContinued) || Controls.secondary.pressed || Controls.tetritary.pressed) && !disableControls
			&& !linefinished && getCurrentLine().skippable)
		{
            typetext.skip();
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
			&& !GameAssets.exists(Paths.getPortrait(getCurrentLine().portrait)))
		{
			portrait.visible = false;
			astrix.offset.x = 0;
			typetext.offset.x = 0;
			typetext.fieldWidth = 496;
		}
		else
		{
			portrait.visible = true;
			portrait.loadGraphic(GameAssets.bitmap(Paths.getPortrait(getCurrentLine().portrait)));
            portrait.updateHitbox();
			positionSprite(portrait, ((100 - portrait.width) / 2) + 24, (160 - portrait.height) / 2);
			astrix.offset.x = -(portrait.width + getSpritePosition(portrait).x);
			typetext.offset.x = -(portrait.width + getSpritePosition(portrait).x);
			typetext.fieldWidth = 400;
		}

		if (GameAssets.exists(Paths.getTextSound(getCurrentLine().portrait))) {
			typetext.sounds = [new FlxSound().loadEmbedded(GameAssets.sound(Paths.getTextSound(getCurrentLine().portrait)))];
		} else {
			typetext.sounds = [new FlxSound().loadEmbedded(GameAssets.sound(Paths.getTextSound()))];
		}

		activated = activated;
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