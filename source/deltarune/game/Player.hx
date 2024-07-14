package deltarune.game;

import flixel.util.FlxDirection;
import deltarune.assets.GameAssets;
import flixel.util.FlxDestroyUtil;
import flixel.math.FlxPoint;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxG;

import deltarune.assets.Paths;
import deltarune.Controls;

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
	public var collider:LinkedCollider;
	public var colliderOffset:Array<Int> = [12, 42];
    public var colliderSize:Array<Int> = [18, 36];
	public var interactionCollider:FlxObject;
    public var controlArray:Array<String> = [];
    //public var hasControl:Bool = true;

    public static var lastAnimation:String = 'down'; //random string
    public var hasLeftRightAnims:Bool = false;

    public var warped:Bool = false;
    public var running:Bool = false;

	public var JSON:PlayerAnims;

    private var intColOffs:Array<Int> = [8, 16];

    var lastMoveDirection:Null<FlxDirection> = null;

    public function new(x:Int, y:Int, character:String = 'KrisDarkworld')
    {
		super(x, y);

		setFacingFlip(LEFT, false, false);
		setFacingFlip(UP, false, false);
		setFacingFlip(DOWN, false, false);
		setFacingFlip(RIGHT, true, false);

		loadAnimations(character);

		collider = new LinkedCollider(x + colliderOffset[0], y + colliderOffset[1], colliderSize[0], colliderSize[1]);

		interactionCollider = new FlxObject(collider.x - intColOffs[0], collider.y - intColOffs[1], 32, 52);

		collider.linkedObjects.set(this, FlxPoint.get(colliderOffset[0], colliderOffset[1]));
		collider.linkedObjects.set(interactionCollider, FlxPoint.get(intColOffs[0], intColOffs[1]));

		collider.drag.x = collider.drag.y = 2000;

        #if FLX_DEBUG
		FlxG.console.registerFunction('playerspeed', function(newSpeed:Int = 160)
		{
			gSpeed = newSpeed;
		});
		FlxG.console.registerFunction('setcharacter', function(char:String = "KrisDarkworld")
		{
			loadAnimations(char);
		});
        #end
    }

    function loadAnimations(folder:String)
	{
		JSON = cast Paths.getJSON('$folder/animations', 'characters');

        if (JSON == null && folder != 'KrisDarkworld')
        {
			loadAnimations('KrisDarkworld');
            return;
        }

		colliderOffset[0] = JSON.colliderData.x*2;
		colliderOffset[1] = JSON.colliderData.y*2;

		if (JSON.colliderData.even) {
			colliderSize[0] = 16;
        } else {
			colliderSize[0] = 18;
        }

        switch (JSON.sheetType.toLowerCase())
        {
            case 'grid' | 'spritesheet' | 'squares' | 'rectangles':
				loadGraphic(GameAssets.bitmap(Paths.getCharacterImage(folder)), true, JSON.width, JSON.height);
            default:
				loadGraphic(GameAssets.bitmap(Paths.getCharacterImage(folder)), true, JSON.width, JSON.height);
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
			updateMovement(elapsed);
        super.update(elapsed);
    }

    function position()
    {
		x = collider.x - colliderOffset[0];
		y = collider.y - colliderOffset[1];
		interactionCollider.x = collider.x - intColOffs[0];
		interactionCollider.y = collider.y - intColOffs[1];
    }

    public function reverseposition()
    {
		collider.x = x + colliderOffset[0];
		collider.y = y + colliderOffset[1];
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
            var diagonal = (keys[0] || keys[3]) && (keys[1] || keys[2]);

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
				if (!diagonal)
					lastMoveDirection = UP;
            }
            else if (keys[1])
            {
				angle = 90;
				if (keys[0])
					angle += 45;
				else if (keys[3])
					angle -= 45;
				facing = DOWN;
				if (!diagonal)
					lastMoveDirection = DOWN;
            }
            else if (keys[0])
            {
				angle = 180;
				facing = LEFT;
				if (!diagonal)
					lastMoveDirection = LEFT;
            }
            else
            {
				facing = RIGHT;
				if (!diagonal)
					lastMoveDirection = RIGHT;
            }

			collider.velocity.set((angle % 90) == 0 ? speed : speed * 1.15, 0);
			collider.velocity.pivotDegrees(FlxPoint.weak(0, 0), angle);

			switch (lastMoveDirection)
            {
				case LEFT:
					if (!hasLeftRightAnims)
					    playAnimation("walk-side");
                    else
					    playAnimation("walk-left");
				case RIGHT:
					if (!hasLeftRightAnims)
					    playAnimation("walk-side");
                    else
					    playAnimation("walk-right");
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
			switch (lastMoveDirection)
			{
				case LEFT:
					if (!hasLeftRightAnims)
						playAnimation("side");
                    else
					    playAnimation("left");
				case RIGHT:
					if (!hasLeftRightAnims)
						playAnimation("side");
                    else
					    playAnimation("right");
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

    override function destroy()
    {
		collider = FlxDestroyUtil.destroy(collider);
		interactionCollider = FlxDestroyUtil.destroy(interactionCollider);
    }
}

class LinkedCollider extends FlxObject
{
    public var linkedObjects:Map<FlxObject, FlxPoint> = [];

	public function new(x:Float = 0, y:Float = 0, width:Float = 0, height:Float = 0)
	{
        super(x, y, width, height);
    }

    override function set_x(value:Float):Float
    {
        for (object => objectOffset in linkedObjects)
        {
            object.x = value - objectOffset.x;
        }
		return x = value;
	}

	override function set_y(value:Float):Float
	{
		for (object => objectOffset in linkedObjects)
		{
			object.y = value - objectOffset.y;
		}
		return y = value;
	}

    override function destroy()
    {
        super.destroy();
        for (obj => point in linkedObjects) {
            point.put();
        }
        linkedObjects.clear();
    }
}