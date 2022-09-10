package states;

import states.substates.Credits;
import states.substates.Options;
import openfl.display.TileContainer;
import flixel.FlxSprite;
import tools.PathGenerator;
import flixel.addons.transition.FlxTransitionableState;
import flixel.FlxG;
import flixel.ui.FlxButton;

class MenuState extends FlxTransitionableState
{
    //bg cropped width and height : 320x70
    // 190 height for top part
    var coolBG:FlxSprite;
    var gameLogo:FlxSprite;
	//#if shaders_supported
    var bgShader:WiggleEffect;
	//#end
	public var playButton:FlxButton;
	public var credsButton:FlxButton;
	public var optButton:FlxButton;

	public var dialougeEditButton:FlxButton;
	public var charEditButton:FlxButton;
	public var battleEditButton:FlxButton;
	public var chapterEditButton:FlxButton;

    var inCredits:Bool;
    var leaving:Bool = false;

    public static var instance:MenuState;
    public static var initialized:Bool = false;

    override public function create()
    {
		if (!initialized)
        {
            FlxG.scaleMode = new CustomScaleMode();
			FlxG.console.registerFunction('switchBorderIdTo', Main.border.switchToId);
			FlxG.console.registerFunction('switchBorderTo', Main.border.switchTo);
			Main.border.switchTo();
            FlxG.save.bind('global', 'BendyGaming0/Deltarune');
            Options.initialize();
			initialized = true;
        }

        FlxG.sound.playMusic(PathGenerator.getMusic('menu'), 0.8, true);

		instance = this;
		inCredits = false;

        coolBG = new FlxSprite().loadGraphic('assets/images/menuBG.png', true, 320, 260);

        coolBG.animation.add('cool', [0,1,2,3,4], 8, true);
        coolBG.animation.play('cool');

        coolBG.scale.x = 2;
        coolBG.scale.y = 2;

		coolBG.antialiasing = false;

		coolBG.updateHitbox();
		coolBG.screenCenter(XY);

        //#if shaders_supported
        bgShader = new WiggleEffect();

        var text:Array<String> = sys.io.File.getContent(Sys.getCwd() + '/assets/data/TitleScreen.txt').split('\n');

		bgShader.waveAmplitude = Std.parseFloat(text[0]) / 5;
		bgShader.waveFrequency = Std.parseFloat(text[1]) / 2;
		bgShader.waveSpeed = Std.parseFloat(text[2]) * 2;

        coolBG.shader = bgShader.shader;
        //#else
        //trace('Shaders are not supported on this platform!');
        //#end

        add(coolBG);

		gameLogo = new FlxSprite(0, 32).loadGraphic('assets/images/gameLogo.png');
		gameLogo.scale.x = 4;
		gameLogo.scale.y = 4;
        gameLogo.updateHitbox();
		gameLogo.screenCenter(X);

        gameLogo.antialiasing = false;

        add(gameLogo);

		playButton = new FlxButton(0, 225, "Play", clickPlay);
        playButton.screenCenter(X);

		credsButton = new FlxButton(0, 275, "Credits", function () {
			if (!inCredits && !leaving) {
                inCredits = true;
                openSubState(new Credits());
            }
		});
		credsButton.screenCenter(X);

		optButton = new FlxButton(0, 325, "Options", function () {
			if (!inCredits && !leaving) {
                inCredits = true;
                openSubState(new Options());
            }
		});
		optButton.screenCenter(X);

        add(playButton);
		add(credsButton);
		add(optButton);

		if (Main.args.contains('debugmode'))
		{
			dialougeEditButton = new FlxButton(32, 425, "Edit Dialouge", function() {
				if (!inCredits && !leaving)
					FlxG.switchState(new editors.DialougeEditorState());
			});
			add(dialougeEditButton);

			charEditButton = new FlxButton(132, 425, "Edit Character", function() {
				trace('Character Editor Isn\'t Available Yet');
			});
			charEditButton.color = 0xFF808080;
			add(charEditButton);

			battleEditButton = new FlxButton(232, 425, "Edit Battle Data", function() {
				trace('Battle Editor Isn\'t Available Yet');
			});
			battleEditButton.color = 0xFF808080;
			add(battleEditButton);

			chapterEditButton = new FlxButton(332, 425, "Edit Chapter", function()
			{
				trace('Chapter Editor Isn\'t Available Yet');
			});
			chapterEditButton.color = 0xFF808080;
			add(chapterEditButton);
        }

		super.create();

		persistentUpdate = true;
		persistentDraw = true;

		FlxG.camera.bgColor = 0xFF000000;
    }

    override public function update(elapsed:Float)
    {
        if (FlxG.keys.justPressed.F11)
			FlxG.fullscreen = !FlxG.fullscreen;
        super.update(elapsed);
		bgShader.shader.data.uTime.value[0] += elapsed;
    }

    public function exitCredits(tween)
    {
        closeSubState();
		inCredits = false;
		playButton.alpha = 1;
		credsButton.alpha = 1;
		optButton.alpha = 1;
		if (Main.args.contains('debugmode')) {
			dialougeEditButton.alpha = 1;
			charEditButton.alpha = 1;
			battleEditButton.alpha = 1;
			chapterEditButton.alpha = 1;
        }
    }

    function clickPlay()
    {
		if (!inCredits && !leaving) {
            FlxG.switchState(new PlayState());
			leaving = true;
        }
    }
}