package;

import flixel.util.FlxSave;

// 这个类是工具类，主要声明了三个函数，分别用于 保存分数 读取分数 清空分数
// （游戏开始时会清空分数，具体看 MenuState.hx 以及 GameOverState.hx）
class MyUtil
{
	inline static var SAVE_DATA:String = "HIGHEST_SCORE";

	static public function saveScore():Void
	{
		Reg.save = new FlxSave();

		if (Reg.save.bind(SAVE_DATA))
		{
			if ((Reg.save.data.score == null) || (Reg.save.data.score < Reg.score))
				Reg.save.data.score = Reg.score;
		}

		Reg.save.flush();
	}

	static public function loadScore():Int
	{
		Reg.save = new FlxSave();

		if (Reg.save.bind(SAVE_DATA))
		{
			if ((Reg.save.data != null) && (Reg.save.data.score != null))
				return Reg.save.data.score;
		}

		return 0;
	}

	static public function clearSave():Void
	{
		Reg.save = new FlxSave();

		if (Reg.save.bind(SAVE_DATA))
			Reg.save.erase();
	}
}
