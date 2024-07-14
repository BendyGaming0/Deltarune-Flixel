package deltarune.game.states;

import deltarune.assets.GameAssets;
import flixel.ui.FlxButton;
import flixel.FlxSprite;
import flixel.FlxG;

import deltarune.game.State;

import deltarune.shaders.PulsatingGhostEffect;
import deltarune.assets.Paths;

class IntroState extends State
{
	var background:FlxSprite;
	var intro_shader:PulsatingGhostEffect;

	var playButton:FlxButton;
	var leaving:Bool = false;

	override public function create()
	{
		Game.initialize();

		FlxG.sound.playMusic(GameAssets.music(Paths.getMusic('anotherhim')), 0.8, true);

	    background = new FlxSprite().loadGraphic(GameAssets.bitmap('images/intro_cutscene/intro_background.png'));

		background.scale.x = 2.5;
		background.scale.y = 2.5;

		background.antialiasing = false;

		background.updateHitbox();
		background.screenCenter(XY);

		intro_shader = new PulsatingGhostEffect();

		var text:Array<String> = GameAssets.text('data/shader_data/intro_pulse.txt').split('\n');

		intro_shader.size = Std.parseFloat(text[0]);
		intro_shader.power = Std.parseFloat(text[1]);
		intro_shader.count = Std.parseInt(text[2]);
		intro_shader.speed = Std.parseFloat(text[3]);

		background.shader = intro_shader.shader;

		add(background);

		playButton = new FlxButton(0, 225, "BEGIN", clickPlay);
		playButton.screenCenter(XY);

        add(playButton);
	}

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        intro_shader.update(elapsed);
    }

	function clickPlay()
	{
		if (leaving)
            return;

		FlxG.switchState(() -> new TransitionState());
        leaving = true;
	}
}