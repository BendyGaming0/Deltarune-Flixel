package deltarune.game.states;

import deltarune.game.State;

class SaveSelectState extends State
{
    public var selectionOther:Bool = false;
    public var saveSelected:Int = 0;
    public var saveOption:Int = 0;
    public var otherOption:Int = 0;
    public var copying:Bool = false;

    override public function create() {

    }

    override public function update(elapsed:Float) {
        super.update(elapsed);
    }
}