package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.editors.ogmo.FlxOgmo3Loader;
import flixel.addons.ui.FlxClickArea;
import flixel.text.FlxText;
import flixel.tile.FlxTilemap;

// 游戏开始界面状态，游戏启动后会先跳转至此状态
class MenuState extends FlxState
{
	var text_display:FlxText;

	var mapLoader:FlxOgmo3Loader;
	var map:FlxTilemap;

	var background:FlxSprite;

	override function create()
	{
		super.create();

		mapLoader = new FlxOgmo3Loader(AssetPaths.test__ogmo, AssetPaths.test_room__json);
		map = mapLoader.loadTilemap(AssetPaths.walls_tile__png, "wall");
		background = new FlxSprite();
		background.loadGraphic(AssetPaths.BG__png, false, 320, 240);

		FlxG.mouse.visible = false;

		// 清空已保存的数据，如果你需要的话可以删除这一行
		MyUtil.clearSave();

		// 显示文字
		text_display = new FlxText();
		text_display.screenCenter();
		text_display.text = "Press SPACE to continue";
		text_display.x -= text_display.width / 2;

		add(background);
		add(map);
		add(text_display);
	}

	override function update(elapsed:Float)
	{
		// 按下空格跳转至 PlayState 状态
		if (FlxG.keys.justPressed.SPACE)
			FlxG.switchState(new PlayState());
		super.update(elapsed);                                                                                                       
	}
}
