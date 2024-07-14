package deltarune.editors;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.ui.FlxButton;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxStringUtil;
import flixel.addons.ui.FlxUIState;
import flixel.addons.ui.FlxUIAssets;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUITypedButton;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.addons.ui.FlxUINumericStepper;

import openfl.net.FileFilter;
import openfl.net.FileReference;
import openfl.events.Event;
import openfl.events.IOErrorEvent;

import sys.io.File;

import haxe.Json;

import deltarune.game.states.MenuState;
import deltarune.game.DeltaDialougeBox;

import deltarune.assets.Paths;

class DialougeEditorState extends FlxUIState
{
	var file:DialougeStructure;
    var dialouge_box:DeltaDialougeBox;

	static var defaultfile:DialougeStructure = {
		style: "darkworld",
		dialouge: [
			{
				portrait: "none",
				text: "lorum ipsum",
				speed: 1,
				pausespeed: 1,
				autocontinue: false,
				skippable: true
			},
		]
	};

    inline function defaultLine():DialougeLine
    {
		return {
			portrait: "none",
			text: "lorum ipsum",
			speed: 1,
			pausespeed: 1,
			autocontinue: false,
			skippable: true
		}
    }

	var curLine:DialougeLine;

	var portraitInput:FlxInputText;
	var textInput:FlxInputText;
	var speedInput:FlxUINumericStepper;
	var continueCheck:FlxUICheckBox;
	var skipCheck:FlxUICheckBox;

    var totalCount:FlxText;

    override function create()
    {
        super.create();

		file = defaultfile;
		dialouge_box = new DeltaDialougeBox(0, 0, file);
		dialouge_box.y = 300;
        dialouge_box.screenCenter(X);
		dialouge_box.activated = true;
        @:privateAccess
		dialouge_box.disableControls = true;
        add(dialouge_box);

		trace('Created Dialouge Box...');

		var portLab = new FlxText(12, 12, "Portrait Name : ", 24);
		portLab.setFormat(Paths.getFont("8bitoperator_jve"), 24, FlxColor.WHITE, LEFT);
		portLab.antialiasing = false;
        add(portLab);
		portraitInput = new FlxInputText(portLab.x + portLab.width, 16, FlxG.width - 300, 'none', 16);
        portraitInput.callback = typePortrait;
		add(portraitInput);
		var quitButt = new FlxButton(0, 19, "Quit", function()
		{
			FlxG.switchState(new MenuState());
		});
		quitButt.x = FlxG.width - (quitButt.width + 24);
		quitButt.color = 0xFFFF5555;
        quitButt.label.color = 0xFF000000;
		add(quitButt);

		var textLab = new FlxText(12, 48, "Text : ", 24);
		textLab.setFormat(Paths.getFont("8bitoperator_jve"), 24, FlxColor.WHITE, LEFT);
		textLab.antialiasing = false;
		add(textLab);
		textInput = new FlxInputText(textLab.x + textLab.width, 52, Std.int(FlxG.width - (textLab.x + textLab.width + 24)), 'lorum ipsum', 16);
		textInput.callback = typeText;
		add(textInput);

		var speedLab = new FlxText(12, 84, "Speed : ", 24);
		speedLab.setFormat(Paths.getFont("8bitoperator_jve"), 24, FlxColor.WHITE, LEFT);
		speedLab.antialiasing = false;
		add(speedLab);
		speedInput = new FlxUINumericStepper(speedLab.x + speedLab.width, 94, 0.1, 1, 0.1, 5, 1);
		add(speedInput);

		var continueLab = new FlxText(speedInput.x + speedInput.width + 12, 84, "Continue When Done? : ", 24);
		continueLab.setFormat(Paths.getFont("8bitoperator_jve"), 24, FlxColor.WHITE, LEFT);
		continueLab.antialiasing = false;
		add(continueLab);
		continueCheck = new FlxUICheckBox(continueLab.x + continueLab.width, 92, null, null, '', 0, null, function() {
			@:privateAccess {
                dialouge_box.getCurrentLine().autocontinue = continueCheck.checked;
			}
        });
		add(continueCheck);

		var skipLab = new FlxText(continueCheck.x + continueCheck.width + 12, 84, "Can Be Skipped? : ", 24);
		skipLab.setFormat(Paths.getFont("8bitoperator_jve"), 24, FlxColor.WHITE, LEFT);
		skipLab.antialiasing = false;
		add(skipLab);
		skipCheck = new FlxUICheckBox(skipLab.x + skipLab.width, 92, null, null, '', 0, null, function() {
			@:privateAccess {
				dialouge_box.getCurrentLine().skippable = skipCheck.checked;
			}
		});
		skipCheck.checked = true;
		add(skipCheck);

		trace('Created Main Dialouge Editor...');

        var addNewButt = new FlxButton(12, 120, "Add New", function() {
            @:privateAccess{
				dialouge_box.nicedialouge.dialouge.insert(dialouge_box.dialougeIndex + 1, defaultLine());
				changeLine(1);
            }
        });
		add(addNewButt);
		var removeButt = new FlxButton(addNewButt.x + addNewButt.width + 12, 120, "Remove", function()
		{
			@:privateAccess {
				dialouge_box.nicedialouge.dialouge.remove(dialouge_box.getCurrentLine());
				if (dialouge_box.nicedialouge.dialouge.length == 0)
				{
					dialouge_box.nicedialouge.dialouge.push(defaultLine());
                }
				changeLine(-1);
			}
		});
		add(removeButt);
		totalCount = new FlxText(removeButt.x + removeButt.width + 12, 114, "1/1", 24);
		totalCount.setFormat(Paths.getFont("8bitoperator_jve"), 24, FlxColor.WHITE, LEFT);
		totalCount.antialiasing = false;
		add(totalCount);

		var prevButt = new FlxButton(totalCount.x + totalCount.width + 36, 120, "Prev. Line", function()
		{
			changeLine(-1);
		});
		add(prevButt);
		var nextButt = new FlxButton(prevButt.x + prevButt.width + 12, 120, "Next Line", function()
		{
			changeLine(1);
		});
		add(nextButt);
		var replayButt = new FlxButton(0, 120, "Replay Line", function()
		{
			resetLine();
		});
		replayButt.x = FlxG.width - (replayButt.width + 24);
		add(replayButt);

		trace('Created Dialouge Editor Controls...');

		var saveButt = new FlxButton(12, 266, "Save", function()
		{
			saveFile();
		});
		saveButt.color = 0xFF55FF55;
		saveButt.label.color = 0xFF000000;
		add(saveButt);
		var loadButt = new FlxButton(saveButt.x + saveButt.width + 12, 266, "Load", function()
		{
			loadFile();
		});
		loadButt.color = 0xFFEEEE66;
		loadButt.label.color = 0xFF000000;
		add(loadButt);
		var testButt = new FlxButton(0, 266, "Test", function()
		{
			@:privateAccess
            openSubState(new deltarune.editors.DialougeTestSState(dialouge_box.nicedialouge));
		});
		testButt.x = FlxG.width - (testButt.width + 24);
		add(testButt);

		trace('Created Dialouge Editor Misc. Controls...');
	}

    override public function update(elapsed:Float)
    {
        super.update(elapsed);

        @:privateAccess
		totalCount.text = '${dialouge_box.dialougeIndex + 1}/${dialouge_box.nicedialouge.dialouge.length}';

        if (FlxG.keys.justPressed.ESCAPE)
            FlxG.switchState(new MenuState());

		if (canControl())
		{
            if (FlxG.keys.pressed.SHIFT)
			{
				if (FlxG.keys.justPressed.S)
					saveFile();
				if (FlxG.keys.justPressed.L)
					loadFile();
            }
            else
            {
                if (FlxG.keys.justPressed.R)
                    resetLine();

                if (Controls.left.justPressed)
                    changeLine(-1);
                if (Controls.right.justPressed)
                    changeLine(1);
            }
        }
    }

    var fileReference:FileReference;

	function saveFile()
    {
		@:privateAccess
		var json = Json.stringify(dialouge_box.nicedialouge, "\t");

		fileReference = new FileReference();
		fileReference.addEventListener(Event.COMPLETE, removeSaveListeners);
		fileReference.addEventListener(Event.CANCEL, removeSaveListeners);
		fileReference.addEventListener(IOErrorEvent.IO_ERROR, removeSaveListeners);
        fileReference.save(json, 'dialouge.json');
	}

	function removeSaveListeners(_)
	{
		fileReference.removeEventListener(Event.COMPLETE, removeSaveListeners);
		fileReference.removeEventListener(Event.CANCEL, removeSaveListeners);
		fileReference.removeEventListener(IOErrorEvent.IO_ERROR, removeSaveListeners);
		fileReference = null;
	}

	function loadFile()
	{
		fileReference = new FileReference();
		fileReference.addEventListener(Event.SELECT, loaded);
		fileReference.addEventListener(Event.CANCEL, removeLoadListeners);
		fileReference.addEventListener(IOErrorEvent.IO_ERROR, removeLoadListeners);
        var filetype = new FileFilter('JSON Dialouge (*.json)', '*.json');
		fileReference.browse([filetype]);
	}

    function loaded(v)
    {
		@:privateAccess {
			trace('selected file : {${fileReference.__path}}');
			var loadedJson = Json.parse(File.getContent(fileReference.__path));
			dialouge_box.nicedialouge = loadedJson;
			dialouge_box.dialougeIndex = 0;
			changeLine();
			removeLoadListeners(v);
		}
    }

	function removeLoadListeners(_)
	{
		fileReference.removeEventListener(Event.SELECT, loaded);
		fileReference.removeEventListener(Event.CANCEL, removeLoadListeners);
		fileReference.removeEventListener(IOErrorEvent.IO_ERROR, removeLoadListeners);
        fileReference = null;
	}

    function resetLine()
	    @:privateAccess {dialouge_box.continueDialouge(true);}

    public function changeLine(change:Int = 0)
    {
		@:privateAccess
		{
			dialouge_box.dialougeIndex += change;

			if (dialouge_box.dialougeIndex >= dialouge_box.nicedialouge.dialouge.length)
				dialouge_box.dialougeIndex = 0;
			if (dialouge_box.dialougeIndex < 0)
				dialouge_box.dialougeIndex = dialouge_box.nicedialouge.dialouge.length - 1;

			dialouge_box.continueDialouge(true);
			portraitInput.text = dialouge_box.getCurrentLine().portrait;
			textInput.text = dialouge_box.getCurrentLine().text;
			speedInput.value = dialouge_box.getCurrentLine().speed;
			continueCheck.checked = dialouge_box.getCurrentLine().autocontinue;
			skipCheck.checked = dialouge_box.getCurrentLine().skippable;
        }
    }

    inline function canControl()
		return !portraitInput.hasFocus && !textInput.hasFocus;

	override public function getEvent(name:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>)
	{
        super.getEvent(name, sender, data, params);

        switch(name)
        {
			case 'change_numeric_stepper':
				@:privateAccess
				dialouge_box.getCurrentLine().speed = data;
        }
    }

	function typeText(text:String, text2:String)
	{
		@:privateAccess {
            dialouge_box.getCurrentLine().text = text;
			if (dialouge_box.linefinished) {
				dialouge_box.typetext.text = text;
                dialouge_box.typetext._finalText = text;
				dialouge_box.typetext._length = text.length;
            }
		}
	}

	function typePortrait(text:String, text2:String)
	{
		@:privateAccess {
            dialouge_box.getCurrentLine().portrait = text;
            dialouge_box.updatePortrait();
        }
    }
}