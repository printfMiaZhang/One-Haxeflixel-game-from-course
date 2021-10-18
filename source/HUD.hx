import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;

class HUD extends FlxSpriteGroup
{
	private var _textScore:FlxText;

	var OFFSET:Int = 15;
	var healthDisplay:FlxText;

	public function new()
	{
		super();
		healthDisplay = new FlxText(OFFSET, OFFSET);
		_textScore = new FlxText(OFFSET, healthDisplay.y + healthDisplay.height);
		add(healthDisplay);
		add(_textScore);
		healthDisplay.scrollFactor = FlxPoint.weak(0, 0);
		_textScore.scrollFactor = FlxPoint.weak(0, 0);
	}

	override public function update(elapsed:Float)
	{
		healthDisplay.text = "HP: " + Reg.playerHealth + "/" + Reg.player_MAX_HEALTH;
		_textScore.text = "SCORE: " + Reg.score;
		super.update(elapsed);
	}
}
