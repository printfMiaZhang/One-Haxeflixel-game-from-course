package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;

class GameOverState extends FlxState
{
	var current_score:FlxText;

	var highest_score:FlxText;

	var text_display:FlxText;

	override function create()
	{
		super.create();
		FlxG.mouse.visible = false;
		current_score = new FlxText();
		highest_score = new FlxText();
		text_display = new FlxText();

		current_score.screenCenter();
		current_score.y = FlxG.height / 3;
		highest_score.screenCenter();
		highest_score.y = current_score.y + current_score.height;
		text_display.screenCenter();
		text_display.y = FlxG.height * 2 / 3;

		current_score.text = "Score: " + Reg.score; // 显示这一轮游戏所获的的分数
		highest_score.text = "Highscore: " + MyUtil.loadScore(); // 显示历史最高分
		text_display.text = "Press SPACE to try again";

		current_score.x -= current_score.width / 2;
		highest_score.x -= highest_score.width / 2;
		text_display.x -= text_display.width / 2;

		add(current_score);
		add(highest_score);
		add(text_display);
	}

	override function update(elapsed:Float)
	{
		if (FlxG.keys.justPressed.SPACE)
			FlxG.switchState(new PlayState());
		super.update(elapsed);
	}
}
