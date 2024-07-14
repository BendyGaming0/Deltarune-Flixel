package deltarune.game.states.substates;

import flixel.text.FlxText;

import deltarune.game.SubState;
import deltarune.game.states.substates.Options.NoSuccess;

class SavingState extends SubState
{
    var _temp_save_text:FlxText;
    var save_id:Int;

    override public function create()
    {
		_temp_save_text = new FlxText(16, 16, 0, 'Selected < $save_id >, Press [ENTER / Z] to save');
        add(_temp_save_text);

		bgColor = 0x80000000;

        super.create();
    }

    override public function update(elapsed:Float)
    {
        super.update(elapsed);
    }

    public function createTestSaveString(id:Int)
    {
		var save_name = Options.grabSaveData('name', null, id);
		var raw_time = Options.grabSaveData('play_time', null, id);
        var save_text;

		if (save_name == NoSuccess.NoSaveData || save_name == null)
		{
			save_text = Options.defaultData.name;
		}
		else
		{
			save_text = Options.defaultData.name;
		}

        save_text += " | Time : ";

        if (raw_time == NoSuccess.NoSaveData || raw_time == null)
        {
			save_text += "N/A";
        }
        else
        {
			var save_play_time = Date.fromTime(cast raw_time);
			// 3600 000 is an hour when using Date.getTime
			save_text += Math.floor(save_play_time.getTime() / 3600000) + DateTools.format(save_play_time, ":%M:%S");
        }

        return save_text;
    }
}