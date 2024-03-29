package states;

import objects.*;
import sys.FileSystem;
import scripting.GameScript;
import haxe.Json;
import openfl.Assets;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.graphics.frames.FlxFramesCollection;
import flixel.math.FlxPoint;
import flixel.graphics.frames.FlxTileFrames;
import flixel.graphics.FlxGraphic;
import flixel.tile.FlxTilemap;
import flixel.addons.editors.ogmo.FlxOgmo3Loader;
import flixel.FlxCamera;
import flixel.addons.transition.FlxTransitionableState;
import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import tools.PathGenerator;

class PlayState extends FlxTransitionableState
{

	public static var instance:PlayState;
	public var interactables:FlxTypedGroup<InteractableSprite>;
	public var collision_layer:FlxTypedGroup<CollisionObject>;
	public var player:Player;
	public var dielouge:DeltaDialougeBox;

	var map:FlxOgmo3Loader;
	var levelValues:Dynamic;
	var background:FlxTilemap;
	var walls:FlxTilemap;

	var quitText:FlxText;
	var gameUICamera:FlxCamera;
	var dialougeCamera:FlxCamera;

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
		Main.border.switchTo(json.values.Border);
		warpTag = warpPoint;
		xoffset = Xoffset;
		yoffset = Yoffset;
	}

	override public function create()
	{
		if (PathGenerator.currentMusic != 'cyber')
			FlxG.sound.playMusic(PathGenerator.getMusic('cyber'), 0.8, true);

		instance = this;
		doingTheQuit = false;

		map = new FlxOgmo3Loader('assets/data/ogmoData.ogmo', 'assets/data/levels/level$levelString.json');

		#if hscript
		var lvlScript = new GameScript();
		lvlScript.loadFile('assets/data/levels/level$levelString');
		if (lvlScript.compiled)
			scripts.push(lvlScript);

		#if sys
		if (FileSystem.exists(Sys.getCwd() + '/assets/scripts'))
		{
			for (script in FileSystem.readDirectory(Sys.getCwd() + '/assets/scripts'))
			{
				if (FileSystem.isDirectory(Sys.getCwd() + '/assets/scripts/' + script))
					continue;

				var globalScript = new GameScript();
				globalScript.loadFile('assets/scripts/' + script);
				if (globalScript.compiled)
					scripts.push(globalScript);
			}
		}
		#end
		#end

		@:privateAccess
		levelValues = map.level.values;

		// Main.border.switchTo(levelValues.Border);

		// custom code for spaced tilemap graphics

		var leframes:FlxFramesCollection;

		background = map.loadTilemap("assets/images/cyberassetsbackgounds.png", "background");
		background.solid = false;

		/*for (x in 0...6)
		{
			try{
				background.setTileProperties(x, NONE);}
			catch (e) {}
		}*/

		add(background);

		@:privateAccess {
			var projectData = map.project;
			var graphic = FlxGraphic.fromBitmapData(PathGenerator.getBitmapSys('cyberassetsmini'));

			var tilesetObject = null;

			for (tileset in projectData.tilesets) {
				if (tileset.label == 'cyberassetsmini')
					tilesetObject = tileset; }
			
			leframes = FlxTileFrames.fromGraphic(graphic, new FlxPoint(tilesetObject.tileWidth, tilesetObject.tileWidth),
				new FlxPoint(tilesetObject.tileSeparationX, tilesetObject.tileSeparationY));
		}

		walls = map.loadTilemap(leframes, "walls");
		walls.solid = false;

		@:privateAccess
		trace('total tile types:'+walls._tileObjects.length);

		/*for (y in 0...3)
		{
			for (x in 0...8)
			{
				try {
				walls.setTileProperties(x + (y * 8), NONE);
				} catch (e) {}
			}
		}

		for (y in 3...7)
		{
			for (x in 0...3)
			{
				try {
				walls.setTileProperties(x + (y * 8), ANY);
				} catch (e) {}
			}
		}

		walls.setTileProperties(37, ANY);
		walls.setTileProperties(45, NONE);*/

		add(walls);

		walls.follow();

		dialougeCamera = new FlxCamera();
		//dialougeCamera.y = -24;
		dialougeCamera.bgColor = 0x00000000; // transparent
		FlxG.cameras.add(dialougeCamera, false);

		gameUICamera = new FlxCamera();
		gameUICamera.bgColor = 0x00000000; // transparent
		FlxG.cameras.add(gameUICamera, false);

		player = new Player(20, 20);
		player.scale.x = 2;
		player.scale.y = 2;
		player.updateHitbox();

		interactables = new FlxTypedGroup<InteractableSprite>();
		collision_layer = new FlxTypedGroup<CollisionObject>();

		map.loadEntities(function (entity:EntityData)
		{
			switch (entity.name) {
			case "player":
				if (!player.warped) {
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
					trace('welcome!');
				}
			case "warpExit":
				var newWarp = new WarpPoint(entity.x + entity.values.xOffset, entity.y + entity.values.yOffset, entity.values.tiledWidth, entity.values.tiledHeight);
				newWarp.objectValues = entity.values;
				newWarp.allowCollisions = NONE;
				interactables.add(newWarp);
				add(newWarp.interactionHitbox);
			default:
				#if hscript
				if (!scriptNames.contains(entity.name)) {
					var objScript = new GameScript();
					if (!(objScript.loadFile('assets/objects/${entity.name}') is haxe.Exception)) {
						var newObj = new ScriptObject(entity.x, entity.y, entity, entity.values, objScript);

						interactables.add(newObj);
						add(newObj.interactionHitbox);
					} else 
				#end
						trace('idk what that is');
				#if hscript
				}
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
					trace('idk what that is');
			}
		}, "collision");

		add(interactables);
		add(collision_layer);

		add(player);
			add(player.collider);
			add(player.interactionCollider);

		trace('added player');

		dielouge = new DeltaDialougeBox(0, 400, "assets/data/dialouge/testDialouge.json");
		dielouge.screenCenter(X);
		dielouge.cameras = [dialougeCamera];
		add(dielouge);

		//dielouge.activated = true; i am getting tired of this dialouge

		trace('added dialouge box');

		quitText = new FlxText(12, 6, 120, "Quiting...");
		quitText.setFormat(PathGenerator.getFont("8bitoperator_jve"), 32, FlxColor.WHITE, LEFT);
		quitText.antialiasing = false;
		quitText.cameras = [gameUICamera];

		quitText.alpha = 0;

		add(quitText);

		FlxG.camera.follow(player, TOPDOWN, 1);
		FlxG.camera.bgColor = 0xFF499DF5;

		//bgColor = 0xFF1A4F89;

		super.create();
	}

	public function changeRoom(Room:String, Entrance:String, X:Float, Y:Float)
	{
		FlxG.switchState(new PlayState(Room, Entrance, X, Y));
	}

	var cachedDialougeScripts:Map<String, GameScript> = [];
	var activeDialougeScript:GameScript;

	public function startDialouge(filename:String)
	{
		remove(dielouge);
		dielouge = new DeltaDialougeBox(0, 400, 'assets/data/dialouge/$filename.json');
		dielouge.screenCenter(X);
		dielouge.cameras = [dialougeCamera];
		add(dielouge);

		#if hscript
		// var lvlScript = new GameScript();
		// lvlScript.loadFile('assets/data/levels/level$levelString');
		// if (lvlScript.compiled)
		// 	scripts.push(lvlScript);
		if (cachedDialougeScripts.exists(filename))
		{
			activeDialougeScript = cachedDialougeScripts.get(filename);
		} else {
			var dialougeScript = new GameScript();
			dialougeScript.loadFile('assets/data/dialouge/$filename');
			if (dialougeScript.compiled) {
				cachedDialougeScripts.set(filename, dialougeScript);
				activeDialougeScript = dialougeScript;
			}
		}
		#end

		dielouge.activated = true;
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
			dialougeCamera.y = 12; //??
		} else {
			// upper half
			dialougeCamera.y = 300; //??
		}
		if (FlxG.keys.pressed.ESCAPE){
			quitTimer += elapsed;
		} else {
			quitTimer = 0;
		}

		quitText.alpha = quitTimer / quitLength;

		if (!doingTheQuit && quitTimer >= quitLength)
		{
			doingTheQuit = true;
			FlxG.switchState(new MenuState());
			Main.border.switchTo();
		}

		super.update(elapsed);

		FlxG.collide(player.collider, collision_layer);
		FlxG.collide(player.collider, interactables);

		//interactables check
		if (player.controlArray.length <= 0)
		{
			for (interactable in interactables)
			{
				if (FlxG.overlap(player.interactionCollider, interactable.interactionHitbox) && (Controls.primary.justPressed || interactable.autoTriggered))
				{
					interactable.onInteraction();
				}
			}
		}
	}
}
