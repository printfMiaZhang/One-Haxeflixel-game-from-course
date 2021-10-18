package;

import flixel.util.FlxSave;

// 这个类主要用于声明一些全局数据，这些数据需要在不同对象间进行访问以便更新
class Reg
{
	static public var save:FlxSave;
	// static public var player:Player;
	static public var playerHealth:Float;
	static public var player_MAX_HEALTH:Float;
	static public var score:Float = 0;
}
