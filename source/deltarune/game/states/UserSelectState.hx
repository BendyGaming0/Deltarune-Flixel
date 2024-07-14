package deltarune.game.states;

import haxe.ds.ReadOnlyArray;
import haxe.ds.ArraySort;
import flixel.util.FlxSort;
import deltarune.game.State;

#if sys
import sys.FileSystem;
#end

class UserSelectState extends State
{
    override public function create()
    {
        Game.initialize();

        super.create();

        var users:Array<String> = [];
        
        #if !sys
        if (Game.globalSave.bind("_userlist", "savedata/global")) {
			if (globalSave.data.users == null)
				globalSave.data.users = [];
			users.concat(globalSave.data.users);
        }
        #else
		var saveDataDir = Sys.getCwd() + '/savedata/global/';
		for (saveFile in FileSystem.readDirectory(saveDataDir))
        {
            if (FileSystem.isDirectory(saveDataDir+saveFile) || saveFile == "_userlist" || saveFile == "_default")
                continue;
            users.push(saveFile);
        }
        #end
		ArraySort.sort(users, sortAlphabetically.bind(FlxSort.ASCENDING));
    }

	private static function sortAlphabetically(order:Int = -1, a:String, b:String)
    {
		if (a == b)
			return 0;
        var al:String = a.toLowerCase();
        var bl:String = b.toLowerCase();
		var av:Int;
		var bv:Int;
		for (index in 0...Std.int(Math.min(a.length, b.length)))
		{
			av = al.charCodeAt(index);
			bv = bl.charCodeAt(index);
			if (av < bv)
				return order;
			else if (bv < av)
				return -order;
		}
		if (a.length > b.length)
			return -order;
		else
			return order;
    }
}