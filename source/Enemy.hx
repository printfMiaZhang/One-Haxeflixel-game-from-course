package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.effects.particles.FlxEmitter;
import flixel.math.FlxPoint;
import flixel.math.FlxVelocity;
import flixel.system.FlxSound;
import flixel.util.FlxColor;

using flixel.util.FlxSpriteUtil;

class Enemy extends FlxSprite
{
	var _thrust:Float;

	var _player:Player;

	var _playerMidpoint:FlxPoint;
	var _velocityAngle:Float;

	var _pieces:FlxEmitter;

	// 一个用以判断死亡时是否加分的 flag （由于岩浆会杀死敌人，这个情况下敌人的死亡不会奖励分数）
	public var score_up:Bool = true;

	// 初始化该对象时需传递一个 Player 对象以供引用其数据，以及传递一个粒子发射器
	public function new(player:Player, pieces:FlxEmitter)
	{
		super();
		_pieces = pieces;
		health = 5;
		// makeGraphic(12, 12, FlxColor.ORANGE);
		loadGraphic(AssetPaths.enemy__png, false, 13, 13);
		setSize(11, 10);
		offset.set(1, 2);
		centerOffsets();
		_thrust = 0;
		_player = player;
		_playerMidpoint = FlxPoint.get();
	}

	override function update(elapsed:Float)
	{
		_velocityAngle = angleTowardPlayer();

		// 计算该对象的运动速度
		_thrust = FlxVelocity.computeVelocity(_thrust, 35, drag.x, 60, elapsed);
		velocity.set(0, -_thrust);

		// 更新运动方向的角度
		velocity.rotate(FlxPoint.weak(0, 0), _velocityAngle);
		super.update(elapsed);

		// 面朝玩家方向
		if (_player.x > x)
			flipX = false;
		else if (_player.x < x)
			flipX = true;
	}

	override function hurt(damage:Float)
	{
		FlxSpriteUtil.flicker(this, 0.2, 0.02, true);
		super.hurt(damage);
	}

	override function kill()
	{
		FlxG.sound.play(AssetPaths.aseplode__wav);

		// 如果敌人的可以加分（flag为true）则更新全局变量 score 的数据
		if (score_up)
			Reg.score += 20;
		super.kill();

		// 发射粒子碎片
		if (_pieces != null)
		{
			_pieces.focusOn(this);
			_pieces.start(true, 0, 20);
		}
	}

	// 从对象池中回收小可爱时顺便调用该函数以设定此小可爱的一些初始参数
	public function init(posx:Float, posy:Float, player:Player, pieces:FlxEmitter)
	{
		_player = player;
		_velocityAngle = angleTowardPlayer();
		_pieces = pieces;
		score_up = true;
		reset(posx - width / 2, posy - height / 2);
	}

	// 计算这个小可爱与玩家之间所构成的夹角
	function angleTowardPlayer():Float
	{
		return getMidpoint(_point).angleBetween(_player.getMidpoint(_playerMidpoint));
	}
}
