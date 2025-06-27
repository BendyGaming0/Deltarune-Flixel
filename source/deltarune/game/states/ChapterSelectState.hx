package deltarune.game.states;

import deltarune.assets.GameAssets;
import deltarune.assets.Paths;
import deltarune.data.Chapter.ChapterFile;
import deltarune.game.State;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxContainer;
import flixel.group.FlxSpriteContainer;
import flixel.sound.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import haxe.Json;

using StringTools;

class ChapterSelectState extends State
{
	public var selectorSprite:FlxSprite;
	public var quitText:FlxText;
	public var currentSelection:Int = 0;
	public var chapterLabels:Array<FlxSpriteContainer> = [];
	public var menuMoveSound:FlxSound;
	// Format : [Group, Chapter ID, Chapter Number Text, Chapter Name, Chapter Icon Suffix]
	public var chapterData:Array<ChapterFile> = [];

	override public function create()
	{
		super.create();

		FlxG.camera.flash(FlxColor.BLACK, 1);
		FlxG.camera.scroll.set(0, 64);
		FlxG.camera.pixelPerfectRender = true;
		FlxTween.tween(FlxG.camera.scroll, {y: 0}, 1, {ease: FlxEase.cubeOut});

		FlxG.sound.playMusic(GameAssets.music(Paths.getMusic('DRONE')), 0.8, true);

		menuMoveSound = new FlxSound().loadEmbedded(GameAssets.sound("sounds/menumove.wav"));

		var chapterFiles = GameAssets.list("data/chapters/");
		chapterFiles = chapterFiles.filter(function(s:String)
		{
			return s.endsWith(".json");
		});

		for (chapterFile in chapterFiles)
		{
			trace(chapterFile);
			var raw = GameAssets.text('data/chapters/$chapterFile');
			var chapter:Dynamic;
			try
			{
				chapter = Json.parse(raw);
			}
			catch (e)
			{
				FlxG.log.error('Error parsing Chapter JSON for $chapterFile');
				FlxG.log.error(e);
				continue;
			}

			if (chapter.previousChapter != null && chapter.previousChapter != "")
			{
				for (i in 0...chapterData.length)
				{
					if (chapterData[i].id == chapter.previousChapter)
					{
						chapterData.insert(i + 1, chapter);
						break;
					}
				}
				if (!chapterData.contains(chapter))
				{
					chapterData.push(chapter);
				}
			}
			else
			{
				chapterData.push(chapter);
			}
		}

		for (i in 0...chapterData.length)
		{
			//TO:DO scrolling when theres more than 7 chapters
			//consider changing how dividers are added
			var divider:FlxSprite = new FlxSprite(0, 62 + (60 * i), GameAssets.graphic('images/ui/chapter_select/divider.png'));
			divider.scale.set(2, 2);
			divider.updateHitbox();
			add(divider);

			var chapterContainer:FlxSpriteContainer = new FlxSpriteContainer(0, 10 + (60 * i));

			var numText:FlxText = new FlxText(48, 4, 0, chapterData[i].chapterSelect.label, 24);
			numText.setFormat('', 32, FlxColor.WHITE, LEFT);
			@:privateAccess
			numText._defaultFormat.font = GameAssets.font(Paths.getFont('8bitoperator_jve')).fontName;
			chapterContainer.add(numText);

			var titleText:FlxText = new FlxText(168, 4, 384, chapterData[i].chapterSelect.title, 24);
			titleText.setFormat('', 32, FlxColor.WHITE, CENTER);
			@:privateAccess
			titleText._defaultFormat.font = GameAssets.font(Paths.getFont('8bitoperator_jve')).fontName;
			chapterContainer.add(titleText);

			var chIcon:FlxSprite = new FlxSprite(552, 0, GameAssets.graphic('images/ui/chapter_select/ch_icon_${chapterData[i].chapterSelect.iconSuffix}.png'));
			chIcon.scale.set(2, 2);
			chIcon.updateHitbox();
			chapterContainer.add(chIcon);

			if (isChapterLocked(i))
			{
				chapterContainer.color = 0xFF808080;
			}

			add(chapterContainer);

			chapterLabels.push(chapterContainer);
		}

		selectorSprite = new FlxSprite(20, 24, GameAssets.graphic("images/ui/chapter_select/selector.png"));
		selectorSprite.scale.set(2, 2);
		selectorSprite.updateHitbox();
		add(selectorSprite);

		var infoText = new FlxText(12, 432, 160, "(C) Toby Fox 2018-2025\nDELTARUNE v" + FlxG.stage.application.meta["version"], 12);
		infoText.setFormat('', 16, 0xFF808080, LEFT);
		@:privateAccess
		infoText._defaultFormat.font = GameAssets.font(Paths.getFont('8bitoperator_jve')).fontName;
		add(infoText);

		quitText = new FlxText(280, 432, 80, "Quit", 24);
		quitText.setFormat('', 32, FlxColor.WHITE, CENTER);
		@:privateAccess
		quitText._defaultFormat.font = GameAssets.font(Paths.getFont('8bitoperator_jve')).fontName;
		add(quitText);

		setSelection(currentSelection);
	}

	override public function update(elapsed:Float)
	{
		if (Controls.up.justPressed)
		{
			setSelection(currentSelection == -1 ? chapterLabels.length - 1 : currentSelection - 1);
		}
		if (Controls.down.justPressed)
		{
			setSelection(currentSelection == chapterLabels.length - 1 ? -1 : currentSelection + 1);
		}

		if (FlxG.keys.justPressed.ENTER)
		{
			if (currentSelection == -1)
			{
				#if sys
				Sys.exit(0);
				#end
			}
			else if (!isChapterLocked(currentSelection))
				FlxG.switchState(() -> new TransitionState());
		}

		super.update(elapsed);
	}

	public function isChapterLocked(index:Int):Bool
	{
		return chapterData[index].type == "dummy"
			|| (chapterData[index].requiredChapters != null && chapterData[index].requiredChapters.length > 0);
	}

	public function setSelection(index:Int)
	{
		if (currentSelection == -1)
		{
			quitText.color = 0xFFFFFFFF;
		}
		else if (currentSelection < chapterLabels.length && !isChapterLocked(currentSelection))
		{
			chapterLabels[currentSelection].color = 0xFFFFFFFF;
		}

		currentSelection = index;

		if (currentSelection == -1)
		{
			quitText.color = 0xFFFFFF00;
			selectorSprite.x = 264;
			selectorSprite.y = 442;
		}
		else if (currentSelection < chapterLabels.length)
		{
			if (!isChapterLocked(currentSelection))
			{
				chapterLabels[currentSelection].color = 0xFFFFFF00;
			}
			selectorSprite.x = 20;
			selectorSprite.y = 24 + (60 * currentSelection);
		}

		menuMoveSound.play(true);
	}
}
