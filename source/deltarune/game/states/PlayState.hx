package deltarune.game.states;

import deltarune.assets.GameAssets;
import deltarune.assets.Paths;
import deltarune.game.State;
import deltarune.game.objects.*;
import deltarune.game.states.substates.Options;
import deltarune.scripting.GameScript;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.addons.editors.ogmo.FlxOgmo3Loader;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxFramesCollection;
import flixel.graphics.frames.FlxTileFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.tile.FlxTilemap;
import flixel.util.FlxColor;
import haxe.Json;
import openfl.Assets;
#if sys
import sys.FileSystem;
#end

class PlayState extends State
{
	public static var instance:PlayState;

	public var interactables:FlxTypedGroup<InteractableSprite>;
	public var collision_layer:FlxTypedGroup<CollisionObject>;
	public var player:Player;
	public var dielogue:LegacyDialogueBox;

	var map:FlxOgmo3Loader;
	var levelValues:Dynamic;
	var background:FlxTilemap;
	var walls:FlxTilemap;

	var quitText:FlxText;
	var gameUICamera:FlxCamera;
	var dialogueCamera:FlxCamera;

	var quitTimer:Float = 0;
	var quitLength:Float = 1.5;
	var doingTheQuit:Bool;

	public var levelString:String;

	var warpTag:String;
	var xoffset:Float;
	var yoffset:Float;

	#if hscript
	var scripts:Array<GameScript> = [];
	var scriptNames:Array<String> = [];
	#end

	public function new(levelID:String = '001', ?warpPoint:String, Xoffset:Float = 0, Yoffset:Float = 0)
	{
		super();
		levelString = levelID;
		var json = Json.parse(Assets.getText('assets/data/levels/level$levelString.json'));
		Game.border.switchTo(json.values.Border);
		warpTag = warpPoint;
		xoffset = Xoffset;
		yoffset = Yoffset;
	}

	override public function create()
	{
		super.create();

		if (Paths.currentMusic != 'A CYBER\'S WORLD')
			FlxG.sound.playMusic(GameAssets.music(Paths.getMusic('A CYBER\'S WORLD')), 0.8, true);

		instance = this;
		doingTheQuit = false;

		map = new FlxOgmo3Loader('assets/data/ogmoData.ogmo', 'assets/data/levels/level$levelString.json');

		#if hscript
		var lvlScript = new GameScript();
		try
		{
			lvlScript.loadFile('data/levels/level$levelString');
			if (lvlScript.compiled)
				scripts.push(lvlScript);
		}
		catch (e)
		{
			FlxG.log.error(e.message);
		}

		if (GameAssets.directoryExists('scripts'))
		{
			for (script in GameAssets.list('scripts/'))
			{
				if (GameAssets.directoryExists('scripts/' + script))
					continue;

				var globalScript = new GameScript();
				try
				{
					globalScript.loadFile('scripts/' + script);
					if (globalScript.compiled)
						scripts.push(globalScript);
				}
				catch (e)
				{
					FlxG.log.error(e.message);
				}
			}
		}
		#end

		@:privateAccess
		levelValues = map.level.values;

		// Main.border.switchTo(levelValues.Border);

		var leframes:FlxFramesCollection;

		background = map.loadTilemap(GameAssets.graphic(Paths.getImage("cyberassetsbackgounds")), "background");
		background.ignoreDrawDebug = true;
		background.solid = false;

		add(background);

		@:privateAccess {
			var projectData = map.project;
			var graphic = GameAssets.graphic(Paths.getImage('cyberassetsmini'));

			var tilesetObject = null;

			for (tileset in projectData.tilesets)
			{
				if (tileset.label == 'cyberassetsmini')
					tilesetObject = tileset;
			}

			leframes = FlxTileFrames.fromGraphic(graphic, new FlxPoint(tilesetObject.tileWidth, tilesetObject.tileWidth),
				new FlxPoint(tilesetObject.tileSeparationX, tilesetObject.tileSeparationY));
		}

		walls = map.loadTilemap(leframes, "walls");
		walls.ignoreDrawDebug = true;
		walls.solid = false;

		add(walls);

		walls.follow();

		dialogueCamera = new FlxCamera();
		// dialogueCamera.y = -24;
		dialogueCamera.bgColor = 0x00000000; // transparent
		FlxG.cameras.add(dialogueCamera, false);

		gameUICamera = new FlxCamera();
		gameUICamera.bgColor = 0x00000000; // transparent
		FlxG.cameras.add(gameUICamera, false);

		player = new Player(20, 20);
		player.scale.x = 2;
		player.scale.y = 2;
		player.updateHitbox();

		interactables = new FlxTypedGroup<InteractableSprite>();
		collision_layer = new FlxTypedGroup<CollisionObject>();

		map.loadEntities(function(entity:EntityData)
		{
			switch (entity.name)
			{
				case "player":
					if (!player.warped)
					{
						player.setPosition(entity.x, entity.y);
						player.reverseposition();
					}
				case "sign":
					var newSign = new Sign(entity.x, entity.y);
					newSign.objectValues = entity.values;
					newSign.allowCollisions = ANY;
					interactables.add(newSign);
					add(newSign.interactionHitbox);
				case "invisible-sign":
					var newISign = new InvisibleSign(entity.x, entity.y, entity.values.width, entity.values.height);
					newISign.objectValues = entity.values;
					newISign.allowCollisions = NONE;
					interactables.add(newISign);
					add(newISign.interactionHitbox);
				case "save":
					var newSave = new SavePoint(entity.x, entity.y);
					newSave.allowCollisions = ANY;
					interactables.add(newSave);
					add(newSave.interactionHitbox);
				case "warpEntrance":
					if (warpTag == entity.values.entranceTag)
					{
						player.setPosition((entity.values.useXoffset ? entity.x + xoffset : entity.x),
							(entity.values.useYoffset ? entity.y + yoffset : entity.y));
						player.reverseposition();
						player.warped = true;
					}
				case "warpExit":
					var newWarp = new WarpPoint(entity.x + entity.values.xOffset, entity.y + entity.values.yOffset, entity.width, entity.height);
					newWarp.objectValues = entity.values;
					newWarp.allowCollisions = NONE;
					interactables.add(newWarp);
					add(newWarp.interactionHitbox);
				default:
					#if hscript
					if (!scriptNames.contains(entity.name))
					{
						var objScript = new GameScript();

						try
						{
							objScript.loadFile('objects/${entity.name}');
							var newObj = new ScriptObject(entity.x, entity.y, entity, entity.values, objScript);

							interactables.add(newObj);
							add(newObj.interactionHitbox);
						}
						catch (e)
						{
							FlxG.log.error(e.message);
						}
					}
					#else
					FlxG.log.warn("Script based objects are not supported on this platform");
					#end
			}
		}, "entities");

		map.loadEntities(function(entity:EntityData)
		{
			switch (entity.name)
			{
				case "collision":
					var collider = new CollisionObject(entity.x, entity.y, entity.width, entity.height);
					collision_layer.add(collider);
				default:
					FlxG.log.warn("Tried to add an unknown object to the collision layer");
			}
		}, "collision");

		add(interactables);
		add(collision_layer);

		add(player);
		add(player.collider);
		add(player.interactionCollider);

		trace('added player');

		dielogue = new LegacyDialogueBox(0, 400, "data/dialogue/testDialogue.json");
		dielogue.screenCenter(X);
		dielogue.cameras = [dialogueCamera];
		add(dielogue);

		// dielogue.activated = true; i am getting tired of this dialogue

		trace('added dialogue box');

		quitText = new FlxText(12, 6, 120, "Quiting...");
		quitText.setFormat('', 32, FlxColor.WHITE, LEFT);
		@:privateAccess
		quitText._defaultFormat.font = GameAssets.font(Paths.getFont('8bitoperator_jve')).fontName;
		quitText.antialiasing = false;
		quitText.cameras = [gameUICamera];

		quitText.alpha = 0;

		add(quitText);

		FlxG.camera.follow(player, TOPDOWN_TIGHT, 1);
		FlxG.camera.pixelPerfectRender = true;
		FlxG.camera.followLead.set(0, 0);
		FlxG.camera.focusOn(FlxPoint.weak(player.x + (player.width / 2), player.y + (player.height / 2)));
		FlxG.camera.bgColor = 0xFF499DF5;
	}

	public function changeRoom(Room:String, Entrance:String, X:Float, Y:Float)
	{
		FlxG.switchState(() -> new PlayState(Room, Entrance, X, Y));
	}

	var cachedDialogueScripts:Map<String, GameScript> = [];
	var activeDialogueScript:GameScript;

	public function startDialogue(filename:String)
	{
		remove(dielogue);
		dielogue = new LegacyDialogueBox(0, 400, 'data/dialogue/$filename.json');
		dielogue.screenCenter(X);
		dielogue.cameras = [dialogueCamera];
		add(dielogue);

		#if hscript
		// var lvlScript = new GameScript();
		// lvlScript.loadFile('data/levels/level$levelString');
		// if (lvlScript.compiled)
		// 	scripts.push(lvlScript);
		if (cachedDialogueScripts.exists(filename))
		{
			activeDialogueScript = cachedDialogueScripts.get(filename);
		}
		else
		{
			var dialogueScript = new GameScript();

			try
			{
				dialogueScript.loadFile('data/dialogue/$filename');
				if (dialogueScript.compiled)
				{
					cachedDialogueScripts.set(filename, dialogueScript);
					activeDialogueScript = dialogueScript;
				}
			}
			catch (e)
			{
				FlxG.log.error(e.message);
			}
		}
		#end

		dielogue.activated = true;
	}

	override function finishTransIn()
	{
		super.finishTransIn();
	}

	override public function update(elapsed:Float)
	{
		if (FlxG.keys.justPressed.F11)
			FlxG.fullscreen = !FlxG.fullscreen;

		if (player.getScreenPosition().y > 240)
		{
			// lower half
			dialogueCamera.y = 12; // ??
		}
		else
		{
			// upper half
			dialogueCamera.y = 300; // ??
		}
		if (FlxG.keys.pressed.ESCAPE)
		{
			quitTimer += elapsed;
		}
		else
		{
			quitTimer = 0;
		}

		quitText.alpha = quitTimer / quitLength;

		if (!doingTheQuit && quitTimer >= quitLength)
		{
			doingTheQuit = true;
			FlxG.switchState(() -> new MenuState());
			Game.border.switchTo();
		}

		Options.currentData.play_time += elapsed;

		super.update(elapsed);

		FlxG.collide(player.collider, collision_layer);
		FlxG.collide(player.collider, interactables);

		// interactables check
		if (player.controlArray.length <= 0)
		{
			for (interactable in interactables)
			{
				if (FlxG.overlap(player.interactionCollider, interactable.interactionHitbox)
					&& (Controls.primary.justPressed || interactable.autoTriggered))
				{
					interactable.onInteraction();
				}
			}
		}
	}
}
