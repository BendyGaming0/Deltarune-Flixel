package;

import flixel.FlxObject;
import flixel.math.FlxPoint;
import flixel.FlxG;
import flixel.FlxSprite;

typedef PlayerAnims =
{
    var sheetType:String;
    var width:Int;
    var height:Int;
    var colliderData:{x:Int,y:Int,even:Bool};
	var animations:Array<AnimationJSON>;
}

typedef AnimationJSON = 
{
    var name:String;
    var prefix:String;
    var indicies:Array<Int>;
    var postfix:String;
    var framerate:Null<Int>;
    var looped:Bool;
    var flipX:Bool;
    var flipY:Bool;
}

class Player extends FlxSprite
{
    public var gSpeed:Float = 160;
    public var collider:FlxObject;
    public var colSize:Array<Int> = [12, 42, 18, 36];
    var intColOffs:Array<Int> = [8, 16];
	public var interactionCollider:FlxObject;
    public var controlArray:Array<String> = [];
    public var hasControl:Bool = true;

    public static var lastAnimation:String = 'down'; //random string
    public var hasLeftRightAnims:Bool = false;

    public var warped:Bool = false;
    public var running:Bool = false;

	public var JSON:PlayerAnims;

    public function new(x:Int, y:Int, character:String = 'KrisDarkworld')
    {
		super(x, y);
		setFacingFlip(LEFT, false, false);
		setFacingFlip(UP, false, false);
		setFacingFlip(DOWN, false, false);
		setFacingFlip(RIGHT, true, false);
		loadAnimations(character);
		collider = new FlxObject(x + colSize[0], y + colSize[1], colSize[2], colSize[3]);
		interactionCollider = new FlxObject(collider.x - intColOffs[0], collider.y - intColOffs[1], 32, 52);
		collider.drag.x = collider.drag.y = 2000;
		FlxG.console.registerFunction('playerspeed', function(newSpeed:Int = 160)
		{
			gSpeed = newSpeed;
		});
		FlxG.console.registerFunction('setcharacter', function(char:String = "KrisDarkworld")
		{
			loadAnimations(char);
		});
    }

    function loadAnimations(folder:String)
	{
		JSON = cast PathGenerator.getJSON('$folder/animations', 'characters');

        if (JSON == null && folder != 'KrisDarkworld')
        {
			loadAnimations('KrisDarkworld');
            return;
        }

		colSize[0] = JSON.colliderData.x*2;
		colSize[1] = JSON.colliderData.y*2;
		if (JSON.colliderData.even) {
            colSize[2] = 16;
        } else {
            colSize[2] = 18;
        }

        switch (JSON.sheetType.toLowerCase())
        {
            case 'grid' | 'spritesheet' | 'squares' | 'rectangles':
				loadGraphic(PathGenerator.getCharacterImage(folder), true, JSON.width, JSON.height);
            default:
				loadGraphic(PathGenerator.getCharacterImage(folder), true, JSON.width, JSON.height);
        }

        for (anim in JSON.animations)
        {
			switch (JSON.sheetType.toLowerCase())
			{
				case 'grid' | 'spritesheet' | 'squares' | 'rectangles':
					animation.add(anim.name, anim.indicies, anim.framerate != null ? anim.framerate : 8, anim.looped);
				default:
					animation.add(anim.name, anim.indicies, anim.framerate != null ? anim.framerate : 8, anim.looped);
            }

            // animation stuff
            if (anim.name == 'left' || anim.name == 'right') {
                setFacingFlip(RIGHT, false, false);
			    hasLeftRightAnims = true;
            }
            else if (anim.name == 'side') {
				setFacingFlip(RIGHT, true, false);
			    hasLeftRightAnims = false;
            }
        }

		/*animation.add("walk-side", [4, 5, 6, 5], 8, false);
		animation.add("side", [5], 8, false);
		animation.add("blush-side", [7], 8, false);

		animation.add("walk-up", [8, 9, 10, 9], 8, false);
		animation.add("up", [9], 8, false);
		animation.add("blush-up", [11], 8, false);

		animation.add("walk-down", [0, 1, 2, 1], 8, false);
		animation.add("down", [1], 8, false);
		animation.add("blush-down", [3], 8, false);*/

		playAnimation();
    }

    public function playAnimation(?anim:String)
    {
        if (anim == null) anim = lastAnimation;
        animation.play(anim);
        lastAnimation = anim;
    }

    override function update(elapsed:Float)
    {
		if (controlArray.length <= 0)
		{
			position();
			updateMovement(elapsed);
		}
		position();
        super.update(elapsed);
        position();
    }

    function position()
    {
        x = collider.x - colSize[0];
		y = collider.y - colSize[1];
		interactionCollider.x = collider.x - intColOffs[0];
		interactionCollider.y = collider.y - intColOffs[1];
    }

    public function reverseposition()
    {
		collider.x = x + colSize[0];
		collider.y = y + colSize[1];
		interactionCollider.x = collider.x - intColOffs[0];
		interactionCollider.y = collider.y - intColOffs[1];
    }

    function updateMovement(elapsed:Float)
    {
        var keys:Array<Bool> = 
        [Controls.left.pressed,
		Controls.down.pressed,
		Controls.up.pressed,
		Controls.right.pressed,];

		running = Controls.secondary.pressed;

        if (keys[1] && keys[2])
		    keys[1] = keys[2] = false;
		if (keys[0] && keys[3])
			keys[0] = keys[3] = false;

        if (keys.contains(true))
        {
            var angle:Float = 0;
            var speed:Float = gSpeed;
            if (running)
                speed *= 1.5;

            if (keys[2])
            {
                angle = -90;
                if (keys[0])
                    angle -= 45;
                else if (keys[3])
					angle += 45;
				facing = UP;
            }
            else if (keys[1])
            {
				angle = 90;
				if (keys[0])
					angle += 45;
				else if (keys[3])
					angle -= 45;
				facing = DOWN;
            }
            else if (keys[0])
            {
				angle = 180;
				facing = LEFT;
            }
            else
            {
                facing = RIGHT;
            }

			collider.velocity.set((angle % 90) == 0 ? speed : speed * 1.15, 0);
			collider.velocity.rotate(FlxPoint.weak(0, 0), angle);

            switch (facing)
            {
				case LEFT:
					playAnimation("walk-left");
					if (!hasLeftRightAnims)
					    playAnimation("walk-side");
				case RIGHT:
					playAnimation("walk-right");
					if (!hasLeftRightAnims)
					    playAnimation("walk-side");
                case UP:
					playAnimation("walk-up");
                case DOWN:
					playAnimation("walk-down");
                case _:
            }

			if (running)
                animation.update(elapsed);//double speed
        }
        else
        {
			switch (facing)
			{
				case LEFT:
					playAnimation("left");
					if (!hasLeftRightAnims)
						playAnimation("side");
				case RIGHT:
					playAnimation("right");
					if (!hasLeftRightAnims)
						playAnimation("side");
				case UP:
					playAnimation("up");
				case DOWN:
					playAnimation("down");
				case _:
			}
        }

        FlxG.watch.addQuick('Player X Velocity', collider.velocity.x);
        FlxG.watch.addQuick('Player Y Velocity', collider.velocity.y);
        FlxG.watch.addQuick('Player Is Running?', running);
    }
}